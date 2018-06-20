//
//  AppDelegate.swift
//  Picture Journal
//
//  Created by Alex Richards on 4/23/18.
//  Copyright © 2018 Alex Richards. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().barTintColor = UIColor.magenta
        UINavigationBar.appearance().tintColor = UIColor.black
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        UNUserNotificationCenter.current().delegate = self
        
        CloudKitManager.shared.registerSilentSubscriptionsWithIdentifier("photo")
    
        CloudKitManager.shared.registerSilentAlertSubscription()
        
        return true
    }


    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let ckManager = CloudKitManager.shared
        ckManager.syncEntries()
    
    }


}

