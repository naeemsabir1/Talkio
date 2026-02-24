import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var sharedText: String?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // Create MethodChannel for share intent
    let shareChannel = FlutterMethodChannel(name: "com.auraly.share/data",
                                           binaryMessenger: controller.binaryMessenger)
    
    shareChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getInitialContent" {
        result(self?.sharedText)
        self?.sharedText = nil
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    // Create EventChannel for streaming share intents
    let eventChannel = FlutterEventChannel(name: "com.auraly.share/events",
                                          binaryMessenger: controller.binaryMessenger)
    eventChannel.setStreamHandler(ShareStreamHandler.shared)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle URL scheme from share sheet
  override func application(_ app: UIApplication,
                          open url: URL,
                          options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if url.scheme == "auraly" {
      if url.host == "share",
         let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
         let queryItems = components.queryItems,
         let sharedURL = queryItems.first(where: { $0.name == "url" })?.value {
        
        // Store shared URL and notify Flutter
        sharedText = sharedURL
        ShareStreamHandler.shared.sendEvent(sharedURL)
      }
    }
    return true
  }
  
  // Handle user activity (alternative to URL scheme)
  override func application(_ application: UIApplication,
                          continue userActivity: NSUserActivity,
                          restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL {
      sharedText = url.absoluteString
      ShareStreamHandler.shared.sendEvent(url.absoluteString)
      return true
    }
    return false
  }
}

// Stream handler for share events
class ShareStreamHandler: NSObject, FlutterStreamHandler {
  static let shared = ShareStreamHandler()
  private var eventSink: FlutterEventSink?
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
  
  func sendEvent(_ text: String) {
    eventSink?(text)
  }
}
