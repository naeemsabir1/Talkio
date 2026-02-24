# Share Extension Testing Guide

## 🧪 Testing with TestSprite MCP

### ⚠️ First: Connect TestSprite MCP

TestSprite MCP server needs to be connected to your IDE first.

**Steps:**
1. Copy the configuration from [`.testsprite/mcp-config.json`](file:///c:/Users/naeem/Documents/Websites/IOS%20APP%20(Audio%20APP%20Like%20Auraly)/.testsprite/mcp-config.json)
2. Add it to your IDE's MCP Servers settings
3. Restart your IDE
4. TestSprite tools will then be available

---

## 📋 Manual Testing (Do This First!)

While setting up TestSprite, you can manually test everything:

### Test 1: Unit Tests (Automated)

Run the unit tests I created:

```bash
cd "c:\Users\naeem\Documents\Websites\IOS APP (Audio APP Like Auraly)"
flutter test test/share_extension_test.dart
```

**What it tests:**
- ✅ Memo creation from URLs
- ✅ Platform detection (Instagram/YouTube/TikTok)
- ✅ Unique ID generation
- ✅ Memo persistence in provider
- ✅ Mock data completeness
- ✅ Processing delay timing

### Test 2: Integration Test on Device

**Prerequisites:**
```bash
# Install app on device
flutter run -d <device-id>
```

**Test Scenarios:**

#### Scenario A: Instagram Share
1. Open Instagram app
2. Find any post
3. Tap **Share** → Select **auraly_clone**
4. **Expected:**
   - Language selection sheet appears
   - Select "English"
   - Processing screen shows (3 seconds)
   - Memo detail opens with Instagram icon
   - Press back
   - ✅ **Memo appears in Recent Memos with Instagram icon**

#### Scenario B: YouTube Share
1. Open YouTube app
2. Find any video
3. Tap **Share** → Select **auraly_clone**
4. **Expected:**
   - Same flow as Instagram
   - ✅ **YouTube icon displayed**

#### Scenario C: TikTok Share
1. Open TikTok app
2. Find any video
3. Tap **Share** → Select **auraly_clone**
4. **Expected:**
   - Same flow as Instagram
   - ✅ **TikTok icon displayed**

#### Scenario D: Multiple Shares
1. Share from Instagram (complete flow)
2. Immediately share from YouTube (complete flow)
3. Share from TikTok (complete flow)
4. **Expected:**
   - ✅ **All 3 memos appear in Recent Memos**
   - ✅ **Newest memo at top**
   - ✅ **Each has correct platform icon**

#### Scenario E: Cold Start
1. Close the app completely (swipe away from recent apps)
2. Open Instagram and share a post to the app
3. **Expected:**
   - ✅ **App launches from closed state**
   - ✅ **Language sheet appears**
   - ✅ **Flow completes successfully**

### Test 3: Performance Testing

**Image Loading:**
1. Open a memo detail screen
2. Observe image loading time
3. **Expected:**
   - ✅ Loading indicator appears
   - ✅ Image loads within 1 second
   - ✅ No layout shift

**List Scrolling:**
1. Create 5-10 memos via sharing
2. Scroll rapidly through the list
3. **Expected:**
   - ✅ Smooth 60fps scrolling
   - ✅ No stuttering
   - ✅ Thumbnails load progressively

---

## 🤖 Automated Testing with TestSprite (After Connection)

Once TestSprite MCP is connected, you can use it to:

### 1. Create Automated UI Tests

```bash
# TestSprite will provide tools to:
- Record user interactions
- Generate test scripts
- Run regression tests
- Generate test reports
```

### 2. Performance Benchmarking

TestSprite can measure:
- App launch time
- Screen transition speed
- Image loading performance
- Memory usage
- Frame rate during scrolling

### 3. Visual Regression Testing

TestSprite can:
- Capture screenshots of key screens
- Compare against baseline images
- Detect UI regressions
- Report visual differences

---

## 📊 Test Checklist

### Functional Tests
- [ ] Share from Instagram works
- [ ] Share from YouTube works
- [ ] Share from TikTok works
- [ ] Platform icons correct
- [ ] Memos persist in list
- [ ] Multiple shares work
- [ ] Cold start works
- [ ] Language selection works
- [ ] Processing animation displays
- [ ] Memo detail shows all data

### Performance Tests
- [ ] Images load < 1 second
- [ ] List scrolls at 60fps
- [ ] No memory leaks
- [ ] App responds immediately

### Edge Cases
- [ ] Share with invalid URL
- [ ] Share while app minimized
- [ ] Share with no internet
- [ ] Share multiple times rapidly
- [ ] Navigate back during processing

---

## 🐛 Known Issues to Test For

1. **Memo Persistence** ✅ FIXED
   - Previous issue: Memos not saved
   - Test: Share → Back → Check Recent Memos
   - Expected: Memo appears

2. **Platform Detection** ✅ IMPLEMENTED
   - Test: Share from each platform
   - Expected: Correct icon displayed

3. **Unique IDs** ✅ IMPLEMENTED
   - Test: Share same link twice
   - Expected: Two separate memos with different IDs

---

## 📝 Test Results Template

Use this template to document your testing:

```
## Test Run: [Date]
**Device**: [Device Name]
**OS Version**: [Android/iOS Version]
**App Version**: [Version Number]

### Functional Tests
- Instagram Share: ✅ / ❌
- YouTube Share: ✅ / ❌
- TikTok Share: ✅ / ❌
- Memo Persistence: ✅ / ❌
- Platform Detection: ✅ / ❌

### Performance Tests
- Image Load Time: [X]ms
- Scroll Performance: [X]fps
- Memory Usage: [X]MB

### Issues Found
1. [Description]
2. [Description]

### Screenshots
[Attach screenshots if needed]
```

---

## 🚀 Quick Start

**Right Now (No TestSprite needed):**
```bash
# Run unit tests
flutter test test/share_extension_test.dart

# Run app on device
flutter run -d <device-id>

# Test manually using scenarios above
```

**After TestSprite Connected:**
- Use TestSprite tools for automated testing
- Generate comprehensive test reports
- Set up CI/CD test automation

---

## 📞 Support

If you encounter issues:
1. Check unit test results first
2. Review error messages in console
3. Verify Android/iOS logs
4. Document steps to reproduce
5. Share findings with development team

Happy Testing! 🎉
