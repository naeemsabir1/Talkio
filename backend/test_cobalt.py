import urllib.request
import json
import urllib.error

url = "https://api.cobalt.tools/api/json"
data = json.dumps({
    "url": "https://www.instagram.com/reel/C2_rT_TNY89/",
    "vCodec": "h264",
    "vQuality": "360",
    "aFormat": "mp3",
    "isAudioOnly": True
}).encode("utf-8")

req = urllib.request.Request(url, data=data, headers={
    "Accept": "application/json",
    "Content-Type": "application/json",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
})

try:
    with urllib.request.urlopen(req) as response:
        print(response.read().decode())
except urllib.error.HTTPError as e:
    print(f"HTTP Error {e.code}: {e.read().decode()}")
except Exception as e:
    print(f"Error: {e}")
