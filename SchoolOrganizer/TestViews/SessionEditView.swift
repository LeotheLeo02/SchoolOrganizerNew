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
    @State private var newstart = Date()
    @State private var newend = Date()
    @State private var startday: Int = 0
    @State private var changed = false
    var body: some View {
        VStack{
            if session.name != nil{
                VStack(alignment: .leading){
                    HStack{
                        Text(session.name!)
                            .font(.system(size: 25, weight: .heavy, design: .rounded))
                            .foregroundColor(changed ? .white : .gray)
                            .animation(.easeInOut, value: changed)
                        
                            .onAppear(){
                                name = session.name!
                            }
                        Spacer()
                        Button {
                            withAnimation{
                            changed = true
                                simpleSuccess()
                                StudyDataController().editStudyTime(study: session, start: newstart, end: newend, context: managedObjContext)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                                    dismiss()
                                }
                            }
                        } label: {
                            if !changed{
                            Text("Change")
                            }
                            if changed{
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    DatePicker(selection: $newstart) {
                        Text("Current Starting Date: ")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(changed ? .white :.gray)
                            .animation(.easeInOut, value: changed)
                    }.onAppear(){
                        newstart = session.start!
                    }
                    DatePicker(selection: $newend, displayedComponents: .hourAndMinute) {
                        Text("Current Ending Time: ")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(changed ? .white :.gray)
                            .animation(.easeInOut, value: changed)
                    }.onAppear(){
                        newend = session.end!
                    }
                    
                }.padding()
                    .background(changed ? .green : Color(.systemGray6))
                    .animation(.easeInOut, value: changed)
                    .cornerRadius(20)
                    .padding()
                    .shadow(color: changed ? .green :.gray, radius: 7)
                    .animation(.easeInOut, value: changed)
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
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
