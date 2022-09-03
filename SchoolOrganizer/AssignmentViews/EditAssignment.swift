//
//  ViewAssignment.swift
//  SchoolKit
//
//  Created by Nate on 7/31/22.
//

import SwiftUI
import UserNotifications
import AlertToast
import UIKit

struct EditAssignment: View {
    @Environment(\.managedObjectContext) var managedObjContext
    var assignment: FetchedResults<Assignment>.Element
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topicname)]) var topic: FetchedResults<Topics>
    @Environment(\.dismiss) var dismiss
    @State private var FolderOn = false
    @State private var complete = false
    @State private var assigntopic = false
    @State private var assigned = false
    @State private var editnotes = false
    @FocusState var addside: Bool
    @State private var sidenotes = ""
    @Binding var newvalue: Bool
    @State private var orientation = UIDevice.current.orientation
    private let orientationChanged = NotificationCenter.default
        .publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    
    var body: some View {
        NavigationView{
            ScrollView{
            VStack{
                if assignment.name != nil{
                    Text(assignment.name!)
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .if(assignment.color == "Red") { Text in
                            Text.foregroundColor(.red)
                        }
                        .if(assignment.color == "Blue") { Text in
                            Text.foregroundColor(.blue)
                        }
                        .if(assignment.color == "Yellow") { Text in
                            Text.foregroundColor(.yellow)
                        }
                        .if(assignment.color == "Green") { Text in
                            Text.foregroundColor(.green)
                        }
                        .if(assignment.color == "Purple"){ view in
                            view.foregroundColor(.purple)
                        }
                    if assignment.sidenotes != nil{
                        if editnotes == false && !assignment.sidenotes!.trimmingCharacters(in: .whitespaces).isEmpty{
                        Text(assignment.sidenotes!)
                            .italic()
                            .bold()
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                            .onLongPressGesture {
                                withAnimation{
                                editnotes = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                    addside.toggle()
                                    }
                                }
                            }
                        }
                        if assignment.sidenotes!.trimmingCharacters(in: .whitespaces).isEmpty && editnotes == false{
                            Button {
                                withAnimation{
                                editnotes.toggle()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                    addside.toggle()
                                    }
                                }
                            } label: {
                                HStack{
                                    Text("Add Note")
                                    Image(systemName: "plus")
                                }
                            }.buttonStyle(.bordered)
                            .buttonBorderShape(.roundedRectangle(radius: 30))

                        }
                        if editnotes{
                            TextField("Side Notes",text: $sidenotes)
                                .focused($addside)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(15)
                                .onSubmit {
                                    withAnimation {
                                            AssignmentDataController().editAssignNotes(assign: assignment, sidenotes: sidenotes, context: managedObjContext)
                                            editnotes = false
                                    }
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                                .onAppear(){
                                    sidenotes = assignment.sidenotes!
                                }
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
                    Image(systemName: "folder.fill.badge.plus")
                        .font(.largeTitle)
                }.padding()
            }.padding()
            .sheet(isPresented: $FolderOn, content: {
                FolderViewSpecific(assignment: assignment)
            })
            .toast(isPresenting: $assigned) {
                AlertToast(displayMode: .banner(.pop), type: .complete(.blue), title: "Assigned Topic", style: .style(backgroundColor: Color(.systemGray6), titleColor: .black, subTitleColor: .black, titleFont: .system(size: 30, weight: .heavy, design: .rounded), subTitleFont: .title))
            }
            }
            .toolbar{
            ToolbarItem(placement: .bottomBar) {
                Button {
                    UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                        let formatter1 = DateFormatter()
                        formatter1.dateStyle = .long
                        let bookassign = assignment.name! + "B"
                        let bookcomplete = assignment.name! + "C"
                        let notif1 = assignment.name! + "notif1"
                        let notif2 = assignment.name! + "notif2"
                        let ontime = assignment.name! + "ON"
                        let rep = assignment.name! + "Rep"
                        if assignment.book{
                        var identifiers: [String] = [bookassign, bookcomplete]
                            for notification:UNNotificationRequest in notificationRequests {
                                if notification.identifier == "identifierCancel" {
                                   identifiers.append(notification.identifier)
                                }
                            }
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                             print("Deleted Notifcation")
                        }else{
                        var identifiers: [String] = [assignment.name!, formatter1.string(from: assignment.duedate!),notif1,notif2,ontime,rep]
                            for notification:UNNotificationRequest in notificationRequests {
                                if notification.identifier == "identifierCancel" {
                                   identifiers.append(notification.identifier)
                                }
                            }
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                             print("Deleted Notifcation")
                        }
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
                    Button{
                        complete.toggle()
                        simpleSuccess()
                        if complete{
                            simpleSuccess()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation{
                                    HistoryADataController().addAssign(assignname: assignment.name!, assigncolor: assignment.color!, assigndate: Date.now, context: managedObjContext)
                                    if complete != false{
                                        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                                            let formatter1 = DateFormatter()
                                            formatter1.dateStyle = .long
                                            let bookassign = assignment.name! + "B"
                                            let bookcomplete = assignment.name! + "C"
                                            let notif1 = assignment.name! + "notif1"
                                            let notif2 = assignment.name! + "notif2"
                                            let ontime = assignment.name! + "ON"
                                            let rep = assignment.name! + "Rep"
                                            if assignment.book{
                                            var identifiers: [String] = [bookassign, bookcomplete]
                                                for notification:UNNotificationRequest in notificationRequests {
                                                    if notification.identifier == "identifierCancel" {
                                                       identifiers.append(notification.identifier)
                                                    }
                                                }
                                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                                                 print("Deleted Notifcation")
                                            }else{
                                            var identifiers: [String] = [assignment.name!, formatter1.string(from: assignment.duedate!), notif1,notif2,ontime,rep]
                                                for notification:UNNotificationRequest in notificationRequests {
                                                    if notification.identifier == "identifierCancel" {
                                                       identifiers.append(notification.identifier)
                                                    }
                                                }
                                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                                                 print("Deleted Notifcation")
                                            }
                                        }

                                newvalue.toggle()
                                dismiss()
                                assignment.managedObjectContext?.delete(assignment)
                                    AssignmentDataController().save(context: managedObjContext)
                                }
                            }
                            }
                        }
                    } label: {
                        HStack{
                            Text("Complete")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundColor(.green)
                        Image(systemName: complete ? "checkmark.circle.fill" : "circle")
                            .font(.largeTitle)
                            .animation(.easeInOut, value: complete)
                            .foregroundColor(.green)
                        }
                    }.if(orientation.isLandscape){view in
                        view.padding()
                    }
                        .if(orientation.isFlat){view in
                        view.padding(.horizontal)
                    }
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .onReceive(orientationChanged) { _ in
                            orientation = UIDevice.current.orientation
                        }

                }
                ToolbarItem(placement: .principal) {
                    VStack{
                        if assignment.name != nil{
                        Text(assignment.name!)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    Button {
                        withAnimation {
                                AssignmentDataController().editAssignNotes(assign: assignment, sidenotes: sidenotes, context: managedObjContext)
                                editnotes = false
                        }
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Text("Done")
                            .font(.title)
                            .bold()
                    }

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
