//
//  SchoolOrganizerApp.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI

@main
struct SchoolOrganizerApp: App {
    @StateObject private var assigndatacontroller  = AssignmentDataController()
    @StateObject private var topicdatacontroller = TopicDataController()
    @StateObject private var folderdatacontroller = FolderDataController()
    @StateObject private var linkdatacontroller = LinksDataController()
    @StateObject private var testdatacontroller = TestDataController()
    var body: some Scene {
        WindowGroup {
            TabManager()
                .environment(\.managedObjectContext,assigndatacontroller.container.viewContext)
                .environment(\.managedObjectContext, topicdatacontroller.container.viewContext)
                .environment(\.managedObjectContext, folderdatacontroller.container.viewContext)
                .environment(\.managedObjectContext, linkdatacontroller.container.viewContext)
                .environment(\.managedObjectContext, testdatacontroller.container.viewContext)
        }
    }
}
