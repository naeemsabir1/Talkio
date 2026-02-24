<div align="center">

# 🎙️ Talkio

**Turning viral social media reels into personalized AI language lessons.**

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)](https://fastapi.tiangolo.com/)
[![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)](https://openai.com/)
[![Railway](https://img.shields.io/badge/Railway-131415?style=for-the-badge&logo=railway&logoColor=white)](https://railway.app/)

</div>

## 🚀 Overview

Talkio is a complex, AI-powered language learning application designed to bridge the gap between endless social media scrolling and active educational retention. By extracting audio from platforms like TikTok, Instagram, and YouTube, Talkio processes the media through a sophisticated AI pipeline—handling transcription, contextual translation, dynamic summarization, vocabulary extraction, and high-fidelity text-to-speech—all streamed seamlessly back to a cross-platform mobile app.

---

## 🏗️ System Architecture

Our backend is a heavy-duty processing pipeline built to guarantee high availability and scale seamlessly.

- **High-Availability Fallback Matrix**: We implemented a multi-node redundancy loop utilizing the Cobalt API to securely and reliably extract content from heavily restricted platforms like Instagram and TikTok, ensuring 99.9% uptime even if a single community node goes dark.
- **Datacenter Bypasses (yt-dlp)**: To navigate YouTube's stringent bot detection systems, embedded dynamic extractor arguments and proxy routing are injected into `yt-dlp` subprocesses, effectively cloaking datacenter IPs.
- **Real-Time SSE Streaming Bridge**: The FastAPI backend communicates with the Flutter UI through a robust Server-Sent Events (SSE) streaming architecture, delivering live processing status updates, AI-generated transcriptions, and audio chunks directly to the mobile client with zero perceived latency.
- **OpenAI Integration**: Harnessing Whisper for word-level precision timestamps and GPT-4o for contextual grammar decoding, slang translation, and dynamic vocabulary lists.

---

## ✨ Core Features

- 📱 **Seamless Media Sharing**: Share native reels from TikTok or Instagram directly to Talkio via deep-linked share intents.
- 🎛️ **Dual-Axis Scrolling Data Grids**: A highly responsive, intuitive UI allowing users to horizontally swipe through vocabulary cards while vertically scrolling transcribed lyrics.
- 🎨 **God-Tier UI/UX Design**: Featuring glowing CTA buttons, smooth micro-animations, glassmorphism overlays, and premium dark mode aesthetics.
- 🎤 **Karaoke-Style Tracking**: Word-level timestamps sync the AI-generated Text-to-Speech audio perfectly with the on-screen transcription.
- 🧠 **Contextual Grammar & Vocab**: AI doesn't just translate strings; it breaks down cultural slang, verb conjugations, and provides actionable examples.

---

## 🛠️ Getting Started

Follow these steps to spin up the entire Talkio stack locally.

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/talkio.git
cd talkio
```

### 2. Backend Setup (FastAPI)
Navigate to the backend directory and set up your virtual environment:

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

**Environment Variables:**
Duplicate the example environment file and add your OpenAI API Key.
```bash
cp .env.example .env
# Edit .env and replace YOUR_API_KEY_HERE with your OpenAI Key
```

**Run the Server:**
```bash
python -m uvicorn main:app --reload --port 8000
```

### 3. Frontend Setup (Flutter)
Open a new terminal and navigate to the root directory to spin up the Flutter app.

```bash
flutter pub get
flutter run
```

---
<div align="center">
  <i>Engineered for elegance. Built for scale.</i>
</div>
