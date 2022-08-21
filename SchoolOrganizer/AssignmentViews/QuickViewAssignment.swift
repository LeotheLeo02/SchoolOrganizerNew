//
//  QuickViewAssignment.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/14/22.
//

import SwiftUI

struct QuickViewAssignment: View {
    var assignment: FetchedResults<Assignment>.Element
    @Environment(\.managedObjectContext) var managedObjContext
    @State private var edit = false
    @State private var name = ""
    var body: some View {
        VStack{
        Rectangle()
            .frame(width: 200, height: 200)
            .cornerRadius(20)
            .foregroundColor(Color(.systemGray6))
            .overlay {
                VStack{
                Text(assignment.name!)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .if(assignment.color == "Red") { View in
                            View.foregroundColor(.red)
                        }
                        .if(assignment.color == "Blue") { View in
                            View.foregroundColor(.blue)
                        }
                        .if(assignment.color == "Green") { View in
                            View.foregroundColor(.green)
                        }
                Text(assignment.topic!)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
            }
            Button {
                withAnimation{
                    if edit{
                    AssignmentDataController().editAssignName(assign: assignment, name: name, context: managedObjContext)
                    }
                    edit.toggle()
                }
            } label: {
                if edit == false{
                Image(systemName: "square.and.pencil")
                        .font(.title)
                }else{
                    Text("Done")
                        .bold()
                }
                
            }.buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
            if edit{
                TextField("Name...", text: $name)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .onAppear(){
                        name = assignment.name!
                    }
            }
            Button {
                withAnimation{
                    assignment.complete.toggle()
                    AssignmentDataController().editAssign(assign: assignment, complete: assignment.complete, context: managedObjContext)
                    if assignment.complete{
                        simpleSuccess()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation{
                                assignmentscompleted += 1
                                HistoryADataController().addAssign(assignname: assignment.name!, assigncolor: assignment.color!, assigndate: Date.now, context: managedObjContext)
                                if assignment.complete != false{
                                    UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                                        let formatter1 = DateFormatter()
                                        formatter1.dateStyle = .long
                                        let bookassign = assignment.name! + "B"
                                        let bookcomplete = assignment.name! + "C"
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
                                        var identifiers: [String] = [assignment.name!, formatter1.string(from: assignment.duedate!)]
                                            for notification:UNNotificationRequest in notificationRequests {
                                                if notification.identifier == "identifierCancel" {
                                                   identifiers.append(notification.identifier)
                                                }
                                            }
                                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                                             print("Deleted Notifcation")
                                        }
                                    }
                            assignment.managedObjectContext?.delete(assignment)
                                AssignmentDataController().save(context: managedObjContext)
                            }
                        }
                        }
                    }
                }
            } label: {
                Image(systemName: assignment.complete ?  "checkmark.circle.fill":"circle")
                    .foregroundColor(.green)
                    .font(.largeTitle)
            }

        }.padding()
        .background(Color(.systemGray5))
        .cornerRadius(20)
    }
}
