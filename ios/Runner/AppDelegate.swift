import UIKit
import Flutter
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    let userDefaults = UserDefaults.standard

if !userDefaults.bool(forKey: "hasRunBefore") {
     // Remove Keychain items here

     // Update the flag indicator
     userDefaults.set(true, forKey: "hasRunBefore")
}
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
