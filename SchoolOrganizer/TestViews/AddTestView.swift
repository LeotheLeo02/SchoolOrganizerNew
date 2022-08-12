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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.score)]) var test: FetchedResults<Tests>
    @State private var testname = ""
    @State private var testtopic = ""
    @State private var addtopic = false
    @State private var newtopic = ""
    @State private var undosignal = false
    @State private var deleteall = false
    @State private var undo = false
    @State private var newtestdate = Date()
    @State private var attached = false
    @State private var presentnewassign = false
    @State private var attachtopic = ""
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    Section {
                        TextField("Test Name...", text: $testname)
                            .onChange(of: undo, perform: { newValue in
                                testname = ""
                            })
                    } header: {
                        Text("Test Name")
                            .onShake {
                                undosignal.toggle()
                            }
                    }
                    
                    Section {
                        if testtopic.isEmpty{
                            Text("No topic is selected")
                                .bold()
                                .foregroundColor(.gray)
                        }else{
                        Text(testtopic)
                                .bold()
                                .foregroundColor(.green)
                                .onChange(of: undo, perform: { newValue in
                                    testtopic = ""
                                })
                             
                        }
                        ScrollView(.horizontal){
                            HStack{
                                if !topic.isEmpty{
                                    ForEach(topic){top in
                                        Button {
                                            testtopic = top.topicname!
                                        } label: {
                                            Text(top.topicname!)
                                            ForEach(assignment){assign in
                                                HStack{
                                                if top.topicname == assign.topic{
                                                    Image(systemName: "doc.plaintext.fill")
                                                }
                                                }.onAppear(){
                                                    if assign.topic == top.topicname{
                                                        attached = true
                                                    }
                                                }
                                            }
                                            ForEach(test){tes in
                                                HStack{
                                                if top.topicname == tes.testtopic{
                                                    Image(systemName: "doc.on.clipboard")
                                                }
                                                }.onAppear(){
                                                    if tes.testtopic == top.topicname{
                                                        attached = true
                                                    }
                                                }
                                            }
                                        }.tint(.green)
                                        .buttonStyle(.bordered)
                                        Button {
                                            withAnimation {
                                                if attached{
                                                    attachtopic = top.topicname!
                                                    presentnewassign.toggle()
                                                }
                                                top
                                                    .managedObjectContext?.delete(top)
                                                
                                                // Saves to our database
                                                TopicDataController().save(context: managedObjContext)
                                            }
                                        } label: {
                                            Image(systemName: "trash.fill")
                                        }.tint(.red)
                                        .buttonStyle(.borderedProminent)
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
                                        .foregroundColor(.green)
                                }

                            }
                        }
                        if addtopic{
                            TextField("Enter New Topic Name", text: $newtopic)
                                .onSubmit {
                                    TopicDataController().addTopic(topicname: newtopic.trimmingCharacters(in: .whitespaces), context: managedObjContext)
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
                            if !assignment.isEmpty{
                                deleteall.toggle()
                            }
                        } label: {
                            Text("Delete All Topics")
                                .foregroundColor(.red)
                                .bold()
                        }.buttonStyle(.bordered)
                    }
                    Section {
                        DatePicker("Select The Day Of Your Test", selection: $newtestdate, in: Date.now...)
                            .datePickerStyle(.graphical)
                            .frame(maxHeight: 400)
                            .onChange(of: undo, perform: { newValue in
                                newtestdate = Date.now
                            })
                    } header: {
                        Text("Test Date")
                    }


                }
            }.alert("Undo All?", isPresented: $undosignal) {
                Button("Yes") {
                    undo.toggle()
                }
                Button("No"){
                    
                }
            }
            .sheet(isPresented: $presentnewassign, content: {
                AssignIndiviualTopicView(topicname: $attachtopic)
            })
            .sheet(isPresented: $deleteall, content: {
                ChangeAllTopicsView()
            })
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        TestDataController().addTest(testname: testname, topic: testtopic, testdate: newtestdate, context: managedObjContext)
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                            if success{
                                print("All Set For Test!")
                            }else if let error = error{
                                print(error.localizedDescription)
                            }
                            //Finish Notifications
                            let content = UNMutableNotificationContent()
                            content.title = testname
                            content.subtitle = "\(testname) is in Two Days! Make Sure To Study!"
                            let date = newtestdate
                            let TwoDaysEarly = Calendar.current.date(byAdding: .day, value: -2, to: date)
                            content.sound = UNNotificationSound.default
                            let twoComp = Calendar.current.dateComponents([.year,.month,.day, .hour, .minute], from: TwoDaysEarly!)

                            let calendarTriggerTwo  = UNCalendarNotificationTrigger(dateMatching: twoComp, repeats: false)
                            let today = newtestdate
                            let formatter1 = DateFormatter()
                            formatter1.dateStyle = .long
                            print(formatter1.string(from: today))
                            let request = UNNotificationRequest(identifier: formatter1.string(from: newtestdate) , content: content, trigger: calendarTriggerTwo)
                            
                            UNUserNotificationCenter.current().add(request)
                        }
                        let date2 = newtestdate
                        let secondcontent = UNMutableNotificationContent()
                        secondcontent.title = testname
                        secondcontent.subtitle = "\(testname) is Tomorrow! Make Sure To Study!"
                        secondcontent.sound = UNNotificationSound.default
                        let OneDayEarly = Calendar.current.date(byAdding: .day, value: -1, to: date2)
                        let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: OneDayEarly!)
                        let calendarTrigger  = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                        let request2 = UNNotificationRequest(identifier: testname, content: secondcontent, trigger: calendarTrigger)
                        UNUserNotificationCenter.current().add(request2)
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
