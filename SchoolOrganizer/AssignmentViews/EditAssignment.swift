//
//  ViewAssignment.swift
//  SchoolKit
//
//  Created by Nate on 7/31/22.
//

import SwiftUI
import UserNotifications
import AlertToast

struct EditAssignment: View {
    @Environment(\.managedObjectContext) var managedObjContext
    var assignment: FetchedResults<Assignment>.Element
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topicname)]) var topic: FetchedResults<Topics>
    @Environment(\.dismiss) var dismiss
    @State private var FolderOn = false
    @State private var complete = false
    @State private var assigntopic = false
    @State private var assigned = false
    var body: some View {
        NavigationView{
            ScrollView{
            VStack{
                if assignment.name != nil{
                    Text(assignment.name!)
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .contextMenu{
                            Button {
                                withAnimation{
                                    //Add Sheet Later
                                assigntopic = true
                                }
                            } label: {
                                Text("Reassign Topic")
                                Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                            }

                        }
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
                                    assignment.imagetitle = ""
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
                    if assignment.imagedata == nil && assignment.link ?? "" == ""{
                        Text("No Attachments")
                            .bold()
                            .font(.largeTitle)
                            .foregroundColor(.gray)
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
            .toast(isPresenting: $assigned) {
                AlertToast(displayMode: .banner(.pop), type: .complete(.blue), title: "Assigned Topic", style: .style(backgroundColor: Color(.systemGray6), titleColor: .black, subTitleColor: .black, titleFont: .system(size: 30, weight: .heavy, design: .rounded), subTitleFont: .title))
            }
        }
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        complete.toggle()
                        simpleSuccess()
                        AssignmentDataController().editAssign(assign: assignment, complete: complete, context: managedObjContext)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
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
                    }
                    } label: {
                        Image(systemName: complete ? "checkmark.circle.fill" : "circle")
                            .font(.largeTitle)
                            .animation(.easeInOut, value: complete)
                            .foregroundColor(.green)
                    }.padding(.vertical)

                }
            }
        }
        .navigationViewStyle(.stack)
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
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
