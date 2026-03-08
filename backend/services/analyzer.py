"""
Auraly Backend - GPT-4o Educational Analysis Service
Generates summary, vocabulary, grammar, conjugations, and translations.

Translation is handled by a DEDICATED API call (_translate_chunk) to prevent
token-budget exhaustion that previously caused truncated translations.
"""

import os
import json
from openai import OpenAI


def analyze(transcript_text: str, source_language: str, target_language: str, app_ui_language: str, segments: list) -> dict:
    """
    Use GPT-4o to generate educational content from a transcript.
    If the transcript is long, it chunks the processing to avoid hitting API character limits.

    Translation and educational content are generated in SEPARATE API calls
    to guarantee complete translations.
    """
    # Safe segment chunk size (in characters)
    MAX_CHUNK_CHARS = 5000 
    
    # 1. Chunk the segments
    chunks = []
    current_chunk = []
    current_len = 0
    
    for s in segments:
        s_text = f"[{s['start']:.1f}s - {s['end']:.1f}s] {s['text']}\n"
        if current_len + len(s_text) > MAX_CHUNK_CHARS and current_chunk:
            chunks.append(current_chunk)
            current_chunk = [s]
            current_len = len(s_text)
        else:
            current_chunk.append(s)
            current_len += len(s_text)
            
    if current_chunk:
        chunks.append(current_chunk)
        
    print(f"🧠 Chunked transcript into {len(chunks)} parts for analysis.")

    # 2. Process chunks
    all_translated = []
    all_vocab = []
    all_grammar = []
    all_conjugations = []
    all_quiz = []
    all_pronouns = []
    final_title = ""
    final_summary = ""
    final_translation = ""

    global_offset = 0

    for i, c_segments in enumerate(chunks):
        print(f"   Processing chunk {i+1}/{len(chunks)}...")
        chunk_text = " ".join([s['text'] for s in c_segments])

        # ── CALL 1: Dedicated translation (separate token budget) ──
        print(f"   📝 Translating chunk {i+1}...")
        translation_result = _translate_chunk(
            chunk_text, source_language, target_language,
            c_segments, global_offset
        )

        chunk_translation = translation_result.get("translation", "")
        chunk_translated_segments = translation_result.get("translated_segments", [])
        
        print(f"   ✅ Translation chunk {i+1}: {len(chunk_translation)} chars, {len(chunk_translated_segments)} segments")

        if chunk_translation:
            if final_translation:
                final_translation += " " + chunk_translation
            else:
                final_translation = chunk_translation
        
        all_translated.extend(chunk_translated_segments)

        # ── CALL 2: Educational content (vocab, grammar, etc.) ──
        print(f"   📚 Generating educational content for chunk {i+1}...")
        edu_result = _analyze_chunk(
            chunk_text, source_language, target_language,
            app_ui_language, c_segments, is_first=(i==0), global_offset=global_offset
        )
        
        all_vocab.extend(edu_result.get("vocabulary", []))
        all_grammar.extend(edu_result.get("grammar", []))
        all_conjugations.extend(edu_result.get("conjugations", []))
        all_quiz.extend(edu_result.get("quiz", []))
        all_pronouns.extend(edu_result.get("pronouns", []))
        
        global_offset += len(c_segments)
        
        if i == 0:
            final_title = edu_result.get("title", "Untitled Lesson")
            final_summary = edu_result.get("summary", "No summary available.")

    # Deduplicate vocab/grammar if needed, but simple append works for now
    # Limit vocab to top 15-20 to avoid massive lists
    all_vocab = all_vocab[:20]
    all_grammar = all_grammar[:15]
    all_conjugations = all_conjugations[:10]
    all_quiz = all_quiz[:5] # Max 5 questions for the quiz array
    all_pronouns = all_pronouns[:10]

    print(f"   ✅ Final translation total: {len(final_translation)} chars, {len(all_translated)} translated segments")

    return {
        "title": final_title,
        "summary": final_summary,
        "translation": final_translation,
        "vocabulary": all_vocab,
        "grammar": all_grammar,
        "conjugations": all_conjugations,
        "quiz": all_quiz,
        "pronouns": all_pronouns,
        "translated_segments": all_translated,
    }


# ═══════════════════════════════════════════════════════════════════
# DEDICATED TRANSLATION CALL — Separate token budget for full output
# ═══════════════════════════════════════════════════════════════════

def _translate_chunk(transcript_text: str, source_language: str, target_language: str, segments: list, global_offset: int = 0) -> dict:
    """
    Dedicated GPT-4o call ONLY for translation.
    
    This is separated from educational content analysis to guarantee
    the full translation is never truncated by token limits.
    
    Returns:
        dict with keys: translation (str), translated_segments (list)
    """
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

    # Build segment list for per-segment translation
    segments_text = "\n".join(
        f"[ID: {global_offset + idx}] {s['text']}"
        for idx, s in enumerate(segments)
    )

    system_prompt = f"""You are an expert translator. 
Your ONLY task is to translate text from **{source_language}** into **{target_language}**.

You MUST respond with valid JSON and nothing else.

The JSON must have this exact structure:
{{
  "translation": "The COMPLETE and FULL translation of the entire text below into {target_language}. Do NOT skip, summarize, or shorten any part. Translate EVERY SINGLE sentence fully.",
  "translated_segments": [
    {{
      "id": 0,
      "translation": "Full translation of segment ID 0 into {target_language}"
    }}
  ]
}}

CRITICAL RULES:
1. The "translation" field MUST contain the COMPLETE translation of the ENTIRE text. Do NOT abbreviate or truncate.
2. Every segment in the TIMED SEGMENTS list MUST have a corresponding entry in "translated_segments" with its matching "id".
3. Do NOT omit any segment. Translate ALL of them.
4. Do NOT add explanations, notes, or commentary. ONLY translate.
5. Maintain the natural flow and meaning of the original text."""

    user_prompt = f"""Translate this text completely:

FULL TEXT:
{transcript_text}

TIMED SEGMENTS (translate each one):
{segments_text}

Generate the complete translation JSON now."""

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        response_format={"type": "json_object"},
        temperature=0.3,
        max_tokens=8000,  # Generous budget dedicated ONLY to translation
    )

    content = response.choices[0].message.content
    result = json.loads(content)

    return {
        "translation": result.get("translation", ""),
        "translated_segments": result.get("translated_segments", []),
    }


# ═══════════════════════════════════════════════════════════════════
# EDUCATIONAL CONTENT CALL — Vocab, grammar, etc. (no translation)
# ═══════════════════════════════════════════════════════════════════

def _analyze_chunk(transcript_text: str, source_language: str, target_language: str, app_ui_language: str, segments: list, is_first: bool = True, global_offset: int = 0) -> dict:
    """
    Use GPT-4o to generate educational content from a transcript.
    Translation is handled separately by _translate_chunk().
    
    Args:
        transcript_text: Full transcript text
        source_language: Language of the video content
        target_language: User's learning language
        app_ui_language: The UI language of the app interface
        segments: List of transcript segments with start/end times
        is_first: Whether this is the first chunk
        global_offset: The index offset of the first segment in the full video
    
    Returns:
        dict with keys: summary, title, vocabulary[], grammar[], conjugations[], pronouns[], quiz[]
    """
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

    system_prompt = f"""You are an expert language teacher and linguist. 
Analyze the following transcript from a social media video.
The video content is in **{source_language}**.
The user is learning this language, and their target learning language is **{target_language}**.
The user interface language of their app is **{app_ui_language}**.

Your task is to produce a structured educational lesson.
You MUST respond with valid JSON and nothing else.

NOTE: Do NOT include any translation fields. Translation is handled separately.

The JSON must have this exact structure:
{{
  "title": "A short, catchy title for this lesson (max 6 words, in {app_ui_language})",
  "summary": "A 2-3 sentence summary describing the content and context (in {app_ui_language}).",
  "vocabulary": [
    {{
      "word": "the word or phrase (in {target_language})",
      "pronunciation": "phonetic pronunciation guide of the word using Romanized/English phonetics",
      "meaning": "clear meaning (in {app_ui_language})",
      "explanation": "Clear explanation of this word (in {app_ui_language})"
    }}
  ],
  "grammar": [
    {{
      "type": "one of: Pronoun, Negation, Tense, Verb, Question, Article, Adjective, Adverb, Preposition, Idiom",
      "title": "Name of the concept (in {app_ui_language})",
      "explanation": "Clear explanation of this rule (in {app_ui_language})",
      "examples": [
        {{
          "sentence": "Example sentence in {target_language}",
          "translation": "Translation of the example in {app_ui_language}"
        }}
      ]
    }}
  ],
  "pronouns": [
    {{
      "category": "[App UI Language: e.g., Pronombre personal]",
      "word": "[Target Language: e.g., میں]",
      "explanation": "[App UI Language: Explanation of usage in context]",
      "examples": [
        {{
          "sentence": "[Target Language: Sentence using the pronoun]",
          "translation": "[App UI Language: Translation of the sentence]"
        }}
      ]
    }}
  ],
  "conjugations": [
    {{
      "form": "The verb form (e.g., Present Simple, Past Tense) in {app_ui_language}",
      "example": "An example from the transcript in {target_language}",
      "translation": "Translation of the example in {app_ui_language}",
      "explanation": "Brief explanation in {app_ui_language}"
    }}
  ],
  "quiz": [
    {{
      "question": "A challenging multiple choice question (in {app_ui_language}). NEVER include the answer word in the question text.",
      "hint": "A subtle, helpful hint that guides without giving away the answer (in {app_ui_language})",
      "explanation": "A clear explanation of why the correct answer is right and why the others are wrong (in {app_ui_language})",
      "correct_answer": "The correct answer (in {target_language})",
      "wrong_answers": ["plausible wrong answer 1 (in {target_language})", "plausible wrong answer 2 (in {target_language})", "plausible wrong answer 3 (in {target_language})"]
    }}
  ]
}}

RULES:
1. Extract 5-10 vocabulary items that are most educational.
2. Identify 3-6 grammar points with clear explanations.
3. Include 2-5 conjugation examples if applicable.
4. Pronunciation must use simple phonetic notation (e.g., "sur-praiz").
5. Grammar rules, Conjugation headers, Explanations, Meanings, and Quiz Questions/Hints must be written strictly in {app_ui_language}. Their corresponding examples/answers must be in {target_language}.
6. CRITICAL: You MUST extract at least 1 pronoun from the source text.

QUIZ RULES (STRICTLY ENFORCED):
7. You MUST generate EXACTLY 5 quiz questions. No fewer, no more.
8. ANSWER LEAKING IS FORBIDDEN: The correct answer word or phrase must NEVER appear anywhere in the question text. For example, if the answer is "overwhelming", the question must NOT contain the word "overwhelming".
9. Each question MUST test a DIFFERENT concept. Use these 5 unique question types — one of each:
   - Type 1: "What is the meaning of [word in {target_language}]?" (Vocabulary meaning)
   - Type 2: "Which grammatical form is used in this sentence: [sentence]?" (Grammar identification)
   - Type 3: "Complete the sentence: [sentence with blank]" (Fill in the blank)
   - Type 4: "Based on the context, what does the speaker mean by [phrase]?" (Contextual understanding)
   - Type 5: "What is the correct conjugation of [verb] in [tense]?" (Conjugation/verb form)
10. All 4 answer choices (1 correct + 3 wrong) MUST be completely unique — no duplicates, no near-duplicates, and no overlap with the question text.
11. Wrong answers must be plausible and from the same category as the correct answer (e.g., if the correct answer is a verb, wrong answers should also be verbs).
12. Questions must be intelligently crafted to test real understanding, not just pattern matching.
"""

    user_prompt = f"""Here is the transcript to analyze:

FULL TEXT:
{transcript_text}

Generate the educational lesson JSON now."""

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        response_format={"type": "json_object"},
        temperature=0.7,
        max_tokens=5000,
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
        "quiz": result.get("quiz", []),
        "pronouns": result.get("pronouns", []),
    }
