import urllib.request
import json
import urllib.error

url = "http://127.0.0.1:8000/api/process"
data = json.dumps({
    "url": "https://www.instagram.com/reel/C2_rT_TNY89/?igsh=MWF5MzhlZDRjZg==",
    "language": "auto",
    "target_language": "English"
}).encode("utf-8")

req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})

try:
    with urllib.request.urlopen(req) as response:
        print(response.read().decode())
except urllib.error.HTTPError as e:
    print(f"HTTP Error {e.code}: {e.read().decode()}")
except Exception as e:
    print(f"Error: {e}")
