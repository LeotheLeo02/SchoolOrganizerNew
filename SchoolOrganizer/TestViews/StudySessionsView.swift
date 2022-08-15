//
//  StudySessionsView.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/15/22.
//

import SwiftUI

struct StudySessionsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.start)]) var session: FetchedResults<StudySessions>
    @State private var add = false
    var body: some View {
        NavigationView{
        ScrollView{
            ForEach(session){study in
                Text(study.name!)
            }
        }
        .sheet(isPresented: $add, content: {
            SessionAdd()
        })
        .navigationTitle("Study Sessions")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    add.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title)
                }

            }
        }
    }
    }
}

struct StudySessionsView_Previews: PreviewProvider {
    static var previews: some View {
        StudySessionsView()
    }
}

struct SessionAdd: View{
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var startdate = Date()
    @State private var enddate = Date()
    @State private var startday: Int = 0
    var body: some View{
        NavigationView{
        Form{
            TextField("Name...", text: $name)
            DatePicker("Starting...", selection: $startdate, in: Date.now...)
                .datePickerStyle(.compact)
                .onChange(of: startdate) { newValue in
                    let calendar  = Calendar.current
                    let day = calendar.component(.day, from: startdate)
                    startday = day
                    let automatic = Calendar.current.date(bySetting: .day, value: startday, of: startdate)
                    enddate = automatic!
                }
            DatePicker("Ending...", selection: $enddate,in: startdate... ,displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
        }
        .navigationTitle("Add Session")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { success, error in
                        if success{
                            print("All Set")
                        }else if let error = error{
                            print(error.localizedDescription)
                        }
                    }
                    StudyDataController().addStudySession(name: name, start: startdate, end: enddate, context: managedObjContext)
                    let content = UNMutableNotificationContent()
                    content.title = name
                    let saydate = startdate
                    content.subtitle = "In 15 minutes! \(saydate.formatted(.dateTime.hour().minute()))"
                    let date = startdate
                    let fifteenminutes = Calendar.current.date(byAdding: .minute, value: -15, to: date)
                    content.sound = UNNotificationSound.default
                    let earlycomp = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: fifteenminutes!)
                    let earlycalendartrigger = UNCalendarNotificationTrigger(dateMatching: earlycomp, repeats: false)
                    let firstrequest = UNNotificationRequest(identifier: name, content: content, trigger: earlycalendartrigger)
                    
                    UNUserNotificationCenter.current().add(firstrequest)
                    
                    let currentcontent = UNMutableNotificationContent()
                    currentcontent.title = name
                    currentcontent.subtitle = "Session Started"
                    let currentdate = startdate
                    let currenttime = Calendar.current.date(byAdding: .day, value: 0, to: currentdate)
                    content.sound = UNNotificationSound.default
                    let currentcomp = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: currenttime!)
                    let currenttrigger = UNCalendarNotificationTrigger(dateMatching: currentcomp , repeats: false)
                    let identifier = name + "CC"
                    let currentrequest = UNNotificationRequest(identifier: identifier, content: currentcontent, trigger: currenttrigger)
                    UNUserNotificationCenter.current().add(currentrequest)
                    dismiss()
                } label: {
                    Text("Submit")
                }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)

            }
        }
    }
    }
}
