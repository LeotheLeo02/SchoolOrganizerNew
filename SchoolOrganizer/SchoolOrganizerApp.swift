//
//  SchoolOrganizerApp.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI

@main
struct SchoolOrganizerApp: App {
    @StateObject private var dataController = SharedDataController.shared
    
    var body: some Scene {
        WindowGroup {
            TabManager()
                .environment(\.managedObjectContext, dataController.viewContext)
                .environmentObject(dataController)
        }
    }
}
