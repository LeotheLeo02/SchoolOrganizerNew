//
//  AddTestView.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI
import AlertToast
import CoreHaptics

struct AddTestView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: [SortDescriptor(\.uses, order: .reverse)]) var topic: FetchedResults<Topics>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.score)]) var test: FetchedResults<Tests>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.number)]) var period: FetchedResults<Periods>
    @FocusState private var focusonTopic: Bool
    @State private var testname = ""
    @State private var testtopic = ""
    @State private var addtopic = false
    @State private var newtopic = ""
    @State private var undosignal = false
    @State private var deleteall = false
    @State private var undo = false
    @Environment(\.colorScheme) var colorScheme
    @State private var newtestdate = Date()
    @State private var attached = false
    @State private var presentnewassign = false
    @State private var attachtopic = ""
    @State private var addsession = false
    @State private var periodhour: Int = 0
    @State private var periodminute: Int = 0
    @State private var timechanged = false
    @State private var addperiod = false
    @State private var presentswapped = false
    @State private var addtopicusage = false
    @State private var testsession = false
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    Section {
                        TextField("Test Name...", text: $testname)
                            .onChange(of: undo, perform: { newValue in
                                testname = ""
                            })
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded({ _ in
                                        withAnimation{
                                        addtopic = false
                                        }
                                    })
                            )
                    } header: {
                        Text("Test Name")
                            .onShake {
                                undosignal.toggle()
                            }
                    }
                    Section {
                        Button {
                            addsession.toggle()
                            addtopic = false
                        } label: {
                            HStack{
                                Text("Add Session")
                                Image(systemName: "rectangle.fill.badge.person.crop")
                                    .font(.title)
                            }
                        }

                    } header: {
                        Text("Create A Session")
                    }
                    Section{
                        
                    }header: {
                        if testsession{
                        Text("Created Sessions For Test")
                        }
                    }
                    
                    Section {
                        if testtopic.isEmpty{
                            HStack{
                            Text("No topic is selected")
                                .bold()
                                .foregroundColor(.red)
                                Image(systemName: "xmark.octagon.fill")
                                    .foregroundColor(.red)
                            }
                        }else{
                            HStack{
                                Spacer()
                        Text(testtopic)
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                                .foregroundColor(.green)
                                .onChange(of: undo, perform: { newValue in
                                    testtopic = ""
                                })
                                Spacer()
                            }
                        }
                        List{
                                if !topic.isEmpty{
                                    ForEach(topic){top in
                                        HStack{
                                            Spacer()
                                        Button {
                                            withAnimation{
                                            testtopic = top.topicname!
                                            }
                                        } label: {
                                            Spacer()
                                            Text(top.topicname!)
                                                .font(.title2)
                                                .bold()
                                            Spacer()
                                            ForEach(assignment){assign in
                                                HStack{
                                                if top.topicname == assign.topic{
                                                    Image(systemName: "doc.plaintext.fill")
                                                }
                                                }.onChange(of: addtopicusage, perform: { _ in
                                                    if testtopic == top.topicname!{
                                                        top.uses += 1
                                                    }
                                                })

                                                .onAppear(){
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
                                            Spacer()
                                        Button {
                                            withAnimation {
                                                if testtopic == top.topicname!{
                                                    testtopic = ""
                                                }
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
                                    }
                                }else{
                                    Text("No topics")
                                        .foregroundColor(.gray)
                                }
                                Button {
                                    withAnimation{
                                    addtopic.toggle()
                                        focusonTopic.toggle()
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.title3)
                                        .foregroundColor(.green)
                                }
                        }
                        if addtopic{
                            TextField("Enter New Topic Name", text: $newtopic)
                                .focused($focusonTopic)
                                .onSubmit {
                                    TopicDataController().addTopic(topicname: newtopic.trimmingCharacters(in: .whitespaces), context: managedObjContext)
                                    testtopic = newtopic.trimmingCharacters(in: .whitespaces)
                                    newtopic = ""
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
                    Section{
                        ForEach(period){per in
                            Button {
                                let date  = newtestdate
                                let calendar  = Calendar.current
                                let hour = calendar.component(.hour, from: per.perioddate!)
                                let minute = calendar.component(.minute, from: per.perioddate!)
                                periodhour = hour
                                periodminute = minute
                                let newtime = Calendar.current.date(bySettingHour: periodhour, minute: periodminute, second: 0, of: date)
                                newtestdate = newtime!
                                simpleSuccess()
                                timechanged.toggle()
                                addtopic = false
                            } label: {
                                HStack{
                                    Text("\(Int64(per.number))")
                                    Text(per.name!)
                                        .bold()
                                    Spacer()
                                    Text(per.perioddate!, style: .time)
                                }
                            }
                        }.onDelete(perform: deletePeriod)
                    }header: {
                        Text("School Periods")
                    }footer: {
                        Button {
                            addperiod.toggle()
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3)
                        }
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
            .toast(isPresenting: $presentswapped, alert: {
                AlertToast(displayMode: .alert, type: .systemImage("arrow.left.arrow.right", .blue), title: "Swapped")
            })
            .sheet(isPresented: $addperiod, content: {
                AddSchoolPeriod(swapped: $presentswapped)
            })
            .sheet(isPresented: $addsession, content: {
                SessionAddPlus(name: $testname)
            })
            .sheet(isPresented: $presentnewassign, content: {
                AssignIndiviualTopicView(topicname: $attachtopic)
            })
            .sheet(isPresented: $deleteall, content: {
                ChangeAllTopicsView()
            })
            .toast(isPresenting: $timechanged) {
                AlertToast(displayMode: .banner(.pop), type: .systemImage("clock.badge.checkmark.fill", .green), title: "Time Changed", style: .style(backgroundColor: Color(.systemGray4), titleColor: colorScheme == .dark ? .white:.black, subTitleColor: .black, titleFont: .system(size: 30, weight: .heavy, design: .rounded), subTitleFont: .title))
            }
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
                            addtopicusage.toggle()
                            let content = UNMutableNotificationContent()
                            content.title = testname
                            content.body = "\(testname) is in Two Days! Make Sure To Study!"
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
                        secondcontent.body = "\(testname) is Tomorrow! Make Sure To Study!"
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
                ToolbarItem(placement: .keyboard) {
                    Button {
                        if addtopic{
                            TopicDataController().addTopic(topicname: newtopic.trimmingCharacters(in: .whitespaces), context: managedObjContext)
                            withAnimation{
                                testtopic = newtopic.trimmingCharacters(in: .whitespaces)
                            addtopic.toggle()
                                newtopic = ""
                            }
                        }
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Text("Done")
                            .font(.title)
                            .bold()
                            .if(addtopic){view in
                                view.foregroundColor(.green)
                            }
                    }

                }
            }
            .navigationTitle(testname.isEmpty ? "Add Test": "Add \(testname)")
        }
        .navigationViewStyle(.stack)
    }
    private func deleteTopics() {
        withAnimation {
            topic
            .forEach(managedObjContext.delete)
            
            // Saves to our database
            TopicDataController().save(context: managedObjContext)
        }
    }
    private func deletePeriod(offsets: IndexSet){
        withAnimation {
            offsets.map { period[$0] }
                .forEach(managedObjContext.delete)
            
            PeriodDataController().save(context: managedObjContext)
        }
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct AddTestView_Previews: PreviewProvider {
    static var previews: some View {
        AddTestView()
    }
}
