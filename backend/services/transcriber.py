"""
Auraly Backend - Whisper Transcription Service
Uses OpenAI Whisper API for word-level timestamps ("karaoke" effect).
"""

import os
from openai import OpenAI


def transcribe(audio_path: str, language: str = "en") -> dict:
    """
    Transcribe audio using OpenAI Whisper with word-level timestamps.
    
    Args:
        audio_path: Path to the audio file (MP3/M4A/WAV)
        language: ISO 639-1 language code (e.g., 'en', 'es', 'fr')
    
    Returns:
        dict with keys:
            - text: Full transcript text
            - words: List of {word, start, end} for karaoke effect
            - segments: List of {text, start, end, words[]} grouped by sentence
    """
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

    # Map display language names to ISO codes for Whisper
    lang_code = _get_language_code(language)

    with open(audio_path, "rb") as audio_file:
        # Build params — omit language for 'auto' so Whisper detects it
        params = {
            "model": "whisper-1",
            "file": audio_file,
            "response_format": "verbose_json",
            "timestamp_granularities": ["word", "segment"],
            "prompt": "Hello, welcome to my video. Let's get started.",
        }
        if lang_code:
            params["language"] = lang_code
        
        response = client.audio.transcriptions.create(**params)

    # Extract word-level data
    words = []
    if hasattr(response, "words") and response.words:
        for w in response.words:
            words.append({
                "word": w.word.strip(),
                "start": round(w.start, 3),
                "end": round(w.end, 3),
            })

    # Extract segment-level data (sentences)
    segments = []
    if hasattr(response, "segments") and response.segments:
        for seg in response.segments:
            segments.append({
                "text": seg.text.strip() if hasattr(seg, "text") else "",
                "start": round(seg.start, 3) if hasattr(seg, "start") else 0,
                "end": round(seg.end, 3) if hasattr(seg, "end") else 0,
            })
    else:
        # Fallback: group words into segments by punctuation
        segments = _group_words_into_segments(words)

    return {
        "text": response.text if hasattr(response, "text") else "",
        "words": words,
        "segments": segments,
    }


def _group_words_into_segments(words: list, max_words_per_segment: int = 15) -> list:
    """
    Fallback: group words into sentence-like segments using punctuation.
    """
    if not words:
        return []

    segments = []
    current_segment_words = []
    segment_start = words[0]["start"] if words else 0

    for w in words:
        current_segment_words.append(w["word"])

        # Break on sentence-ending punctuation or after max words
        is_sentence_end = w["word"].rstrip().endswith((".", "!", "?", "...", "。", "！", "？"))
        is_too_long = len(current_segment_words) >= max_words_per_segment

        if is_sentence_end or is_too_long:
            segments.append({
                "text": " ".join(current_segment_words).strip(),
                "start": round(segment_start, 3),
                "end": round(w["end"], 3),
            })
            current_segment_words = []
            segment_start = w["end"]

    # Don't forget remaining words
    if current_segment_words:
        segments.append({
            "text": " ".join(current_segment_words).strip(),
            "start": round(segment_start, 3),
            "end": round(words[-1]["end"], 3),
        })

    return segments


def _get_language_code(language: str) -> str | None:
    """Map display language name to ISO 639-1 code for Whisper.
    Returns None for 'auto' to let Whisper auto-detect."""
    if language.lower() == "auto":
        return None  # Whisper auto-detects when no language specified
    
    mapping = {
        # Popular / Major
        "english": "en", "spanish": "es", "french": "fr", "chinese": "zh",
        "german": "de", "japanese": "ja", "korean": "ko", "italian": "it",
        "portuguese": "pt", "russian": "ru", "arabic": "ar", "turkish": "tr",
        "hindi": "hi", "dutch": "nl", "polish": "pl", "swedish": "sv",
        "norwegian": "no", "danish": "da", "finnish": "fi", "greek": "el",
        "czech": "cs", "romanian": "ro", "hungarian": "hu", "thai": "th",
        "vietnamese": "vi", "indonesian": "id", "malay": "ms", "filipino": "tl",
        "swahili": "sw", "ukrainian": "uk", "persian": "fa", "hebrew": "he",
        # South Asian
        "bengali": "bn", "tamil": "ta", "telugu": "te", "urdu": "ur",
        "marathi": "mr", "gujarati": "gu", "kannada": "kn", "malayalam": "ml",
        "punjabi": "pa", "nepali": "ne", "sinhala": "si", "assamese": "as",
        "odia": "or", "sanskrit": "sa",
        # Southeast Asian
        "burmese": "my", "khmer": "km", "lao": "lo", "mongolian": "mn",
        "cebuano": "ceb", "tagalog": "tl", "javanese": "jw", "sundanese": "su",
        # East Asian
        "cantonese": "yue", "taiwanese": "zh", "tibetan": "bo",
        # European
        "catalan": "ca", "galician": "gl", "basque": "eu",
        "croatian": "hr", "serbian": "sr", "bosnian": "bs",
        "slovak": "sk", "slovenian": "sl", "bulgarian": "bg",
        "macedonian": "mk", "albanian": "sq",
        "latvian": "lv", "lithuanian": "lt", "estonian": "et",
        "icelandic": "is", "welsh": "cy", "irish": "ga",
        "scottish gaelic": "gd", "breton": "br", "occitan": "oc",
        "corsican": "co", "luxembourgish": "lb", "maltese": "mt",
        "belarusian": "be", "armenian": "hy", "georgian": "ka",
        "azerbaijani": "az", "kazakh": "kk", "uzbek": "uz",
        "turkmen": "tk", "kyrgyz": "ky", "tajik": "tg",
        "montenegrin": "sr", "faroese": "fo",
        # African
        "afrikaans": "af", "zulu": "zu", "xhosa": "xh",
        "sotho": "st", "tswana": "tn", "yoruba": "yo",
        "igbo": "ig", "hausa": "ha", "amharic": "am",
        "tigrinya": "ti", "somali": "so", "malagasy": "mg",
        "kinyarwanda": "rw", "wolof": "wo", "bambara": "bm",
        "akan": "ak", "shona": "sn", "tsonga": "ts",
        "venda": "ve", "ndebele": "nr", "kirundi": "rn",
        "lingala": "ln", "oromo": "om",
        # Middle Eastern & Central Asian
        "kurdish": "ku", "pashto": "ps", "sindhi": "sd",
        # Pacific & Oceanic
        "maori": "mi", "samoan": "sm", "tongan": "to",
        "hawaiian": "haw",
        # Americas
        "guarani": "gn", "quechua": "qu", "aymara": "ay",
        "haitian creole": "ht",
        # Constructed & Classical
        "esperanto": "eo", "latin": "la",
        # Additional Arabic dialects → base Arabic code
        "sudanese arabic": "ar", "libyan arabic": "ar",
        "moroccan arabic": "ar", "egyptian arabic": "ar",
        "levantine arabic": "ar",
        # Additional
        "dhivehi": "dv", "tatar": "tt", "bashkir": "ba",
        "uyghur": "ug", "tamil (sri lankan)": "ta",
    }
    return mapping.get(language.lower(), None)  # None = auto-detect for unknown
