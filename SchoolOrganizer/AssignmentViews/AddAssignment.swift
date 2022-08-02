//
//  AddAssignment.swift
//  SchoolKit
//
//  Created by Nate on 7/31/22.
//

import SwiftUI
import UserNotifications
import CoreHaptics

struct AddAssignment: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topicname)]) var topic: FetchedResults<Topics>
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
    @State private var engine: CHHapticEngine?
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView{
        Form{
            TextField("Name Of Assignment", text: $assigname)
            Section {
                if topics.isEmpty{
                    Text("No topic selected")
                        .bold()
                        .foregroundColor(.gray)
                }else{
                Text(topics)
                        .bold()
                        .foregroundColor(.blue)
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
                    }.buttonStyle(.bordered)
                }
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
                        TextField("Enter New Topic Name", text: $newname)
                        .onSubmit {
                            TopicDataController().addTopic(topicname: newname, context: managedObjContext)
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
                } label: {
                    Text("Delete All Topics")
                        .bold()
                        .foregroundColor(.red)
                }.buttonStyle(.bordered)
            }
            
            Section {
                TextEditor(text: $details)
            } header: {
                Text("Details")
            }
            
            Section {
                TextField("Enter Color", text: $color)
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
            
            Section {
                DatePicker("Choose a Due Date", selection: $duedate, in: Date.now..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .frame(maxHeight: 400)
                Toggle("Want to be reminded Two Days Prior to due date of \(assigname)", isOn: $twodaysearly)
            } header: {
                Text("Select Due Date")
            }

        }
        .alert(isPresented: $NotComplete){
            Alert(title: Text("Not Complete"), message: Text("Name, Topic, and Color need to be assigned"), dismissButton: .cancel(Text("Ok")))
        }
        .navigationTitle(assigname.isEmpty ? "Add Assignment": "Add \(assigname)")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    if assigname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || color.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || topics.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                        NotComplete.toggle()
                        complexSuccess()
                    }else{
                    AssignmentDataController().addAssign(notes: details, topic: topics, color: color.trimmingCharacters(in: .whitespaces), duedate: duedate, name: assigname, context: managedObjContext)
                    dismiss()
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success{
                            print("All Set!")
                        }else if let error = error{
                            print(error.localizedDescription)
                        }
                        
                        let content = UNMutableNotificationContent()
                        content.title = topics
                        content.subtitle = "This is Due Today!"
                        let date = duedate
                        let TwoDaysEarly = Calendar.current.date(byAdding: .day, value: -2, to: date)
                        content.sound = UNNotificationSound.default
                        let dateComp = Calendar.current.dateComponents([.year, .month, .day], from: date)
                        let twoComp = Calendar.current.dateComponents([.year,.month,.day], from: TwoDaysEarly!)
                        
                        let calendarTrigger  = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)

                        let calendarTriggerTwo  = UNCalendarNotificationTrigger(dateMatching: twoComp, repeats: false)
                        
                        let request = UNNotificationRequest(identifier: assigname, content: content, trigger: twodaysearly ? calendarTriggerTwo : calendarTrigger)
                        
                        UNUserNotificationCenter.current().add(request)
                    }
                }
                } label: {
                    Text("Add")
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
        }
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
