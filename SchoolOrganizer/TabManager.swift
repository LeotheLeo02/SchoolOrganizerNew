//
//  TabManager.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI

struct TabManager: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateoftest, order: .reverse)]) var completedtest: FetchedResults<CompletedTest>
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
            ProjectsView()
                .tabItem {
                    Text("Projects")
                    Image(systemName: "cube.transparent")
                }
            
            if !completedtest.isEmpty{
            HistoryView()
                .tabItem {
                    Text("Past Tests")
                    Image(systemName: "clock")
                }
            }
        }
    }
}

struct TabManager_Previews: PreviewProvider {
    static var previews: some View {
        TabManager()
    }
}
extension Color: RawRepresentable {

    public init?(rawValue: String) {
        
        guard let data = Data(base64Encoded: rawValue) else{
            self = .black
            return
        }
        
        do{
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .black
            self = Color(color)
        }catch{
            self = .black
        }
        
    }

    public var rawValue: String {
        
        do{
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
            
        }catch{
            
            return ""
            
        }
        
    }

}
