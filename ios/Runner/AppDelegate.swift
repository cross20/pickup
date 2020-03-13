import UIKit
import Flutter
import "GoogleMaps/GoogleMaps.h" //for Google Maps API

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices provideAPIKey: @"AIzaSyBn1RcsGnYTNiNUGfqWEtRZeRMNBdzoOrw" //for Google Maps API
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
