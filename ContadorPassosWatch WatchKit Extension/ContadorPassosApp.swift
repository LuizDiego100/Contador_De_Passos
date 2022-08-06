//
//  ContadorPassosApp.swift
//  ContadorPassosWatch WatchKit Extension
//
//  Created by Luiz Andrade on 06/08/2022.
//

import SwiftUI

@main
struct ContadorPassosApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
