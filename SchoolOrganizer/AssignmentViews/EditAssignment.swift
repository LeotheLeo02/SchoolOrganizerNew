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
                    if assignment.link != nil {
                    Link("\(assignment.link!)", destination: URL(string: assignment.link!)!)
                    }
                    if assignment.imagedata != nil{
                        VStack{
                        Image(uiImage: UIImage(data: assignment.imagedata!)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150, alignment: .center)
                            Text(assignment.imagetitle!)
                        }.padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        .contextMenu{
                            Button(role: .destructive) {
                                withAnimation{
                                assignment.imagedata = nil
                                    assignment.imagetitle = nil
                                }
                            } label: {
                                HStack{
                                Text("Delete Image")
                                    Image(systemName: "trash")
                                }
                            }

                        }
                    }
                }
            }.sheet(isPresented: $FolderOn, content: {
                FolderView()
            })
            .navigationBarHidden(true)
            .toolbar{
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
            ToolbarItem(placement: .bottomBar) {
                Button {
                    UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                        var identifiers: [String] = [assignment.name!]
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
            }
            }
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
