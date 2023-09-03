//
//  AppDelegate.swift
//  ChatAIT
//
//  Created by developer on 31.08.2023.
//

import CocoaLumberjack
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DDLog.add(DDOSLogger.sharedInstance)
        appCoordinator = AppCoordinator()
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    private var appCoordinator: AppCoordinatorInterface!
}


extension AppDelegate: AppCoordinatorProvider {
    var coordinator: AppCoordinatorInterface { appCoordinator }
}
