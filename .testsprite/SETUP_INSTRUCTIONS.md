# TestSprite MCP Setup Instructions

## 🧪 TestSprite Configuration

TestSprite MCP has been configured with your API key and is ready to use for automated testing of the share extension functionality!

---

## 📋 Configuration File

The MCP configuration is located at:
[`mcp-config.json`](file:///c:/Users/naeem/Documents/Websites/IOS%20APP%20(Audio%20APP%20Like%20Auraly)/.testsprite/mcp-config.json)

---

## 🚀 How to Add to Your IDE/Environment

### Option 1: For Gemini Desktop / Antigravity

1. Open your IDE settings
2. Navigate to **MCP Servers** configuration
3. Add the TestSprite server using the configuration above
4. The server will use `npx` to run `@testsprite/testsprite-mcp@latest`

### Option 2: Manual Integration

If you're using a different MCP-compatible tool:

1. Copy the contents of `mcp-config.json`
2. Add it to your tool's MCP servers configuration
3. Restart the tool to load the new server

---

## 🧪 What You Can Test with TestSprite

### Share Extension Testing Scenarios

1. **Share Intent Flow**
   - Test share from Instagram/TikTok/YouTube
   - Verify language selection appears
   - Confirm processing animation
   - Check memo detail display
   - **Verify memo persists in Recent Memos** ✅

2. **Platform Detection**
   - Share YouTube URL → verify YouTube icon
   - Share Instagram URL → verify Instagram icon
   - Share TikTok URL → verify TikTok icon

3. **Performance Testing**
   - Image loading speed
   - List scrolling performance
   - Memory usage during shares

4. **Edge Cases**
   - Share multiple items in succession
   - Share with app in background
   - Share with app closed (cold start)

---

## 📱 Testing on Real Devices

### Android Testing
```bash
# Connect your Android device via USB
flutter devices

# Run the app
flutter run -d <device-id>

# Share from any app to test
```

### iOS Testing (After Xcode Setup)
```bash
# Run on iOS device
flutter run -d <device-id>

# Complete manual Xcode setup first
# See: ios/IOS_SHARE_SETUP.md
```

---

## ✅ What's Already Working

- ✅ Share intent handling (Android)
- ✅ Memo persistence fix implemented
- ✅ Platform auto-detection
- ✅ Performance optimizations
- ✅ Mock data integration

---

## 🔧 Troubleshooting

### If TestSprite doesn't connect:

1. **Install dependencies**:
   ```bash
   npm install -g @testsprite/testsprite-mcp@latest
   ```

2. **Verify npx works**:
   ```bash
   npx @testsprite/testsprite-mcp@latest --version
   ```

3. **Check API key** is correctly set in environment

---

## 📚 Next Steps

1. Add TestSprite MCP to your IDE
2. Start testing the share extension
3. Use TestSprite to automate regression tests
4. Document test results

The share extension is ready for comprehensive testing! 🎉
