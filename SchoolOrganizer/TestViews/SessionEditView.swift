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
                        
                            .onAppear {
                                name = session.name!
                            }
                        Spacer()
                        Button {
                            withAnimation{
                            changed = true
                                simpleSuccess()
                                StudyDataController().editStudyTime(study: session, start: newstart, end: newend, context: managedObjContext)
                                UNUserNotificationCenter.current().getPendingNotificationRequests{ (notificationRequests) in
                                    let formatter1 = DateFormatter()
                                    formatter1.dateStyle = .long
                                    // See if it ever fixes
                                    var identifiers: [String] = [name, name + "CC", name + "EE"]
                                   for notification: UNNotificationRequest in notificationRequests {
                                       if notification.identifier == "identifierCancel" {
                                          identifiers.append(notification.identifier)
                                       }
                                   }
                                   UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                                    print("Deleted Notifcation")
                                }
                                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                    if success{
                                        print("All Set")
                                    }else if let error = error{
                                        print(error.localizedDescription)
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                                    let content = UNMutableNotificationContent()
                                    content.title = name
                                    let saydate = newstart
                                    content.body = "In 15 minutes! \(saydate.formatted(.dateTime.hour().minute()))"
                                    let date = newstart
                                    let fifteenminutes = Calendar.current.date(byAdding: .minute, value: -15, to: date)
                                    content.sound = UNNotificationSound.default
                                    let earlycomp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fifteenminutes!)
                                    let earlycalendartrigger = UNCalendarNotificationTrigger(dateMatching: earlycomp, repeats: false)
                                    let firstrequest = UNNotificationRequest(identifier: name, content: content, trigger: earlycalendartrigger)
                                    
                                    UNUserNotificationCenter.current().add(firstrequest)
                                    
                                    let currentcontent = UNMutableNotificationContent()
                                    currentcontent.title = name
                                    currentcontent.body = "\(name) Session Started"
                                    let currentdate = newstart
                                    let currenttime = Calendar.current.date(byAdding: .day, value: 0, to: currentdate)
                                    content.sound = UNNotificationSound.default
                                    let currentcomp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: currenttime!)
                                    let currenttrigger = UNCalendarNotificationTrigger(dateMatching: currentcomp, repeats: false)
                                    let identifier = name + "CC"
                                    let currentrequest = UNNotificationRequest(identifier: identifier, content: currentcontent, trigger: currenttrigger)
                                    UNUserNotificationCenter.current().add(currentrequest)
                                    
                                    let endcontent = UNMutableNotificationContent()
                                    endcontent.title = "\(name) Session Ending"
                                    endcontent.body = "Finish Up Last Thoughts"
                                    let enddate = newend
                                    let endtime = Calendar.current.date(byAdding: .day, value: 0, to: enddate)
                                    endcontent.sound = UNNotificationSound.default
                                    let endcomp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: endtime!)
                                    let endtrigger = UNCalendarNotificationTrigger(dateMatching: endcomp, repeats: false)
                                    let endidentifier = name + "EE"
                                    let endrequest = UNNotificationRequest(identifier: endidentifier, content: endcontent, trigger: endtrigger)
                                    UNUserNotificationCenter.current().add(endrequest)
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
                    }.onAppear {
                        newstart = session.start!
                    }
                    DatePicker(selection: $newend, displayedComponents: .hourAndMinute) {
                        Text("Current Ending Time: ")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(changed ? .white :.gray)
                            .animation(.easeInOut, value: changed)
                    }.onAppear {
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
                    // See if it ever fixes
                    var identifiers: [String] = [name, name + "CC", name + "EE"]
                   for notification: UNNotificationRequest in notificationRequests {
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
