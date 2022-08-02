//
//  ViewAssignment.swift
//  SchoolKit
//
//  Created by Nate on 7/31/22.
//

import SwiftUI
import UserNotifications

struct EditAssignment: View {
    @Environment(\.managedObjectContext) var managedObjContext
    var assignment: FetchedResults<Assignment>.Element
    @FetchRequest(sortDescriptors: [SortDescriptor(\.foldername)]) var folder: FetchedResults<Folder>
    @Environment(\.dismiss) var dismiss
    @State private var FolderOn = false
    var body: some View {
        NavigationView{
            VStack{
                if assignment.name != nil{
                Text(assignment.name!)
                    .font(.largeTitle)
                    .bold()
                }
                Button {
                    UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                        var identifiers: [String] = [assignment.topic!]
                       for notification:UNNotificationRequest in notificationRequests {
                           if notification.identifier == "identifierCancel" {
                              identifiers.append(notification.identifier)
                           }
                       }
                       UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                        print("Deleted Notifcation")
                    }
                    deleteAssignment()
                    dismiss()
                } label: {
                    HStack{
                    Text("Delete Assignment")
                        .foregroundColor(.red)
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }.buttonStyle(.bordered)
            }.sheet(isPresented: $FolderOn, content: {
                FolderView()
            })
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    ForEach(folder){fold in
                        Button(action: {
                            FolderOn.toggle()
                        },label: {
                        VStack{
                            Image(systemName: "folder.fill")
                            Text(fold.foldername!)
                        }
                        })
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    private func deleteAssignment(){
        withAnimation {
            assignment
                .managedObjectContext?.delete(assignment)
            
            // Saves to our database
            AssignmentDataController().save(context: managedObjContext)
        }
    }
}
