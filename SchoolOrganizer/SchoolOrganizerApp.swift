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
    @StateObject private var linkdatacontroller = LinksDataController()
    @StateObject private var testdatacontroller = TestDataController()
    @StateObject private var pastnamedatacontroller = PastNamesDataController()
    @StateObject private var imagedatacontroller = ImageDataController()
    @StateObject private var historyadatacontroller = HistoryADataController()
    var body: some Scene {
        WindowGroup {
            TabManager()
                .environment(\.managedObjectContext,assigndatacontroller.container.viewContext)
                .environment(\.managedObjectContext, topicdatacontroller.container.viewContext)
                .environment(\.managedObjectContext, linkdatacontroller.container.viewContext)
                .environment(\.managedObjectContext, testdatacontroller.container.viewContext)
                .environment(\.managedObjectContext, pastnamedatacontroller.container.viewContext)
                .environment(\.managedObjectContext, imagedatacontroller.container.viewContext)
                .environment(\.managedObjectContext, historyadatacontroller.container.viewContext)
        }
    }
}
