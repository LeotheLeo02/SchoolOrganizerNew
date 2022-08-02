//
//  AddTestView.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI

struct AddTestView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topicname)]) var topic: FetchedResults<Topics>
    @State private var testname = ""
    @State private var testtopic = ""
    @State private var addtopic = false
    @State private var newtopic = ""
    @State private var testdate = Date()
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    Section {
                        TextField("Test Name...", text: $testname)
                    } header: {
                        Text("Test Name")
                    }
                    
                    Section {
                        if testtopic.isEmpty{
                            Text("No topic is selected")
                                .bold()
                                .foregroundColor(.gray)
                        }else{
                        Text(testtopic)
                                .bold()
                                .foregroundColor(.blue)
                        }
                        ScrollView(.horizontal){
                            HStack{
                                if !topic.isEmpty{
                                    ForEach(topic){top in
                                        Button {
                                            testtopic = top.topicname!
                                        } label: {
                                            Text(top.topicname!)
                                        }.buttonStyle(.bordered)
                                    }
                                }else{
                                    Text("No topics")
                                        .foregroundColor(.gray)
                                }
                                Button {
                                    withAnimation{
                                    addtopic.toggle()
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                }

                            }
                        }
                        if addtopic{
                            TextField("Enter New Topic Name", text: $newtopic)
                                .onSubmit {
                                    TopicDataController().addTopic(topicname: newtopic, context: managedObjContext)
                                    withAnimation {
                                        addtopic.toggle()
                                    }
                                }
                        }
                    } header: {
                        Text("Topic")
                    }footer: {
                        Button {
                            deleteTopics()
                        } label: {
                            Text("Delete All Topics")
                                .foregroundColor(.red)
                                .bold()
                        }.buttonStyle(.bordered)
                    }
                    Section {
                        DatePicker("Select The Day Of Your Test", selection: $testdate, in: Date.now..., displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .frame(maxHeight: 400)
                    } header: {
                        Text("Test Date")
                    }


                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        TestDataController().addTest(testname: testname, topic: testtopic, testdate: testdate, context: managedObjContext)
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                            if success{
                                print("All Set For Test!")
                            }else if let error = error{
                                print(error.localizedDescription)
                            }
                            
                            let content = UNMutableNotificationContent()
                            content.title = testname
                            content.subtitle = "\(testname) is in Two Days! Make Sure To Study!"
                            let secondcontent = UNMutableNotificationContent()
                            secondcontent.title = testname
                            secondcontent.subtitle = "\(testname) is Tomorrow! Make Sure To Study!"
                            secondcontent.sound = UNNotificationSound.default
                            let date = testdate
                            let TwoDaysEarly = Calendar.current.date(byAdding: .day, value: -2, to: date)
                            let OneDayEarly = Calendar.current.date(byAdding: .day, value: -1, to: date)
                            content.sound = UNNotificationSound.default
                            let dateComp = Calendar.current.dateComponents([.year, .month, .day], from: OneDayEarly!)
                            let twoComp = Calendar.current.dateComponents([.year,.month,.day], from: TwoDaysEarly!)
                            
                            let calendarTrigger  = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)

                            let calendarTriggerTwo  = UNCalendarNotificationTrigger(dateMatching: twoComp, repeats: false)
                            
                            let request = UNNotificationRequest(identifier: testname, content: content, trigger: calendarTriggerTwo)
                            let request2 = UNNotificationRequest(identifier: testname, content: content, trigger: calendarTrigger)
                            
                            UNUserNotificationCenter.current().add(request)
                            UNUserNotificationCenter.current().add(request2)
                        }
                        dismiss()
                    } label: {
                        Text("Confirm")
                    }

                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }

                }
            }
            .navigationTitle(testname.isEmpty ? "Add Test": "Add \(testname)")
        }
    }
    private func deleteTopics() {
        withAnimation {
            topic
            .forEach(managedObjContext.delete)
            
            // Saves to our database
            TopicDataController().save(context: managedObjContext)
        }
    }
}

struct AddTestView_Previews: PreviewProvider {
    static var previews: some View {
        AddTestView()
    }
}
