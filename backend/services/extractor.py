"""
Auraly Backend - Content Extraction Service
Uses yt-dlp to extract audio and metadata from Instagram/TikTok/YouTube URLs.
"""

import os
import uuid
import subprocess
import json
import re
from pathlib import Path
import httpx


TEMP_DIR = Path(__file__).parent.parent / "temp"
TEMP_DIR.mkdir(exist_ok=True)


def detect_platform(url: str) -> str:
    """Detect social media platform from URL."""
    url_lower = url.lower()
    if "youtube.com" in url_lower or "youtu.be" in url_lower:
        return "YouTube"
    elif "tiktok.com" in url_lower:
        return "TikTok"
    elif "instagram.com" in url_lower:
        return "Instagram"
    else:
        return "Unknown"


def validate_url(url: str) -> bool:
    """Check if URL is from a supported platform."""
    supported = ["youtube.com", "youtu.be", "tiktok.com", "instagram.com"]
    return any(domain in url.lower() for domain in supported)


def extract_audio(url: str) -> dict:
    """
    Extract audio (MP3) and metadata from a social media URL.
    
    Returns:
        dict with keys: audio_path, thumbnail_url, title, platform
    
    Raises:
        ValueError: If URL is invalid or video is unavailable
        RuntimeError: If extraction fails
    """
    # ────────────────────────────────────────────────────────────
    # Step 0: Extract the actual URL if text contains extra words 
    # (e.g., from an iOS/Android share intent)
    # ────────────────────────────────────────────────────────────
    url_match = re.search(r"https?://[^\s]+", url)
    if url_match:
        url = url_match.group(0).strip(".,;!?()[]{}'\"")
        # Strip tracking parameters to reduce bot flags
        url = re.sub(r'([?&])si=[^&]+(&|$)', r'\1', url).rstrip('?&')
    else:
        raise ValueError("No valid URL found in the provided text.")

    if not validate_url(url):
        raise ValueError(
            "Unsupported URL. Please share a valid Instagram, TikTok, or YouTube link."
        )

    platform = detect_platform(url)
    request_id = str(uuid.uuid4())[:8]
    audio_filename = f"{request_id}.mp3"
    audio_path = TEMP_DIR / audio_filename
    info_path = TEMP_DIR / f"{request_id}_info.json"

    # ────────────────────────────────────────────────────────────
    # Step 0.5: TikTok Direct API Bypass
    if platform == "TikTok":
        try:
            api_url = f"https://www.tikwm.com/api/?url={url}"
            resp = httpx.get(api_url, timeout=30.0)
            resp.raise_for_status()
            data = resp.json()
            
            if data.get("code") != 0 or "data" not in data:
                raise ValueError("TikWM API returned an error or no data. Please try another TikTok video.")
                
            video_data = data["data"]
            title = video_data.get("title", "TikTok Video")
            thumbnail_url = video_data.get("cover", "")
            
            # Extract the direct audio or video play link
            audio_url = video_data.get("music") or video_data.get("play")
            if not audio_url:
                raise ValueError("Could not extract audio link from TikTok response.")
                
            # Download the raw media file
            audio_resp = httpx.get(audio_url, timeout=60.0)
            audio_resp.raise_for_status()
            
            with open(audio_path, "wb") as f:
                f.write(audio_resp.content)
            
            # Check file size (Whisper limit = 25MB)
            file_size_mb = os.path.getsize(audio_path) / (1024 * 1024)
            if file_size_mb > 25:
                cleanup_temp(request_id)
                raise ValueError("Video is too long (audio > 25MB). Try a shorter clip.")

            return {
                "audio_path": str(audio_path),
                "thumbnail_url": thumbnail_url,
                "title": title,
                "platform": platform,
                "request_id": request_id,
            }
        except httpx.RequestError as e:
            cleanup_temp(request_id)
            raise RuntimeError(f"Failed to reach TikWM API: {e}")
        except Exception as e:
            cleanup_temp(request_id)
            if isinstance(e, ValueError):
                raise
            raise RuntimeError(f"TikTok extraction failed: {e}")

    # ────────────────────────────────────────────────────────────
    # Step 0.6: Instagram Cobalt API Bypass
    # ────────────────────────────────────────────────────────────
    elif platform == "Instagram":
        cobalt_instances = [
            "https://cobalt.canine.tools/",
            "https://api.cobalt.best/",
            "https://co.rooot.gay/",
            "https://cobalt.api.timelessnesses.me/",
            "https://co.wuk.sh/"
        ]

        headers = {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        }
        payload = {"url": url}

        audio_url = None
        
        for cobalt_api_url in cobalt_instances:
            try:
                resp = httpx.post(cobalt_api_url, headers=headers, json=payload, timeout=30.0)
                resp.raise_for_status()
                data = resp.json()
                
                if data.get("status") == "error" or "url" not in data:
                    print(f"Instance {cobalt_api_url} failed (API error or no URL), trying next...")
                    continue
                    
                audio_url = data["url"]
                break  # Success! Loop breaks and proceed to download
                
            except httpx.HTTPStatusError as e:
                if e.response.status_code >= 400:
                    print(f"Instance {cobalt_api_url} failed with HTTP {e.response.status_code}, trying next...")
                    continue
                print(f"Instance {cobalt_api_url} failed, trying next...")
                continue
            except (httpx.RequestError, ConnectionError) as e:
                print(f"Instance {cobalt_api_url} failed with request/connection error, trying next...")
                continue
            except Exception as e:
                print(f"Instance {cobalt_api_url} failed unexpectedly: {e}, trying next...")
                continue

        if not audio_url:
            cleanup_temp(request_id)
            raise RuntimeError("All Cobalt instances failed to extract the media. Please try again later.")

        try:
            title = "Instagram Video"
            thumbnail_url = "" # Cobalt doesn't always provide one reliably in the simple response
            
            # Download the raw media file
            audio_resp = httpx.get(audio_url, timeout=60.0)
            audio_resp.raise_for_status()
            
            with open(audio_path, "wb") as f:
                f.write(audio_resp.content)
            
            # Check file size (Whisper limit = 25MB)
            file_size_mb = os.path.getsize(audio_path) / (1024 * 1024)
            if file_size_mb > 25:
                cleanup_temp(request_id)
                raise ValueError("Video is too long (audio > 25MB). Try a shorter clip.")

            return {
                "audio_path": str(audio_path),
                "thumbnail_url": thumbnail_url,
                "title": title,
                "platform": platform,
                "request_id": request_id,
            }
        except Exception as e:
            cleanup_temp(request_id)
            if isinstance(e, ValueError):
                raise
            raise RuntimeError(f"Instagram extraction failed during download: {e}")

    # ────────────────────────────────────────────────────────────
    # Step 1: Fetch metadata (title, thumbnail) without downloading
    # ────────────────────────────────────────────────────────────
    info_cmd = [
        "yt-dlp",
        "--dump-json",
        "--no-download",
        "--no-warnings",
        "--extractor-args", "youtube:player-client=web_embedded,web,tv",
        url,
    ]

    title = "Untitled"
    thumbnail_url = ""

    try:
        result = subprocess.run(
            info_cmd,
            capture_output=True,
            text=True,
            timeout=60,
        )
        if result.returncode == 0 and result.stdout.strip():
            info = json.loads(result.stdout.strip().split("\n")[0])
            title = info.get("title", "Untitled")
            thumbnail_url = info.get("thumbnail", "")
            # Try to get the best thumbnail
            thumbnails = info.get("thumbnails", [])
            if thumbnails:
                # Pick the highest resolution thumbnail
                best = max(thumbnails, key=lambda t: t.get("height", 0) or 0)
                thumbnail_url = best.get("url", thumbnail_url)
    except (subprocess.TimeoutExpired, json.JSONDecodeError, Exception) as e:
        print(f"⚠️  Warning: Could not fetch metadata: {e}")

    # ────────────────────────────────────────────────────────────
    # Step 2: Download audio only as MP3
    # ────────────────────────────────────────────────────────────
    download_cmd = [
        "yt-dlp",
        "-x",                          # Extract audio
        "--audio-format", "mp3",       # Convert to MP3
        "--audio-quality", "5",        # Medium quality (smaller file)
        "-o", str(audio_path),         # Output path
        "--no-playlist",               # Single video only
        "--no-warnings",
        "--extractor-args", "youtube:player-client=web_embedded,web,tv",
        "--max-filesize", "25m",       # Whisper API limit
    ]

    # Platform-specific options for anti-scraping
    # (Instagram is now handled by Cobalt, so this is mostly for YouTube fallback if needed)
    if platform == "Instagram":
        download_cmd.extend([
            "--add-header", "User-Agent:Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X)",
        ])

    download_cmd.append(url)

    try:
        result = subprocess.run(
            download_cmd,
            capture_output=True,
            text=True,
            timeout=120,
        )
    except subprocess.TimeoutExpired:
        cleanup_temp(request_id)
        raise RuntimeError("Download timed out. The video may be too long or the server is slow.")

    if result.returncode != 0:
        error_msg = result.stderr.lower() if result.stderr else ""
        cleanup_temp(request_id)

        if "private" in error_msg or "login" in error_msg:
            raise ValueError("This video is private or requires login. Please share a public video.")
        elif "not found" in error_msg or "unavailable" in error_msg or "404" in error_msg:
            raise ValueError("This video was not found or has been deleted.")
        elif "no video" in error_msg or "no audio" in error_msg:
            raise ValueError("Could not extract audio from this video.")
        else:
            raise RuntimeError(f"Failed to download video: {result.stderr[:200] if result.stderr else 'Unknown error'}")

    # yt-dlp might add an extension suffix — find the actual file
    actual_path = _find_audio_file(TEMP_DIR, request_id)
    if actual_path is None:
        cleanup_temp(request_id)
        raise RuntimeError("Audio extraction completed but output file was not found.")

    # Check file size (Whisper limit = 25MB)
    file_size_mb = os.path.getsize(actual_path) / (1024 * 1024)
    if file_size_mb > 25:
        cleanup_temp(request_id)
        raise ValueError("Video is too long (audio > 25MB). Try a shorter clip.")

    return {
        "audio_path": str(actual_path),
        "thumbnail_url": thumbnail_url,
        "title": title,
        "platform": platform,
        "request_id": request_id,
    }


def _find_audio_file(directory: Path, prefix: str) -> Path | None:
    """Find the downloaded audio file (yt-dlp may add suffixes)."""
    for ext in [".mp3", ".m4a", ".wav", ".opus", ".webm"]:
        candidate = directory / f"{prefix}{ext}"
        if candidate.exists():
            return candidate
    # Fallback: search by prefix
    for f in directory.iterdir():
        if f.name.startswith(prefix) and f.is_file():
            return f
    return None


def cleanup_temp(request_id: str):
    """Remove temporary files for a given request."""
    for f in TEMP_DIR.iterdir():
        if f.name.startswith(request_id):
            try:
                f.unlink()
            except OSError:
                pass
