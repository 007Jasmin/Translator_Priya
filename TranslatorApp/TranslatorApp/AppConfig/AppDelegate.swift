//
//  AppDelegate.swift
//  TranslatorApp
//
//  Created by Priyadarshani on 18/09/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var isSubscribed: Bool {
        // return false
        /*
        if getIsFreeUseCount() < 1 {
            return true
        }
        */
        return isUserSubscribe()
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: - Methods
    func storyboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    func sharedDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    // MARK: - Change Status bar stype
    func setLightStatusBarStyle() {
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
    }
    
    func setDarkStatusBarStyle() {
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.darkContent, animated: true)
    }

}

