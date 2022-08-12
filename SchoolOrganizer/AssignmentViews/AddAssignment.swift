//
//  AddAssignment.swift
//  SchoolKit
//
//  Created by Nate on 7/31/22.
//

import SwiftUI
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
    @State private var details = ""
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
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView{
        Form{
            TextField("Name Of Assignment", text: $assigname)
                .onChange(of: undoall) { newValue in
                assigname = ""
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
            List{
                Section(header: Text("Past Names")){
                    if pastname.isEmpty{
                        Text("No History")
                            .foregroundColor(.gray)
                    }else{
                        ScrollView{
            ForEach(pastname){pass in
                Button {
                    assigname = pass.pastnames!
                    exists = true
                } label: {
                    HStack{
                    Text(pass.pastnames!)
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
                                .foregroundColor(.red)
                            Image(systemName: "trash.fill")
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
            
            Section {
                TextEditor(text: $details)
                    .onChange(of: undoall) { newValue in
                        details = ""
                    }
            } header: {
                Text("Details")
            }
            
            Section {
                TextField("Enter Color", text: $color)
                    .onChange(of: undoall) { V in
                        color = ""
                    }
                    HStack{
                    Text("Red")
                            .foregroundColor(color.trimmingCharacters(in: .whitespaces) == "Red" ? .white: .red)
                            .bold()
                            .padding()
                            .background(color.trimmingCharacters(in: .whitespaces) == "Red" ? Color.red:Color.clear)
                            .animation(.spring(), value: color.trimmingCharacters(in: .whitespaces) == "Red")
                            .cornerRadius(20)
                            .onTapGesture {
                                color = "Red"
                            }
                    Divider()
                    Text("Blue")
                            .foregroundColor(color.trimmingCharacters(in: .whitespaces) == "Blue" ? .white: .blue)
                            .bold()
                            .padding()
                            .background(color.trimmingCharacters(in: .whitespaces) == "Blue" ? Color.blue:Color.clear)
                            .animation(.spring(), value: color.trimmingCharacters(in: .whitespaces) == "Blue")
                            .cornerRadius(20)
                            .onTapGesture {
                                color = "Blue"
                            }
                        Divider()
                        Text("Yellow")
                            .foregroundColor(color.trimmingCharacters(in: .whitespaces) == "Yellow" ? .white: .yellow)
                            .bold()
                            .padding()
                            .background(color.trimmingCharacters(in: .whitespaces) == "Yellow" ? Color.yellow:Color.clear)
                            .animation(.spring(), value: color.trimmingCharacters(in: .whitespaces) == "Yellow")
                            .cornerRadius(20)
                            .onTapGesture {
                                color = "Yellow"
                            }
                    }
            } header: {
                LinearGradient(
                    colors: [.red, .blue, .green, .yellow],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(
                        Text("Color")
                )
            }
            Section{
                ForEach(period){per in
                    Button {
                        duedate = per.perioddate!
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
                DatePicker("Choose a Due Date", selection: $duedate)
                    .datePickerStyle(.graphical)
                    .frame(maxHeight: 400)
                    .onChange(of: undoall) { newValue in
                        duedate = Date.now
                    }
                Toggle("Want to be reminded Two Days Prior to due date of \(assigname.isEmpty ? "(NO NAME)" : "\(assigname)")", isOn: $twodaysearly)
                    .onShake {
                        simpleSuccess()
                        undosignal.toggle()
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
                    AssignmentDataController().addAssign(notes: details, topic: topics, color: color.trimmingCharacters(in: .whitespaces), duedate: duedate, name: assigname, complete: false, context: managedObjContext)
                    dismiss()
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success{
                            print("All Set!")
                        }else if let error = error{
                            print(error.localizedDescription)
                        }
                        
                        let content = UNMutableNotificationContent()
                        content.title = assigname
                        content.subtitle = "This is Due Tomorrow!"
                        let date = duedate
                        content.sound = UNNotificationSound.default
                        let OneDayEarly = Calendar.current.date(byAdding: .day, value: -1, to: date)
                        let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: OneDayEarly!)
                        print(dateComp)
                        let calendarTrigger  = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)

                        
                        let request = UNNotificationRequest(identifier: assigname, content: content, trigger: calendarTrigger)
                        
                        UNUserNotificationCenter.current().add(request)
                    }
                        if twodaysearly{
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
        }
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
