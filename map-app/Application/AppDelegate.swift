//
//  AppDelegate.swift
//  map-app
//
//  Created by Admin on 10/28/21.
//
import UIKit
import FirebaseCore
import FirebaseMessaging
import IQKeyboardManagerSwift
import SwiftMessages
import UserNotifications
import GoogleMaps

var thisuser: UserModel!

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        thisuser = UserModel()
        thisuser.loadUserInfo()
        thisuser.saveUserInfo()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        // push settings
        FirebaseApp.configure()
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        registerForPushNotifications()
        // google map setting
        GMSServices.provideAPIKey("AIzaSyDigbXIHJ2q5mQnubsKz4dxLek8heVX69c")
        
        return true
    }
    
    // MARK: -   set push notifations

    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge] // [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { granted, _ in
                if granted {
                    print("Permission granted: \(granted)")
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            })
            Messaging.messaging().delegate = self
            // Messaging.messaging().shouldEstablishDirectChannel = true
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    
    func getRegisteredPushNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                print("The user agrees to receive notifications.")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            case .denied:
                print("Permission denied.")
            // The user has not given permission. Maybe you can display a message remembering why permission is required.
            case .notDetermined:
                print("The permission has not been determined, you can ask the user.")
                self.getRegisteredPushNotifications()
            default:
                return
            }
        })
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != [] {
            application.registerForRemoteNotifications()
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for notifications!")
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""

        for i in 0 ..< deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        let aps = userInfo["aps"] as? [AnyHashable: Any]
        let badgeCount = aps!["badge"] as? Int ?? 0
        UIApplication.shared.applicationIconBadgeNumber = badgeCount

        let alertMessage = aps!["alert"] as? [AnyHashable: Any]
        if let alertMessage = alertMessage {
            let bodyMessage = alertMessage["body"] as? String
            let titleMessage = alertMessage["title"] as? String
            if let bodyMessage = bodyMessage, let titleMessage = titleMessage {
                print(titleMessage)
                print(bodyMessage)

                let view: MessageView
                view = try! SwiftMessages.viewFromNib()
                let icon = UIImage(named: "ic_logo")!.resize(toTargetSize: CGSize(width: 40, height: 40)).withRoundedCorners(radius: 5)

                view.configureContent(title: titleMessage, body: bodyMessage, iconImage: icon, iconText: nil, buttonImage: nil, buttonTitle: "OK", buttonTapHandler: { _ in
                    SwiftMessages.hide()
                    // UIApplication.shared.applicationIconBadgeNumber -= 1
                })
                view.configureTheme(backgroundColor: .blue, foregroundColor: UIColor.white, iconImage: icon, iconText: nil)
                view.button?.setTitle("OK", for: .normal)
                view.button?.backgroundColor = UIColor.white
                view.button?.tintColor = .blue
                var config = SwiftMessages.defaultConfig
                config.presentationStyle = .top
                config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
                config.duration = .forever // .seconds(seconds: 5)
                config.dimMode = .blur(style: .dark, alpha: 0.5, interactive: true)
                config.shouldAutorotate = true
                config.interactiveHide = true
                config.preferredStatusBarStyle = .lightContent
                SwiftMessages.show(config: config, view: view)
                sleep(1)
                completionHandler([])
            }
        }
        completionHandler([])
    }
    
    // when in background
    /*func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // display alert for notification
        let home = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()!
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapVC") as! MapVC
        vc.test = "123132132"

        vc.modalPresentationStyle = .fullScreen
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = home
        window?.makeKeyAndVisible()
        home.present(vc, animated: false, completion: nil)
        completionHandler()
    }*/
}

//
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Messaging.messaging().subscribe(toTopic: "all")
        if let fcmToken = fcmToken {
            UserDefault.setString(key: PARAMS.TOKEN, value: fcmToken)
            UserDefault.Sync()
        }
    }
}


