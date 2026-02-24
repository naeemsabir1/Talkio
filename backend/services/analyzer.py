"""
Auraly Backend - GPT-4o Educational Analysis Service
Generates summary, vocabulary, grammar, conjugations, and translations.
"""

import os
import json
from openai import OpenAI


def analyze(transcript_text: str, source_language: str, target_language: str, segments: list) -> dict:
    """
    Use GPT-4o to generate educational content from a transcript.
    
    Args:
        transcript_text: Full transcript text
        source_language: Language of the video content
        target_language: User's learning language (for translations/explanations)
        segments: List of transcript segments with start/end times
    
    Returns:
        dict with keys: summary, title, vocabulary[], grammar[], conjugations[], translated_segments[]
    """
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

    # Build the segments text for context  
    segments_text = "\n".join(
        f"[{s['start']:.1f}s - {s['end']:.1f}s] {s['text']}"
        for s in segments
    )

    # Logic: Native Mode vs Learner Mode
    is_native_mode = source_language.lower() == target_language.lower()
    
    translation_instruction = ""
    if is_native_mode:
        translation_instruction = """
        - Start 'translated_segments' with an EMPTY list []. Do NOT translate.
        - Focus heavily on advanced vocabulary and deeper grammar nuances.
        - Explanations should be in the source language itself.
        """
    else:
        translation_instruction = f"""
        - For 'translated_segments', translate EACH segment into {target_language}.
        - Grammar explanations must be written in {target_language} to help the learner understand.
        - Vocabulary definitions can be in {target_language}.
        """

    system_prompt = f"""You are an expert language teacher and linguist. 
Analyze the following transcript from a social media video.
The video content is in **{source_language}**.
The user is learning this language, and their native language/preference is **{target_language}**.

Your task is to produce a structured educational lesson.
You MUST respond with valid JSON and nothing else.

The JSON must have this exact structure:
{{
  "title": "A short, catchy title for this lesson (max 6 words, in {target_language})",
  "summary": "A 2-3 sentence summary describing the content and context (in {target_language}).",
  "vocabulary": [
    {{
      "word": "the word or phrase (in {source_language})",
      "pronunciation": "phonetic pronunciation guide",
      "definition": "clear definition (in {target_language})",
      "example": "an example sentence using this word from context (optional)"
    }}
  ],
  "grammar": [
    {{
      "type": "one of: Pronoun, Negation, Tense, Verb, Question, Article, Adjective, Adverb, Preposition, Idiom",
      "title": "Name of the concept (in {target_language})",
      "explanation": "Clear explanation of this rule (in {target_language})",
      "examples": ["example sentence 1", "example sentence 2"]
    }}
  ],
  "conjugations": [
    {{
      "form": "The verb form (e.g., Present Simple, Past Tense)",
      "example": "An example from the transcript"
    }}
  ],
  "translated_segments": [
    {{
      "original": "Original text from transcript",
      "translation": "Translation in {target_language}",
      "timestamp": 0.0
    }}
  ]
}}

RULES:
1. Extract 5-10 vocabulary items that are most educational.
2. Identify 3-6 grammar points with clear explanations.
3. Include 2-5 conjugation examples if applicable.
4. Pronunciation should use simple phonetic notation (e.g., "sur-praiz").
5. {translation_instruction}
6. Format the transcription with flawless grammar, adding accurate commas, full stops, and capitalization without altering the original words.
"""

    user_prompt = f"""Here is the transcript to analyze:

FULL TEXT:
{transcript_text}

TIMED SEGMENTS:
{segments_text}

Generate the educational lesson JSON now."""

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        response_format={"type": "json_object"},
        temperature=0.7,
        max_tokens=4000,
    )

    content = response.choices[0].message.content
    result = json.loads(content)

    # Validate and provide defaults
    return {
        "title": result.get("title", "Untitled Lesson"),
        "summary": result.get("summary", "No summary available."),
        "vocabulary": result.get("vocabulary", []),
        "grammar": result.get("grammar", []),
        "conjugations": result.get("conjugations", []),
        "translated_segments": result.get("translated_segments", []),
    }
