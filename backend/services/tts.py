"""
Talkio Backend - OpenAI TTS Service
Generates spoken audio of the lesson summary/translations.

Uses pydub + ffmpeg for proper MP3 concatenation when text is chunked.
"""

import os
import uuid
import tempfile
from pathlib import Path
from openai import OpenAI


STATIC_AUDIO_DIR = Path(__file__).parent.parent / "static" / "audio"
STATIC_AUDIO_DIR.mkdir(parents=True, exist_ok=True)


def chunk_text_by_punctuation(text: str, chunk_size: int = 4000) -> list[str]:
    """Split text into chunks by punctuation marks, respecting a max size.
    
    Chunk size raised to 4000 (OpenAI TTS-1 supports up to 4096 chars).
    This reduces the number of chunks needed, minimising concatenation risk.
    """
    if len(text) <= chunk_size:
        return [text]
        
    chunks = []
    current_chunk = ""
    
    import re
    sentences = re.split(r'(?<=[.!?])\s+', text)
    
    for sentence in sentences:
        if len(current_chunk) + len(sentence) < chunk_size:
            current_chunk += sentence + " "
        else:
            if current_chunk.strip():
                chunks.append(current_chunk.strip())
            current_chunk = sentence + " "
            
    if current_chunk.strip():
        chunks.append(current_chunk.strip())
        
    return chunks


def _concat_mp3_files(chunk_paths: list[Path], output_path: Path) -> bool:
    """Properly concatenate multiple MP3 files into one using pydub + ffmpeg.
    
    Binary appending of MP3s creates corrupt files (duplicate headers, broken
    seeking). iOS AVFoundation is strict about this and refuses to play them.
    pydub decodes each chunk, concatenates the raw audio, then re-encodes as
    a single valid MP3 file.
    
    Returns True on success, False on failure.
    """
    try:
        from pydub import AudioSegment

        combined = AudioSegment.empty()
        for path in chunk_paths:
            segment = AudioSegment.from_mp3(str(path))
            combined += segment

        combined.export(str(output_path), format="mp3", bitrate="128k")
        return True

    except Exception as e:
        print(f"⚠️ TTS: pydub concatenation failed: {e}")
        print("   Falling back to first-chunk-only output")
        # Fallback: use just the first chunk (at least it's a valid MP3)
        if chunk_paths and chunk_paths[0].exists():
            import shutil
            shutil.copy2(str(chunk_paths[0]), str(output_path))
            return True
        return False


def generate_speech(text: str, voice: str = "alloy") -> str:
    """
    Generate speech audio from text using OpenAI TTS.
    Chunks long text, generates each chunk, then merges with pydub.
    
    Args:
        text: The text to convert to speech (translated segments or summary)
        voice: OpenAI TTS voice (alloy, echo, fable, onyx, nova, shimmer)
    
    Returns:
        Relative URL path to the generated audio file (e.g., "/static/audio/tts_abc123.mp3")
        Returns empty string if TTS generation fails (non-fatal).
    """
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("❌ TTS: OPENAI_API_KEY not set — skipping TTS generation")
        return ""

    # Guard against empty/whitespace-only text
    if not text or not text.strip():
        print("⚠️  TTS: No text provided — skipping TTS generation")
        return ""

    client = OpenAI(api_key=api_key)

    audio_id = str(uuid.uuid4())[:8]
    filename = f"tts_{audio_id}.mp3"
    filepath = STATIC_AUDIO_DIR / filename
    
    text_chunks = chunk_text_by_punctuation(text)
    print(f"🔊 TTS: Text length {len(text)} chars, split into {len(text_chunks)} chunk(s) for {voice} voice")

    # Create a temp directory for chunk files
    tmp_dir = tempfile.mkdtemp(prefix="tts_chunks_")
    chunk_paths: list[Path] = []

    try:
        # Generate each chunk as a separate MP3 file
        for i, chunk in enumerate(text_chunks):
            print(f"   Generating speech for chunk {i+1}/{len(text_chunks)} ({len(chunk)} chars)...")
            
            try:
                response = client.audio.speech.create(
                    model="tts-1",
                    voice=voice,
                    input=chunk,
                    response_format="mp3",
                )
            except Exception as api_err:
                print(f"   ❌ TTS API error on chunk {i+1}: {api_err}")
                # If the first chunk fails, we can't produce any audio
                if i == 0:
                    return ""
                # If a later chunk fails, continue with what we have
                print(f"   ⚠️ Skipping chunk {i+1}, will use {i} chunk(s)")
                break

            chunk_path = Path(tmp_dir) / f"chunk_{i}.mp3"
            with open(chunk_path, "wb") as f:
                for audio_bytes in response.iter_bytes():
                    f.write(audio_bytes)
            
            # Verify chunk file is reasonable
            chunk_size = chunk_path.stat().st_size
            if chunk_size < 100:
                print(f"   ⚠️ Chunk {i+1} is suspiciously small ({chunk_size} bytes), skipping")
                continue
            
            chunk_paths.append(chunk_path)
            print(f"   ✅ Chunk {i+1}: {chunk_size:,} bytes")

        if not chunk_paths:
            print("❌ TTS: No valid chunks were generated")
            return ""

        # Single chunk: just move the file directly (no concatenation needed)
        if len(chunk_paths) == 1:
            import shutil
            shutil.move(str(chunk_paths[0]), str(filepath))
        else:
            # Multiple chunks: properly concatenate using pydub + ffmpeg
            print(f"   🔗 Concatenating {len(chunk_paths)} chunks with pydub...")
            success = _concat_mp3_files(chunk_paths, filepath)
            if not success:
                print("❌ TTS: Failed to concatenate chunks")
                return ""

        # Final verification
        if not filepath.exists():
            print("❌ TTS: Output file was not created")
            return ""
        
        file_size = filepath.stat().st_size
        if file_size < 100:
            print(f"❌ TTS: Generated file is suspiciously small ({file_size} bytes)")
            filepath.unlink(missing_ok=True)
            return ""

        print(f"✅ TTS: Generated {filename} ({file_size:,} bytes)")
        return f"/static/audio/{filename}"

    except Exception as e:
        print(f"❌ TTS: Failed to generate speech: {type(e).__name__}: {e}")
        # Clean up any partial file
        if filepath.exists():
            filepath.unlink(missing_ok=True)
        return ""

    finally:
        # Clean up temp chunk files
        import shutil
        shutil.rmtree(tmp_dir, ignore_errors=True)
