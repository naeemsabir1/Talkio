from services.extractor import extract_audio

try:
    print("Testing YouTube extraction...")
    res = extract_audio("https://youtube.com/shorts/3nOqH5gXvV0?feature=share")
    print(res)
except Exception as e:
    print(f"Error: {e}")
