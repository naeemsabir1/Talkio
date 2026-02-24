# iOS Share Extension Setup Guide

## ⚠️ IMPORTANT: Manual XCode Configuration Required

The iOS share extension requires creating a **Share Extension Target** in Xcode. This cannot be automated via Flutter and must be done manually.

## Steps to Complete iOS Setup:

### 1. Open XCode
```bash
cd "c:\Users\naeem\Documents\Websites\IOS APP (Audio APP Like Auraly)\ios"
open Runner.xcworkspace
```

### 2. Create Share Extension Target
1. In Xcode, go to **File → New → Target**
2. Select **iOS → Share Extension**
3. Name it: `ShareExtension`
4. Language: Swift
5. Click **Finish**
6. When prompted "Activate scheme?", click **Activate**

### 3. Configure Share Extension
1. Select the `ShareExtension` folder in Project Navigator
2. Replace `ShareViewController.swift` with:

```swift
import UIKit
import Social

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        extractSharedURL()
    }
    
    private func extractSharedURL() {
        let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem
        let itemProvider = extensionItem?.attachments?.first
        
        if let itemProvider = itemProvider {
            if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
                    if let shareURL = url as? URL {
                        self.openMainApp(with: shareURL.absoluteString)
                    }
                }
            } else if itemProvider.hasItemConformingToTypeIdentifier("public.text") {
                itemProvider.loadItem(forTypeIdentifier: "public.text", options: nil) { (text, error) in
                    if let shareText = text as? String {
                        self.openMainApp(with: shareText)
                    }
                }
            }
        }
    }
    
    private func openMainApp(with url: String) {
        let urlScheme = "auraly://share?url=\(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let appURL = URL(string: urlScheme) {
            // Redirect to main app
            var responder: UIResponder? = self
            while responder != nil {
                if let application = responder as? UIApplication {
                    application.perform(#selector(openURL(_:)), with: appURL)
                    break
                }
                responder = responder?.next
            }
        }
        
        // Close share extension
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
```

3. Open `ShareExtension/Info.plist` and ensure it has:
```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>NSExtensionActivationRule</key>
        <dict>
            <key>NSExtensionActivationSupportsText</key>
            <true/>
            <key>NSExtensionActivationSupportsWebURLWithMaxCount</key>
            <integer>1</integer>
        </dict>
    </dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.share-services</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).ShareViewController</string>
</dict>
```

### 4. Configure App Groups (for sharing data)
1. Select **Runner** target → **Signing & Capabilities**
2. Click **+ Capability** → Add **App Groups**
3. Create group: `group.com.auraly.share`
4. Repeat for **ShareExtension** target

### 5. Test on Physical Device
```bash
flutter build ios
flutter install
```

Then:
1. Open Safari or Instagram on iOS
2. Share a URL
3. Select "Auraly Clone" from share sheet
4. App should open with language selection

## Current Status

✅ **Completed**:
- AppDelegate.swift updated with share handling
- Info.plist configured with URL schemes
- Share service already handles iOS channels

⚠️ **Requires Manual Setup**:
- Creating Share Extension Target in Xcode
- Configuring ShareViewController.swift
- Setting up App Groups

The Android share functionality is fully working. iOS will work once the manual XCode steps are completed.
