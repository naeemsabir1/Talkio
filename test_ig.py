import httpx

def test_endpoint(base_url):
    print(f"Testing {base_url} ...")
    url = "https://www.instagram.com/p/C-vT6H9v3lZ/"
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    }
    payload = {"url": url}
    try:
        resp = httpx.post(base_url, headers=headers, json=payload, timeout=15.0)
        print(resp.status_code)
        print(resp.text)
        if resp.status_code == 200 and "url" in resp.json():
            print("SUCCESS!\n")
            return base_url
    except Exception as e:
        print(f"Failed: {e}\n")
    return None

if __name__ == "__main__":
    endpoints = [
        "https://cobalt.cibere.dev/",
        "https://cobalt.qewertyy.dev/",
        "https://api.cobalt.acjosh.com/",
        "https://cobalt.tu.fo/",
        "https://cobalt.kwiatekm.dev/"
    ]
    working = None
    for ep in endpoints:
        res = test_endpoint(ep)
        if res:
            working = res
            break
    if working:
        print(f"Found working: {working}")
