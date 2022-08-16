//
//  SessionEditView.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/16/22.
//

import SwiftUI

struct SessionEditView: View {
    var session: FetchedResults<StudySessions>.Element
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    var body: some View {
        VStack{
            if session.name != nil{
            Text(session.name!)
                .onAppear(){
                    name = session.name!
                }
            }
            Button(role: .destructive) {
                UNUserNotificationCenter.current().getPendingNotificationRequests{ (notificationRequests) in
                    let formatter1 = DateFormatter()
                    formatter1.dateStyle = .long
                    //See if it ever fixes
                    var identifiers: [String] = [name, name + "CC", name + "EE"]
                   for notification:UNNotificationRequest in notificationRequests {
                       if notification.identifier == "identifierCancel" {
                          identifiers.append(notification.identifier)
                       }
                   }
                   UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                    print("Deleted Notifcation")
                }
                dismiss()
                session.managedObjectContext?.delete(session)
                    StudyDataController().save(context: managedObjContext)
            } label: {
                HStack{
                    Text("Delete")
                    Image(systemName: "trash.fill")
                }
            }.buttonStyle(.bordered)

        }
    }
}
