//
//  TabManager.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI

struct TabManager: View {
    var body: some View {
        TabView{
            AssignmentsView()
                .tabItem {
                    Text("Assignments")
                    Image(systemName: "doc.text")
                }
            
            TestsView()
                .tabItem {
                    Text("Tests")
                    Image(systemName: "doc.on.clipboard")
                }
            
            HistoryView()
                .tabItem {
                    Text("History")
                    Image(systemName: "clock")
                }
        }
    }
}

struct TabManager_Previews: PreviewProvider {
    static var previews: some View {
        TabManager()
    }
}
