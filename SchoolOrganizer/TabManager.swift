//
//  TabManager.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI

struct TabManager: View {
    @AppStorage("Color") var Color: Color = .clear
    var body: some View {
        TabView{
            AssignmentsView(Background: $Color)
                .tabItem {
                    Text("Assignments")
                    Image(systemName: "doc.text")
                }
            
            TestsView(Background: $Color)
                .tabItem {
                    Text("Tests")
                    Image(systemName: "doc.on.clipboard")
                }
            
            HistoryView(Background: $Color)
                .tabItem {
                    Text("History")
                    Image(systemName: "clock")
                }
        }
        ColorPicker("Pick", selection: $Color)
            .frame(width: 25, height: 25, alignment: .center)
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
