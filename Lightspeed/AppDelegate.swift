//
//  AppDelegate.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let speedoManagerShared = SpeedoManagerImpl.shared
    
        // If location updates were previously active, restart them after the background launch.
        if speedoManagerShared.updatesStarted {
            speedoManagerShared.beginUpdates()
        }
        // If a background activity session was previously active, reinstantiate it after the background launch.
        if speedoManagerShared.backgroundActivity {
            speedoManagerShared.backgroundActivity = true
        }
        return true
    }
}
