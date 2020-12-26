//
//  DoYourTasksApp.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 30/10/2020.
//

import SwiftUI
import FirebaseCore

@main
struct DoYourTasksApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ListsView()
        }
    }
}

//final class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//        return true
//    }
//}
