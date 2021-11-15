//
//  SceneDelegate.swift
//  map-app
//
//  Created by Admin on 10/28/21.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyBoard.instantiateViewController(withIdentifier: "SplashVC")
            self.window?.rootViewController = initialViewController
            self.window!.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        registerForPushNotifications()
        // update pushnotification setting
        guard let _ = (scene as? UIWindowScene) else { return }
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyBoard.instantiateViewController(withIdentifier: "SplashVC")
            self.window?.rootViewController = initialViewController
            self.window!.makeKeyAndVisible()
        }
    }
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
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

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

extension SceneDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Messaging.messaging().subscribe(toTopic: "all")
        if let fcmToken = fcmToken {
            print("####################### new scene delegate token registered #######################")
            UserDefault.setString(key: PARAMS.TOKEN, value: fcmToken)
            UserDefault.Sync()
        }
    }
}

