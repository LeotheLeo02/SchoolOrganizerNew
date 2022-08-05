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
                            .if(assignment.imagesize == 1, transform: { View in
                                View.frame(width: 150, height: 150, alignment: .center)
                            })
                            .if(assignment.imagesize == 2, transform: { View in
                                View.frame(width: 250, height: 250, alignment: .center)
                            })
                            .if(assignment.imagesize == 3, transform: { View in
                                View.frame(width: 350, height: 350, alignment: .center)
                            })
                            Text(assignment.imagetitle!)
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                        }.padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        .contextMenu{
                            Button(role: .destructive) {
                                withAnimation{
                                assignment.imagedata = nil
                                    assignment.imagetitle = nil
                                    assignment.imagesize = 0
                                    try? managedObjContext.save() 
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
                Button {
                    FolderOn.toggle()
                } label: {
                    Image(systemName: "folder.fill")
                        .font(.largeTitle)
                }.padding()
            }.sheet(isPresented: $FolderOn, content: {
                FolderView()
            })
            .navigationBarHidden(true)
            .toolbar{
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
