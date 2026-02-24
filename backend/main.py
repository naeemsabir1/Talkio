"""
Auraly Backend - FastAPI Server
Orchestrates the full content processing pipeline:
URL → Audio Extraction → Transcription → Analysis → TTS → Memo JSON
"""

import os
import shutil
import time
from pathlib import Path
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Request
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from services.extractor import extract_audio, cleanup_temp
from services.transcriber import transcribe
from services.analyzer import analyze
from services.tts import generate_speech


# ─── Load environment variables ───────────────────────────────
_env_path = Path(__file__).parent / ".env"
load_dotenv(dotenv_path=_env_path)

if not os.getenv("OPENAI_API_KEY"):
    print("⚠️  WARNING: OPENAI_API_KEY not found in .env file!")
    print("   Copy .env.example to .env and add your key.")


# ─── Ensure directories exist ─────────────────────────────────
STATIC_DIR = Path(__file__).parent / "static"
AUDIO_DIR = STATIC_DIR / "audio"
TEMP_DIR = Path(__file__).parent / "temp"
STATIC_DIR.mkdir(exist_ok=True)
AUDIO_DIR.mkdir(exist_ok=True)
TEMP_DIR.mkdir(exist_ok=True)


# ─── FastAPI App ───────────────────────────────────────────────
app = FastAPI(
    title="Auraly AI Engine",
    description="Turns social media URLs into structured language lessons",
    version="1.0.0",
)

# CORS: Allow Flutter app to connect from anywhere during development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve static files (TTS audio)
app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")


# ─── Request/Response Models ──────────────────────────────────

class ProcessRequest(BaseModel):
    url: str
    language: str = "English"  # Source language (detected or specified)
    target_language: str = "English"  # Output language for translations & explanations


class WordTimestamp(BaseModel):
    word: str
    start: float
    end: float


class TranscriptSegment(BaseModel):
    original: str
    translation: str
    timestamp: float


class VocabularyItem(BaseModel):
    word: str
    pronunciation: str
    definition: str
    example: str | None = None


class GrammarPoint(BaseModel):
    type: str
    title: str
    explanation: str
    examples: list[str]


class ConjugationItem(BaseModel):
    form: str
    example: str


class ProcessResponse(BaseModel):
    id: str
    title: str
    sourceUrl: str
    sourcePlatform: str
    thumbnailUrl: str
    language: str
    summary: str
    audioUrl: str
    transcript: list[TranscriptSegment]
    vocabulary: list[VocabularyItem]
    grammar: list[GrammarPoint]
    conjugations: list[ConjugationItem]
    words: list[WordTimestamp]  # For karaoke effect


# ─── Health Check ──────────────────────────────────────────────

@app.get("/")
async def health_check():
    return {
        "status": "running",
        "service": "Auraly AI Engine",
        "api_key_configured": bool(os.getenv("OPENAI_API_KEY")),
    }


@app.get("/api/diagnostics")
async def diagnostics():
    """System health check for debugging deployment issues."""
    import subprocess as _sp

    def _check_binary(name: str) -> bool:
        try:
            _sp.run([name, "--version"], capture_output=True, timeout=5)
            return True
        except Exception:
            return False

    disk = shutil.disk_usage(STATIC_DIR)
    tts_files = list(AUDIO_DIR.glob("tts_*.mp3"))
    temp_files = list(TEMP_DIR.iterdir())

    return {
        "status": "ok",
        "ffmpeg_available": _check_binary("ffmpeg"),
        "ytdlp_available": _check_binary("yt-dlp"),
        "api_key_configured": bool(os.getenv("OPENAI_API_KEY")),
        "api_key_prefix": (os.getenv("OPENAI_API_KEY") or "")[:8] + "...",
        "disk_free_mb": round(disk.free / (1024 * 1024)),
        "tts_files_count": len(tts_files),
        "temp_files_count": len(temp_files),
        "env_path": str(_env_path),
        "env_exists": _env_path.exists(),
    }


# ─── Main Processing Endpoint ─────────────────────────────────

@app.post("/api/process", response_model=ProcessResponse)
async def process_url(request: ProcessRequest, raw_request: Request):
    """
    Full pipeline: URL → Audio → Transcript → Analysis → TTS → Memo
    
    This is the main endpoint that the Flutter app calls.
    """
    request_id = None

    try:
        # ── Step 1: Extract Audio ──────────────────────────────
        print(f"🎬 Step 1/4: Extracting audio from {request.url}")
        extraction = extract_audio(request.url)
        request_id = extraction["request_id"]
        audio_path = extraction["audio_path"]
        thumbnail_url = extraction["thumbnail_url"]
        video_title = extraction["title"]
        platform = extraction["platform"]
        print(f"   ✅ Audio extracted: {audio_path}")

        # ── Step 2: Transcribe with Whisper ────────────────────
        print(f"🎤 Step 2/4: Transcribing audio ({request.language})")
        transcription = transcribe(audio_path, request.language)
        transcript_text = transcription["text"]
        words = transcription["words"]
        segments = transcription["segments"]
        print(f"   ✅ Transcribed: {len(words)} words, {len(segments)} segments")

        if not transcript_text.strip():
            raise ValueError("No speech detected in the audio. The video may not contain spoken content.")

        # ── Step 3: Analyze with GPT-4o ────────────────────────
        print(f"🧠 Step 3/4: Analyzing content with GPT-4o")
        analysis = analyze(transcript_text, request.language, request.target_language, segments)
        print(f"   ✅ Analysis complete: {len(analysis['vocabulary'])} vocab, {len(analysis['grammar'])} grammar points")

        # ── Step 4: Generate TTS Audio ─────────────────────────────
        # Build TTS text from translations (so the voice speaks the translation)
        translated = analysis.get("translated_segments", [])
        if translated:
            tts_text = " ".join(t.get("translation", t.get("original", "")) for t in translated)
        else:
            # Same-language mode: use summary as fallback
            tts_text = analysis["summary"]
        
        print(f"🔊 Step 4/4: Generating TTS audio for translation")
        tts_audio_path = generate_speech(tts_text)
        # Build full audio URL so mobile devices can reach it
        base_url = str(raw_request.base_url).rstrip('/')
        tts_full_url = f"{base_url}{tts_audio_path}"
        print(f"   ✅ TTS audio: {tts_full_url}")

        # ── Build Response ─────────────────────────────────────
        # Use GPT-generated title, fallback to video title
        lesson_title = analysis.get("title", video_title) or video_title

        # Build transcript segments from GPT translations + Whisper timestamps
        transcript_segments = []
        translated = analysis.get("translated_segments", [])

        if translated:
            for ts in translated:
                transcript_segments.append(TranscriptSegment(
                    original=ts.get("original", ""),
                    translation=ts.get("translation", ts.get("original", "")),
                    timestamp=ts.get("timestamp", 0.0),
                ))
        else:
            # Fallback: use Whisper segments directly
            for seg in segments:
                transcript_segments.append(TranscriptSegment(
                    original=seg["text"],
                    translation=seg["text"],  # Same if no translation
                    timestamp=seg["start"],
                ))

        # Build vocabulary list
        vocabulary = [
            VocabularyItem(
                word=v.get("word", ""),
                pronunciation=v.get("pronunciation", ""),
                definition=v.get("definition", ""),
                example=v.get("example"),
            )
            for v in analysis.get("vocabulary", [])
        ]

        # Build grammar list
        grammar = [
            GrammarPoint(
                type=g.get("type", "General"),
                title=g.get("title", ""),
                explanation=g.get("explanation", ""),
                examples=g.get("examples", []),
            )
            for g in analysis.get("grammar", [])
        ]

        # Build conjugation list
        conjugations = [
            ConjugationItem(
                form=c.get("form", ""),
                example=c.get("example", ""),
            )
            for c in analysis.get("conjugations", [])
        ]

        # Build word timestamps for karaoke
        word_timestamps = [
            WordTimestamp(word=w["word"], start=w["start"], end=w["end"])
            for w in words
        ]

        # Generate unique memo ID
        memo_id = f"ai_{int(time.time() * 1000)}"

        response = ProcessResponse(
            id=memo_id,
            title=lesson_title,
            sourceUrl=request.url,
            sourcePlatform=platform,
            thumbnailUrl=thumbnail_url,
            language=request.language,
            summary=analysis["summary"],
            audioUrl=tts_full_url,
            transcript=transcript_segments,
            vocabulary=vocabulary,
            grammar=grammar,
            conjugations=conjugations,
            words=word_timestamps,
        )

        print(f"🎉 Processing complete! Memo ID: {memo_id}")
        return response

    except ValueError as e:
        # Known user-facing errors (private video, invalid URL, etc.)
        print(f"❌ Validation error: {e}")
        raise HTTPException(status_code=400, detail=str(e))

    except Exception as e:
        # Unexpected errors
        print(f"❌ Processing error: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"An error occurred while processing the video: {str(e)}"
        )

    finally:
        # Always clean up temporary files
        if request_id:
            cleanup_temp(request_id)
            print(f"🧹 Cleaned up temp files for {request_id}")


# ─── Run with: python -m uvicorn main:app --reload --port 8000 ─
if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=False)
