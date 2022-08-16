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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topicname)]) var topic: FetchedResults<Topics>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.pastnames)]) var pastname: FetchedResults<PastNames>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.number)]) var period: FetchedResults<Periods>
    @FocusState private var focusonTopic: Bool
    @State private var topics = ""
    @State private var color  = ""
    @State private var duedate = Date()
    @State private var addtopic = false
    @State private var newname = ""
    @State private var showAlert = false
    @State private var NotComplete = false
    @State private var twodaysearly = false
    @State private var assigname = ""
    @State private var undosignal = false
    @State private var undoall = false
    @State private var engine: CHHapticEngine?
    @State private var exists = false
    @State private var assignmentexits = false
    @State private var reassign = false
    @State private var timechanged = false
    @State private var attached = false
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
    @State private var pagenumber: Int = 0
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView{
        Form{
            Picker(selection: $type, label: Text("What Type Of Assignment")){
                Image(systemName: "doc.plaintext.fill").tag("Original")
                Image(systemName: "book.closed.fill").tag("Book")
            }.labelsHidden()
                .pickerStyle(.segmented)
                .onChange(of: undoall) { V in
                    type = "Original"
                }
            TextField("Name Of Assignment", text: $assigname)
                .onChange(of: undoall) { newValue in
                assigname = ""
            }
            if type == "Book"{
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
                .onChange(of: undoall) { V in
                    pages = ""
                    pagenumber = 0
                }
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                Text("Pages: \(Int(pagenumber))")
                Text("Suggestion: \(suggestdays) Pages Per Day")
                DatePicker("When Is It Due", selection: $duedate, displayedComponents: .date)
                    .onChange(of: duedate) { V in
                        let days = daysBetween(start: Date.now, end: duedate)
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
                List{
                ForEach(pastname){pass in
                    Button {
                        assigname = pass.pastnames!
                        exists = true
                    } label: {
                        HStack{
                        Text(pass.pastnames!)
                                .font(.caption)
                                .bold()
                            Spacer()
                            Button {
                                withAnimation {
                                        pass
                                        .managedObjectContext?.delete(pass)
                                    
                                    // Saves to our database
                                    PastNamesDataController().save(context: managedObjContext)
                                }
                            } label: {
                                Text("Delete")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                                Image(systemName: "trash.fill")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                            }
                        }
                    }.tint(.blue)
                        .buttonStyle(.bordered)
                    .onChange(of: assigname, perform: { V in
                        if assigname.trimmingCharacters(in: .whitespaces) == pass.pastnames?.trimmingCharacters(in: .whitespaces) {
                            exists = true
                        }
                    })
                }
            }

            } label: {
                if showpast{
                    Text("Hide Past Names")
                }else{
                Text("See Past Names")
                }
                
            }
        }
            Section {
                if topics.isEmpty{
                    Text("No topic selected")
                        .bold()
                        .foregroundColor(.gray)
                }else{
                Text(topics)
                        .bold()
                        .foregroundColor(.green)
                        .onChange(of: undoall, perform: { newValue in
                            topics = ""
                        })
                }
                ScrollView(.horizontal){
                HStack{
                    if topic.isEmpty{
                        Text("No Topics")
                            .foregroundColor(.gray)
                    }else{
                ForEach(topic){top in
                    Button {
                        topics = top.topicname!
                    } label: {
                        Text(top.topicname!)
                        ForEach(assignment){assign in
                            VStack{
                            if assign.topic == top.topicname{
                                Image(systemName: "doc.plaintext.fill")
                            }
                            }
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
                    }
                    Button {
                        withAnimation{
                            addtopic.toggle()
                            focusonTopic.toggle()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.green)
                    }
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
                            addtopic.toggle()
                            }
                        }
                }

            }
            header: {
                Text("Topic")
            }
            footer: {
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
                Picker("Color:", selection: $color) {
                    Text("Red").tag("Red")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.red)
                    Text("Blue").tag("Blue")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.blue)
                    Text("Green").tag("Green")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.green)
                }
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
                }
            }header: {
                Text("School Periods")
            }
            Section {
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
                    Toggle(isOn: $turnonsuggest) {
                        Text("Use Suggestion")
                    }
                    DatePicker("Choose Reminder Time", selection: $duedate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.graphical)
                        .frame(maxHeight: 400)
                        .onChange(of: undoall) { newValue in
                            duedate = Date.now
                        }
                    if !turnonsuggest{
                        Picker("Choose the Amount of Pages You Want To Read Everyday", selection: $ownpages){
                            ForEach(1...150, id: \.self){custom in
                                Text("\(custom)")
                            }
                        }.pickerStyle(.menu)
                    }
                }else{
                DatePicker("Choose a Due Date", selection: $duedate)
                    .datePickerStyle(.graphical)
                    .frame(maxHeight: 400)
                    .onChange(of: undoall) { newValue in
                        duedate = Date.now
                    }
                Toggle("Reminder Two Days Prior To Due Date", isOn: $twodaysearly)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .onShake {
                        simpleSuccess()
                        undosignal.toggle()
                    }
            }
            } header: {
                Text("Select Due Date")
            }
        }
        .sheet(isPresented: $reassign, content: {
            ChangeAllTopicsView()
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
        .navigationTitle(assigname.isEmpty ? "Add Assignment": "Add \(assigname)")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    if assigname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || color.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || topics.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                        NotComplete.toggle()
                        complexSuccess()
                    }else{
                        if exists == false{
                    PastNamesDataController().addName(pastnames: assigname, context: managedObjContext)
                        }
                        AssignmentDataController().addAssign(topic: topics, color: color.trimmingCharacters(in: .whitespaces), duedate: duedate, name: assigname, complete: false, book: type == "Book" ? true:false, context: managedObjContext)
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
                        let daterepcomp = Calendar.current.dateComponents([.hour, .minute], from: duedate)
                        let reptrigger  = UNCalendarNotificationTrigger(dateMatching: daterepcomp, repeats: true)
                            let setup = UNNotificationRequest(identifier: assigname, content: repcontent, trigger: reptrigger)
                            UNUserNotificationCenter.current().add(setup)
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
                        }
                    }
                        if twodaysearly && type == "Original"{
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
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day, .hour, .minute], from: start, to: end).day!
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
