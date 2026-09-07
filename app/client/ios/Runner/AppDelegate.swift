//import UIKit
//import FirebaseCore
//import flutter_local_notifications
//import FBSDKCoreKit
//import Flutter
//
//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//    private let channelName = "ink.itapp2u.com/fb_events"
//
//    func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//
//        ApplicationDelegate.shared.application(
//            application,
//            didFinishLaunchingWithOptions: launchOptions
//        )
//
//            return true
//    }
//
//    func application(
//        _ app: UIApplication,
//        open url: URL,
//        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
//    ) -> Bool {
//
//        FirebaseApp.configure()
//        GeneratedPluginRegistrant.register(with: self)
//
//
//        ApplicationDelegate.shared.application(
//            app,
//            open: url,
//            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
//        )
//
//        guard let controller = window?.rootViewController as? FlutterViewController else {
//            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//        }
//
//        let channel = FlutterMethodChannel(name: channelName,binaryMessenger: controller.binaryMessenger)
//        channel.setMethodCallHandler({
//            (call: FlutterMethodCall , result:@escaping FlutterResult) -> Void in
//            if call.method == "logEvent" {
//                print("logEvent called");
//                result(self.handleLogEvent(call,result:@escaping result))
////            }else if call.method == "handlePurchase" {
////                result(self.handlePurchased(call,result:@escaping result))
//            }else{
//                result(FlutterMethodNotImplemented)
//            }
//        })
//
//        if #available(iOS 10.0, *) {
//            application.applicationIconBadgeNumber = 0
//            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//            application.registerForRemoteNotifications()
//        }
//
//        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
////    }
//    }
//
//
//
//    private func handleLogEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
//
//        //                 guard let arguments = call.arguments as? [String: Any] else {
//        //                     result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected a map", details: nil))
//        //                     return
//        //                 }
//        let name = arguments["name"] as! String
//        //                 let amount = arguments["amount"] as! Double
//        //                 let currency = arguments["currency"] as! String
//        //                 let parameters = arguments["parameters"] as? [AppEvents.ParameterName: Any] ?? [AppEvents.ParameterName: Any]()
//        //                 AppEvents.shared.logPurchase(amount: amount, currency: currency, parameters: parameters)
//
//        AppEvents.shared.logEvent(AppEvents.Name(name))
//
//        result(nil)
//    }
    
    /*
     
     @UIApplicationMain
     @objc class AppDelegate: FlutterAppDelegate {
     private let channelName = "ink.itapp2u.com/fb_events"
     override func application(
     _ application: UIApplication,
     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
     FirebaseApp.configure()
     GeneratedPluginRegistrant.register(with: self)
     
     //Native Code Start
     guard let controller = window?.rootViewController as? FlutterViewController else {
     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
     
     let channel = FlutterMethodChannel(name: channelName,binaryMessenger: controller.binaryMessenger)
     channel.setMethodCallHandler({
     (call: FlutterMethodCall , result:@escaping FlutterResult) -> Void in
     if call.method == "logEvent" {
     result(self.handleLogEvent(call,result:@escaping result))
     }else if call.method == "handlePurchase" {
     result(self.handlePurchased(call,result:@escaping result))
     }else{
     result(FlutterMethodNotImplemented)
     }
     })
     
     if #available(iOS 10.0, *) {
     application.applicationIconBadgeNumber = 0
     UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
     application.registerForRemoteNotifications()
     }
     
     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
     
     
     //  flutter
     
     private func handleSetAutoLogAppEventsEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
     let enabled = call.arguments as! Bool
     Settings.shared.isAutoLogAppEventsEnabled = enabled
     result(nil)
     }
     
     private func handlePurchased(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
     //          let arguments = call.arguments as? [String: Any] ?? [String: Any]()
     
     guard let arguments = call.arguments as? [String: Any] else {
     result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected a map", details: nil))
     return
     }
     let amount = arguments["amount"] as! Double
     let currency = arguments["currency"] as! String
     let parameters = arguments["parameters"] as? [AppEvents.ParameterName: Any] ?? [AppEvents.ParameterName: Any]()
     AppEvents.shared.logPurchase(amount: amount, currency: currency, parameters: parameters)
     
     result(nil)
     }
     }
     
     */
    
     import UIKit
     import Flutter
     import FirebaseCore
     import flutter_local_notifications
     
     @UIApplicationMain
     @objc class AppDelegate: FlutterAppDelegate {
     override func application(
     _ application: UIApplication,
     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
     FirebaseApp.configure()
     GeneratedPluginRegistrant.register(with: self)
     
     if #available(iOS 10.0, *) {
     application.applicationIconBadgeNumber = 0
     UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
     application.registerForRemoteNotifications()
     }
     
     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
//     } 
}
