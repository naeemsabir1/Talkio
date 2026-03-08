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
    target_language: str = "English"  # Target learning language
    app_ui_language: str = "en"  # The overall app UI language (e.g. "es", "en")


class CopyeditRequest(BaseModel):
    text: str


class CopyeditResponse(BaseModel):
    formatted_text: str


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
    meaning: str
    explanation: str
    example: str | None = None


class GrammarExample(BaseModel):
    sentence: str
    translation: str


class GrammarPoint(BaseModel):
    type: str
    title: str
    explanation: str
    examples: list[GrammarExample]


class PronounExample(BaseModel):
    sentence: str
    translation: str


class PronounItem(BaseModel):
    category: str
    word: str
    explanation: str
    examples: list[PronounExample]



class ConjugationItem(BaseModel):
    form: str
    example: str
    translation: str
    explanation: str


class QuizItem(BaseModel):
    question: str
    hint: str
    explanation: str
    correct_answer: str
    wrong_answers: list[str]


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
    quiz: list[QuizItem]
    pronouns: list[PronounItem]
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


# ─── Copyeditor Endpoint ──────────────────────────────────────

@app.post("/api/copyedit", response_model=CopyeditResponse)
async def copyedit_text(request: CopyeditRequest):
    """
    Format raw transcription with AI to add punctuation and capitalization.
    DOES NOT change original words.
    """
    from openai import OpenAI
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
    
    system_prompt = "You are an expert English copyeditor. Your only job is to take the following raw speech-to-text transcript and add proper punctuation, capitalization, and grammatical formatting. DO NOT change the original words, do not summarize, and do not add conversational filler. Output ONLY the perfectly formatted text."
    
    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": request.text},
            ],
            temperature=0.3,
            max_tokens=4000,
        )
        formatted = response.choices[0].message.content.strip()
        return CopyeditResponse(formatted_text=formatted)
    except Exception as e:
        print(f"❌ Copyedit error: {e}")
        return CopyeditResponse(formatted_text=request.text)


# ─── Main Processing Endpoint ─────────────────────────────────

@app.post("/api/process", response_model=ProcessResponse)
async def process_url(request: ProcessRequest, raw_request: Request):
    """
    Full pipeline: URL → Audio → Transcript → Analysis → TTS → Memo
    
    This is the main endpoint that the Flutter app calls.
    """
    request_id = None

    pipeline_start = time.time()

    try:
        # ── Step 1: Extract Audio ──────────────────────────────
        step_start = time.time()
        print(f"🎬 Step 1/4: Extracting audio from {request.url}")
        extraction = extract_audio(request.url)
        request_id = extraction["request_id"]
        audio_path = extraction["audio_path"]
        thumbnail_url = extraction["thumbnail_url"]
        video_title = extraction["title"]
        platform = extraction["platform"]
        print(f"   ✅ Audio extracted: {audio_path} ({time.time() - step_start:.1f}s)")

        # ── Step 2: Transcribe with Whisper ────────────────────
        step_start = time.time()
        print(f"🎤 Step 2/4: Transcribing audio ({request.language})")
        transcription = transcribe(audio_path, request.language)
        transcript_text = transcription["text"]
        words = transcription["words"]
        segments = transcription["segments"]
        print(f"   ✅ Transcribed: {len(words)} words, {len(segments)} segments ({time.time() - step_start:.1f}s)")

        if not transcript_text.strip():
            raise ValueError("No speech detected in the audio. The video may not contain spoken content.")

        # ── Step 3: Analyze with GPT-4o ────────────────────────
        step_start = time.time()
        print(f"🧠 Step 3/4: Analyzing content with GPT-4o")
        analysis = analyze(transcript_text, request.language, request.target_language, request.app_ui_language, segments)
        print(f"   ✅ Analysis complete: {len(analysis['vocabulary'])} vocab, {len(analysis['grammar'])} grammar points ({time.time() - step_start:.1f}s)")

        # ── Step 4: Generate TTS Audio ─────────────────────────────
        # For LONG videos: use the lesson summary for TTS voice (concise, 1 chunk, fast)
        # For SHORT videos: use the full translation (more detail, still fits 1-2 chunks)
        step_start = time.time()
        translated = analysis.get("translated_segments", [])
        if translated:
            full_translation = " ".join(t.get("translation", t.get("original", "")) for t in translated)
        else:
            full_translation = ""

        # Smart TTS text selection: summary for long content, translation for short
        if len(full_translation) > 3000:
            tts_text = analysis["summary"]
            print(f"🔊 Step 4/4: TTS using SUMMARY ({len(tts_text)} chars) — full translation too long ({len(full_translation)} chars)")
        elif full_translation:
            tts_text = full_translation
            print(f"🔊 Step 4/4: TTS using full translation ({len(tts_text)} chars)")
        else:
            tts_text = analysis["summary"]
            print(f"🔊 Step 4/4: TTS using summary as fallback ({len(tts_text)} chars)")

        tts_audio_path = generate_speech(tts_text)
        # Build full audio URL so mobile devices can reach it
        # Guard: if TTS failed (returned ""), keep audioUrl empty instead of
        # building a broken URL like "https://host" with no audio path.
        if tts_audio_path:
            base_url = str(raw_request.base_url).rstrip('/')
            tts_full_url = f"{base_url}{tts_audio_path}"
        else:
            tts_full_url = ""
            print("   ⚠️ TTS generation returned empty — audioUrl will be empty")
        print(f"   ✅ TTS audio: {tts_full_url or '(none)'} ({time.time() - step_start:.1f}s)")

        # ── Build Response ─────────────────────────────────────
        # Use GPT-generated title, fallback to video title
        lesson_title = analysis.get("title", video_title) or video_title

        # Build transcript segments from GPT translations + Whisper timestamps using ID mapping
        transcript_segments = []
        translated = analysis.get("translated_segments", [])

        if translated:
            # Map by ID
            for ts in translated:
                seg_id = ts.get("id")
                if seg_id is not None and seg_id < len(segments):
                    orig_seg = segments[seg_id]
                    transcript_segments.append(TranscriptSegment(
                        original=orig_seg["text"],
                        translation=ts.get("translation", orig_seg["text"]),
                        timestamp=orig_seg["start"],
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
                meaning=v.get("meaning", v.get("definition", "")),
                explanation=v.get("explanation", ""),
                example=v.get("example"),
            )
            for v in analysis.get("vocabulary", [])
        ]

        # Build grammar list
        grammar = []
        for g in analysis.get("grammar", []):
            examples = []
            for ex in g.get("examples", []):
                if isinstance(ex, dict):
                    examples.append(GrammarExample(
                        sentence=ex.get("sentence", ""),
                        translation=ex.get("translation", "")
                    ))
                elif isinstance(ex, str):
                    examples.append(GrammarExample(
                        sentence=ex,
                        translation=""
                    ))
            
            grammar.append(GrammarPoint(
                type=g.get("type", "General"),
                title=g.get("title", ""),
                explanation=g.get("explanation", ""),
                examples=examples,
            ))

        # Build pronouns list
        pronouns = []
        for p in analysis.get("pronouns", []):
            examples = []
            for ex in p.get("examples", []):
                examples.append(PronounExample(
                    sentence=ex.get("sentence", ""),
                    translation=ex.get("translation", "")
                ))
            pronouns.append(PronounItem(
                category=p.get("category", ""),
                word=p.get("word", ""),
                explanation=p.get("explanation", ""),
                examples=examples
            ))

        # Build conjugation list
        conjugations = [
            ConjugationItem(
                form=c.get("form", ""),
                example=c.get("example", ""),
                translation=c.get("translation", ""),
                explanation=c.get("explanation", ""),
            )
            for c in analysis.get("conjugations", [])
        ]

        # Build generated quiz items
        quiz_items = []
        for q in analysis.get("quiz", []):
            try:
                quiz_items.append(QuizItem(
                    question=q.get("question", ""),
                    hint=q.get("hint", ""),
                    explanation=q.get("explanation", ""),
                    correct_answer=q.get("correct_answer", ""),
                    wrong_answers=q.get("wrong_answers", []),
                ))
            except Exception:
                pass


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
            quiz=quiz_items,
            pronouns=pronouns,
            words=word_timestamps,
        )

        elapsed = time.time() - pipeline_start
        print(f"🎉 Processing complete! Memo ID: {memo_id} — Total pipeline: {elapsed:.1f}s ({elapsed/60:.1f} min)")
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
