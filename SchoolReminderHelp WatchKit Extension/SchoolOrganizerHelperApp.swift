//
//  SchoolOrganizerHelperApp.swift
//  SchoolReminderHelp WatchKit Extension
//
//  Created by Nate on 8/12/22.
//

import SwiftUI

@main
struct SchoolOrganizerHelperApp: App {
    @StateObject private var assigndatacontroller  = AssignmentDataController()
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext,assigndatacontroller.container.viewContext)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
