//
//  AddAssignment.swift
//  SchoolKit
//
//  Created by Nate on 7/31/22.
//

import SwiftUI
import Combine
import UserNotifications
import CoreHaptics
import AlertToast

struct AddAssignment: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.score)]) var test: FetchedResults<Tests>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.uses, order: .reverse)]) var topic: FetchedResults<Topics>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.pastnames)]) var pastname: FetchedResults<PastNames>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.number)]) var period: FetchedResults<Periods>
    @FocusState private var focusonTopic: Bool
    @State private var sidenotes = ""
    @State private var topics = ""
    @State private var color  = ""
    @State private var duedate = Date()
    @State private var addtopic = false
    @State private var newname = ""
    @State private var showAlert = false
    @State private var NotComplete = false
    @State private var assigname = ""
    @State private var undosignal = false
    @State private var undoall = false
    @State private var engine: CHHapticEngine?
    @State private var exists = false
    @State private var assignmentexits = false
    @State private var reassign = false
    @State private var timechanged = false
    @State private var attached = false
    @State private var repassign = false
    @State private var reptime = Date()
    @State private var presentnewassign = false
    @State private var attachtopic = ""
    @State private var type = "Original"
    @State private var pages = ""
    @State private var done = false
    @State private var showpast = false
    @State private var periodhour: Int = 0
    @State private var periodminute: Int = 0
    @State private var date = Date()
    @State private var suggestion = ""
    @State private var suggestdays: Int = 0
    @State private var turnonsuggest = true
    @State private var ownpages: Int = 0
    @State private var owntext = ""
    @State private var pagenumber: Int = 0
    @State private var timetocomplete = Date()
    @State private var addperiod = false
    @State private var presentswapped = false
    @State private var addtopicusage = false
    @State private var notifnumber = 0
    @State private var addnotif1 = false
    @State private var addnotif2 = false
    @State private var notification1 = Date()
    @State private var notification2 = Date()
    private let adaptiveColumns = [
     GridItem(.adaptive(minimum: 50))
    ]
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView{
        Form{
            Picker(selection: $type, label: Text("What Type Of Assignment")){
                Image(systemName: "doc.plaintext.fill").tag("Original")
                Image(systemName: "book.closed.fill").tag("Book")
            }.labelsHidden()
                .pickerStyle(.segmented)
                .onChange(of: type, perform: { _ in
                    let impactHeavy = UIImpactFeedbackGenerator(style: .rigid)
                        impactHeavy.impactOccurred()
                })
                .onChange(of: undoall) { V in
                    type = "Original"
                }
            TextField("Name Of Assignment", text: $assigname)
                .onChange(of: undoall) { newValue in
                assigname = ""
            }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded({ _ in
                            withAnimation{
                            addtopic = false
                            }
                        })
                )
            if type == "Book"{
                Toggle(isOn: $turnonsuggest) {
                    HStack{
                        Spacer()
                    Text("Use Suggestion")
                        Spacer()
                    }
                }.toggleStyle(.button)
                if !turnonsuggest{
                    TextField("Number Of Pages To Read EveryDay", text: Binding(
                        get: {owntext},
                        set: {owntext = $0.filter{"0123456789".contains($0)}}))
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .onChange(of: owntext) { _ in
                        ownpages = NumberFormatter().number(from: "0" + owntext) as! Int
                    }
                    .onChange(of: undoall) { V in
                        owntext = ""
                        ownpages = 0
                    }
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded({ _ in
                                withAnimation{
                                addtopic = false
                                }
                            })
                    )
                    DatePicker("When Is It Due", selection: $timetocomplete,in: Date.now... ,displayedComponents: .date)
                        .onChange(of: undoall) { _ in
                            timetocomplete = Date.now
                        }
                }
            }
            if type == "Book" && turnonsuggest{
                HStack{
                    Spacer()
                Text("How Many Pages Are In The Book?")
                    .multilineTextAlignment(.center)
                    Spacer()
                }
                TextField("Pages", text: Binding(
                    get: {pages},
                    set: {pages = $0.filter{"0123456789".contains($0)}}))
                .onChange(of: pages) { V in
                    let days = daysBetween(start: Date.now, end: duedate)
                    pagenumber = NumberFormatter().number(from: "0" + pages) as! Int
                        if days != 0{
                        let suggest = pagenumber/days
                        suggestdays = suggest
                    }else{
                        let suggest = pagenumber/1
                        suggestdays = suggest
                    }
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded({ _ in
                            withAnimation{
                            addtopic = false
                            }
                        })
                )
                .onChange(of: undoall) { V in
                    pages = ""
                    pagenumber = 0
                }
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                Text("Pages: \(Int(pagenumber))")
                Text("Suggestion: \(suggestdays) Pages Per Day")
                DatePicker("When Is It Due", selection: $timetocomplete,in: Date.now... ,displayedComponents: .date)
                    .onChange(of: timetocomplete) { _ in
                        let days = daysBetween(start: Date.now, end: timetocomplete)
                        if days != 0{
                        let suggest = pagenumber/days
                        suggestdays = suggest
                        }else{
                            let suggest = pagenumber/1
                            suggestdays = suggest
                        }
                    }
            }
            if assignmentexits{
                HStack{
                Text("Assignment Already Exists")
                    .foregroundColor(.red)
                    .bold()
                    Image(systemName: "exclamationmark.octagon.fill")
                        .foregroundColor(.red)
                }
            }
            if type != "Book"{
            DisclosureGroup(isExpanded: $showpast) {
                ScrollView(.horizontal){
                    if pastname.isEmpty{
                        Text("No Past Names")
                            .bold()
                            .foregroundColor(.gray)
                    }
                    HStack{
                ForEach(pastname){pass in
                    Button {
                        assigname = pass.pastnames!
                        exists = true
                    } label: {
                        HStack{
                        Text(pass.pastnames!)
                                .font(.caption)
                                .bold()
                        }
                    }.tint(.blue)
                        .buttonStyle(.bordered)
                    .onChange(of: assigname, perform: { V in
                        if assigname.trimmingCharacters(in: .whitespaces) == pass.pastnames?.trimmingCharacters(in: .whitespaces) {
                            exists = true
                        }
                    })
                    Divider()
                }
                }
            }

            } label: {
                HStack{
                if showpast{
                    Text("Hide Past Names")
                }else{
                Text("See Past Names")
                }
                    Spacer()
                    Button {
                        withAnimation{
                        pastname
                        .forEach(managedObjContext.delete)
                        
                        // Saves to our database
                        PastNamesDataController().save(context: managedObjContext)
                        }
                    } label: {
                        Text("Delete All")
                            .bold()
                            .foregroundColor(.red)
                    }.buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle(radius: 30))

                }
            }
        }
            
            Section {
                if topics.isEmpty{
                    HStack{
                        Spacer()
                    Text("No topic selected")
                        .bold()
                        .foregroundColor(.red)
                        Image(systemName: "xmark.octagon.fill")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }else{
                    HStack{
                        Spacer()
                Text(topics)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.green)
                        .onChange(of: undoall, perform: { newValue in
                            topics = ""
                        })
                        Spacer()
                    }
                }
                List{
                    if topic.isEmpty{
                        Text("No Topics")
                            .foregroundColor(.gray)
                    }else{
                ForEach(topic){top in
                    HStack{
                        Spacer()
                    Button {
                        withAnimation{
                        topics = top.topicname!
                        }
                    } label: {
                        Spacer()
                        Text(top.topicname!)
                            .font(.title2)
                            .bold()
                            Spacer()
                        ForEach(assignment){assign in
                            VStack{
                            if assign.topic == top.topicname{
                                Image(systemName: "doc.plaintext.fill")
                            }
                            }
                            .onChange(of: addtopicusage, perform: { _ in
                                if topics == top.topicname!{
                                    top.uses += 1
                                }
                            })
                            .onAppear(){
                                if assign.topic == top.topicname{
                                    attached = true
                                }
                            }
                            .onChange(of: assigname) { V in
                                if assigname.trimmingCharacters(in: .whitespaces) == assign.name?.trimmingCharacters(in: .whitespaces) {
                                    withAnimation{
                                    assignmentexits = true
                                    }
                                }else{
                                    withAnimation{
                                    assignmentexits = false
                                    }
                                }
                            }
                            ForEach(test){tes in
                                VStack{
                                if tes.testtopic == top.topicname{
                                Image(systemName: "doc.on.clipboard")
                                }
                                }.onAppear(){
                                    if tes.testtopic == top.topicname{
                                        attached = true
                                    }
                                }
                            }
                        }
                    }.tint(.green)
                    .buttonStyle(.bordered)
                        Spacer()
                    Button {
                        withAnimation {
                            if topics == top.topicname{
                                topics = ""
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
                    }
                    Button {
                        withAnimation{
                            addtopic.toggle()
                            focusonTopic.toggle()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.green)
                    }.sheet(isPresented: $presentnewassign) {
                    AssignIndiviualTopicView(topicname: $attachtopic)
                }
                }
                if addtopic{
                        TextField("Enter New Topic Name", text: $newname)
                        .focused($focusonTopic)
                        .onSubmit {
                            TopicDataController().addTopic(topicname: newname.trimmingCharacters(in: .whitespaces), context: managedObjContext)
                            withAnimation{
                                topics = newname
                            addtopic.toggle()
                                newname = ""
                            }
                        }
                }

            }
            header: {
                Text("Topic")
            } footer: {
                Button {
                    deleteTopics()
                    topics = ""
                    if !assignment.isEmpty{
                        reassign.toggle()
                    }
                } label: {
                    Text("Delete All Topics")
                        .bold()
                        .foregroundColor(.red)
                }.buttonStyle(.bordered)
            }
            
            Section{
                TextField("Side Notes",text: $sidenotes)
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded({ _ in
                                withAnimation{
                                addtopic = false
                                }
                            })
                    )
                Picker(selection: $color) {
                    Text("Red").tag("Red")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.red)
                    Text("Blue").tag("Blue")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.blue)
                    Text("Green").tag("Green")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.green)
                    Text("Purple").tag("Purple")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.purple)
                }label: {
                    HStack{
                    if color == ""{
                    Text("Color: ")
                            .italic()
                            .foregroundColor(.gray)
                            .bold()
                        Spacer()
                        Text("None")
                            .italic()
                            .foregroundColor(.gray)
                            .bold()
                    }else{
                        Text("Color: ")
                            .bold()
                    }
                    }
                }
            }header:{
                Text("Color And Side Notes")
            }
            Section{
                ForEach(period){per in
                    Button {
                        let date  = duedate
                        let calendar  = Calendar.current
                        let hour = calendar.component(.hour, from: per.perioddate!)
                        let minute = calendar.component(.minute, from: per.perioddate!)
                        periodhour = hour
                        periodminute = minute
                        let newtime = Calendar.current.date(bySettingHour: periodhour, minute: periodminute, second: 0, of: date)
                        duedate = newtime!
                        simpleSuccess()
                        timechanged.toggle()
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
            }
        footer: {
            Button {
                addperiod.toggle()
            } label: {
                Image(systemName: "plus")
                    .font(.title3)
            }
        }
            Section{
                if type == "Book"{
                    HStack{
                        Spacer()
                        Text("You will be reminded daily to read \(assigname.isEmpty ? "(NO NAME)" : "\(assigname)")")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                if type == "Book"{
                    DatePicker("Choose Reminder Time", selection: $timetocomplete, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.graphical)
                        .frame(maxHeight: 400)
                        .onChange(of: undoall) { newValue in
                            timetocomplete = Date.now
                        }
                }else{
                    DatePicker("Choose a Due Date", selection: $duedate, in: Date.now...)
                    .datePickerStyle(.graphical)
                    .frame(maxHeight: 400)
                    .onChange(of: undoall) { newValue in
                        duedate = Date.now
                    }
                    Toggle(isOn: $repassign) {
                        Text("Repeat Assignment")
                        Image(systemName: "repeat.circle.fill")
                            .foregroundColor(.blue)
                            .onChange(of: addnotif1) { _ in
                                if addnotif1 && repassign{
                                    withAnimation{
                                    repassign = false
                                    }
                                }
                            }
                    }
                    if repassign{
                        DatePicker("Time:", selection: $reptime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                    }
                    HStack{
                    Stepper("Add Custom Notifications", value: $notifnumber, in: 0...2, step: 1)
                        .onChange(of: notifnumber) { V in
                            if notifnumber == 0{
                                addnotif1 = false
                                addnotif2 = false
                            }
                            if notifnumber == 1{
                                addnotif1 = true
                                addnotif2 = false
                            }
                            if notifnumber == 2{
                                addnotif1 = true
                                addnotif2 = true
                            }
                        }
                        Image(systemName: "bell.square")
                            .foregroundColor(.red)
                            .font(.title)
                    }
                    if addnotif1{
                        DatePicker(selection: $notification1, in: Date.now...){
                            Text("Custom")
                            Image(systemName: "1.square.fill")
                                .foregroundColor(.red)
                        }
                            .datePickerStyle(.compact)
                    }
                    if addnotif2{
                        HStack{
                            DatePicker(selection: $notification2, in: Date.now...){
                                Text("Custom")
                                Image(systemName: "2.square.fill")
                                    .foregroundColor(.red)
                            }
                            .datePickerStyle(.compact)
                        }
                    }
            }
            }header: {
                Text("Select Due Date")
            }
        }
        .sheet(isPresented: $reassign, content: {
            ChangeAllTopicsView()
        })
        .sheet(isPresented: $addperiod, content: {
            AddSchoolPeriod(swapped: $presentswapped)
        })
        .alert("Undo All?", isPresented: $undosignal) {
            Button("Yes") {
                undoall.toggle()
            }
            Button("No"){
                
            }
        }
        .alert(isPresented: $NotComplete){
            Alert(title: Text("Not Complete"), message: Text("Name, Topic, and Color need to be assigned"), dismissButton: .cancel(Text("Ok")))
        }
        .toast(isPresenting: $timechanged) {
            AlertToast(displayMode: .banner(.pop), type: .systemImage("clock.badge.checkmark.fill", .green), title: "Time Changed", style: .style(backgroundColor: Color(.systemGray4), titleColor: .black, subTitleColor: .black, titleFont: .system(size: 30, weight: .heavy, design: .rounded), subTitleFont: .title))
        }
        .toast(isPresenting: $presentswapped, alert: {
            AlertToast(displayMode: .alert, type: .systemImage("arrow.left.arrow.right", .blue), title: "Swapped")
        })
        .navigationTitle(assigname.isEmpty ? "Add Assignment": "Add \(assigname)")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    if assigname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || color.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || topics.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                        NotComplete.toggle()
                        complexSuccess()
                    }else{
                        if exists == false && type == "Original"{
                    PastNamesDataController().addName(pastnames: assigname, context: managedObjContext)
                        }
                        addtopicusage.toggle()
                        AssignmentDataController().addAssign(topic: topics, color: color.trimmingCharacters(in: .whitespaces), duedate: duedate, name: assigname, complete: false, book: type == "Book" ? true:false, sidenotes: sidenotes, context: managedObjContext)
                    dismiss()
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success{
                            print("All Set!")
                        }else if let error = error{
                            print(error.localizedDescription)
                        }
                        if type == "Book"{
                            let repcontent = UNMutableNotificationContent()
                            repcontent.title = "Read \(assigname)"
                            //Change depending on what the user wants
                            if turnonsuggest{
                                repcontent.body = "Pages: \(Int(suggestdays))"
                            }else{
                            repcontent.body = "Pages: \(Int(ownpages))"
                            }
                        let daterepcomp = Calendar.current.dateComponents([.hour, .minute], from: timetocomplete)
                        let reptrigger  = UNCalendarNotificationTrigger(dateMatching: daterepcomp, repeats: true)
                            let bookassign = assigname + "B"
                            let setup = UNNotificationRequest(identifier: bookassign, content: repcontent, trigger: reptrigger)
                            UNUserNotificationCenter.current().add(setup)
                            
                            let completecontent = UNMutableNotificationContent()
                            completecontent.title = "Complete Reading"
                            completecontent.body = "Make Sure To Mark \(assigname) As Complete"
                            let HourEarly = Calendar.current.date(byAdding: .hour, value: -1, to: timetocomplete)
                            let completecomp = Calendar.current.dateComponents([.year,.month,.day, .hour, .minute], from: HourEarly!)
                            let completetrigger = UNCalendarNotificationTrigger(dateMatching: completecomp, repeats: false)
                            let completeid = assigname + "C"
                            let completesetup = UNNotificationRequest(identifier: completeid, content: completecontent, trigger: completetrigger)
                            UNUserNotificationCenter.current().add(completesetup)
                        }else{
                        let content = UNMutableNotificationContent()
                        content.title = assigname
                        content.body = "This is Due Tomorrow!"
                        let date = duedate
                        content.sound = UNNotificationSound.default
                        let OneDayEarly = Calendar.current.date(byAdding: .day, value: -1, to: date)
                        let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: OneDayEarly!)
                        print(dateComp)
                        let calendarTrigger  = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                        let request = UNNotificationRequest(identifier: assigname, content: content, trigger: calendarTrigger)
                        
                        UNUserNotificationCenter.current().add(request)
                
                            let OnTimeContent = UNMutableNotificationContent()
                            OnTimeContent.title = assigname
                            OnTimeContent.body = "This is Due!"
                            let dateOn = duedate
                            OnTimeContent.sound = UNNotificationSound.default
                            let OnTime = Calendar.current.date(byAdding: .day, value: 0, to: dateOn)
                            let dateCompOn = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: OnTime!)
                            print(dateCompOn)
                            let calendarTriggerOn  = UNCalendarNotificationTrigger(dateMatching: dateCompOn, repeats: false)
                            let requestOn = UNNotificationRequest(identifier: assigname + "ON", content: OnTimeContent, trigger: calendarTriggerOn)
                            
                            UNUserNotificationCenter.current().add(requestOn)
                        }
                    }
                        if type == "Original"{
                        let twodaycontent = UNMutableNotificationContent()
                            twodaycontent.title = assigname
                            twodaycontent.body = "This is Due in Two Days!"
                            twodaycontent.sound = UNNotificationSound.default
                        let date = duedate
                        let TwoDaysEarly = Calendar.current.date(byAdding: .day, value: -2, to: date)
                            let twoComp = Calendar.current.dateComponents([.year,.month,.day, .hour,.minute], from: TwoDaysEarly!)
                        let calendarTriggerTwo  = UNCalendarNotificationTrigger(dateMatching: twoComp, repeats: false)
                            let formatter1 = DateFormatter()
                            formatter1.dateStyle = .long
                            let request2 = UNNotificationRequest(identifier: formatter1.string(from: date), content: twodaycontent, trigger: calendarTriggerTwo)
                            UNUserNotificationCenter.current().add(request2)
                            if repassign{
                            let repeatcontent = UNMutableNotificationContent()
                            repeatcontent.title = assigname
                            repeatcontent.body = "Remember To Work On This!"
                            repeatcontent.sound = UNNotificationSound.default
                            let repcomp = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: reptime)
                            let reptrigger  = UNCalendarNotificationTrigger(dateMatching: repcomp, repeats: true)
                            let reprequest = UNNotificationRequest(identifier: assigname + "Rep", content: repeatcontent, trigger: reptrigger)
                                UNUserNotificationCenter.current().add(reprequest)
                        }
                        }
                        if addnotif1{
                            let notif1 = UNMutableNotificationContent()
                            notif1.title = assigname
                            notif1.body = "Reminder To Work"
                            let date = notification1
                            notif1.sound = UNNotificationSound.default
                            let OneDayEarly = Calendar.current.date(byAdding: .day, value: 0, to: date)
                            let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: OneDayEarly!)
                            print(dateComp)
                            let calendarTrigger  = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                            let request = UNNotificationRequest(identifier: assigname + "notif1", content: notif1, trigger: calendarTrigger)
                            
                            UNUserNotificationCenter.current().add(request)
                            
                        }
                        if addnotif2{
                            let notif2 = UNMutableNotificationContent()
                            notif2.title = assigname
                            notif2.body = "Reminder To Work"
                            let date2 = notification2
                            notif2.sound = UNNotificationSound.default
                            let AnotherDayEarly = Calendar.current.date(byAdding: .day, value: 0, to: date2)
                            let dateComp2 = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: AnotherDayEarly!)
                            print(dateComp2)
                            let calendarTrigger2  = UNCalendarNotificationTrigger(dateMatching: dateComp2, repeats: false)
                            let request2 = UNNotificationRequest(identifier: assigname + "notif3", content: notif2, trigger: calendarTrigger2)
                            
                            UNUserNotificationCenter.current().add(request2)
                        }
                        
                }
                } label: {
                    Text("Add")
                }.disabled(assignmentexits)
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
                        TopicDataController().addTopic(topicname: newname.trimmingCharacters(in: .whitespaces), context: managedObjContext)
                        withAnimation{
                            topics = newname
                        addtopic.toggle()
                            newname = ""
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
        }
        .navigationViewStyle(.stack)
    }
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day, .hour, .minute], from: start, to: end).day!
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
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    func complexSuccess() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
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

struct AddAssignment_Previews: PreviewProvider {
    static var previews: some View {
        AddAssignment()
    }
}
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

//  Override the default behavior of shake gestures to send our notification instead.
extension UIWindow {
     open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
     }
}

// A view modifier that detects shaking and calls a function of our choosing.
struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

// A View extension to make the modifier easier to use.
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}
