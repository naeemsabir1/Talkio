"""
Auraly Backend - OpenAI TTS Service
Generates spoken audio of the lesson summary/translations.
"""

import os
import uuid
from pathlib import Path
from openai import OpenAI


STATIC_AUDIO_DIR = Path(__file__).parent.parent / "static" / "audio"
STATIC_AUDIO_DIR.mkdir(parents=True, exist_ok=True)


def generate_speech(text: str, voice: str = "alloy") -> str:
    """
    Generate speech audio from text using OpenAI TTS.
    
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

    # Truncate very long text (TTS has a ~4096 char limit for best results)
    if len(text) > 4000:
        print(f"⚠️  TTS: Truncating text from {len(text)} to 4000 chars")
        text = text[:4000]

    client = OpenAI(api_key=api_key)

    audio_id = str(uuid.uuid4())[:8]
    filename = f"tts_{audio_id}.mp3"
    filepath = STATIC_AUDIO_DIR / filename

    try:
        print(f"🔊 TTS: Generating speech ({len(text)} chars, voice={voice})...")
        response = client.audio.speech.create(
            model="tts-1",
            voice=voice,
            input=text,
            response_format="mp3",
        )

        # Write the response to file
        try:
            response.write_to_file(filepath)
        except AttributeError:
            # Fallback for different SDK versions: stream bytes directly
            with open(filepath, "wb") as f:
                for chunk in response.iter_bytes():
                    f.write(chunk)

        # Verify the file was actually created and has content
        if not filepath.exists():
            print("❌ TTS: File was not created after write")
            return ""
        
        file_size = filepath.stat().st_size
        if file_size < 100:  # An MP3 file should be at least a few hundred bytes
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
        # Return empty string instead of crashing — TTS is non-critical
        return ""
