//
//  ProjectCreateVew.swift
//  SchoolOrganizerPlus
//
//  Created by Nate on 8/22/22.
//

import SwiftUI

struct ProjectCreateView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var goal1 = ""
    @State private var goal2 = ""
    @State private var goal3 = ""
    @State private var checkpoint1 = Date()
    @State private var checkpoint2 = Date()
    @State private var checkpoint3 = Date()
    @State private var duedate = Date()
    var body: some View {
        NavigationView{
        ScrollView{
        VStack{
            TextField("Name...", text: $name)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
            Rectangle()
                .frame(width: .infinity, height: 150)
                .foregroundColor(Color(.systemGray6))
                .cornerRadius(20)
                .overlay {
                    VStack{
                        HStack{
                            Image(systemName: goal1.trimmingCharacters(in: .whitespaces).isEmpty ? "circle":"checkmark.circle.fill")
                                .foregroundColor(.green)
                            TextField("Checkpoint 1 Goal", text: $goal1)
                                .textFieldStyle(.roundedBorder)
                        }
                        DatePicker("Checkpoint 1 Due Date", selection: $checkpoint1,in: Date.now...)
                            .datePickerStyle(.compact)
                    }.padding()
                }
            Rectangle()
                .frame(width: .infinity, height: 150)
                .foregroundColor(Color(.systemGray6))
                .cornerRadius(20)
                .overlay {
                    VStack{
                        HStack{
                            Image(systemName: goal2.trimmingCharacters(in: .whitespaces).isEmpty ? "circle":"checkmark.circle.fill")
                                .foregroundColor(.green)
                            TextField("Checkpoint 2 Goal", text: $goal2)
                                .textFieldStyle(.roundedBorder)
                        }
                        DatePicker("Checkpoint 2 Due Date", selection: $checkpoint2, in: Date.now...)
                            .datePickerStyle(.compact)
                    }.padding()
                }
            Rectangle()
                .frame(width: .infinity, height: 150)
                .foregroundColor(Color(.systemGray6))
                .cornerRadius(20)
                .overlay{
                    VStack{
                        HStack{
                            Image(systemName: goal3.trimmingCharacters(in: .whitespaces).isEmpty ? "circle":"checkmark.circle.fill")
                                .foregroundColor(.green)
                            TextField("Checkpoint 3 Goal", text: $goal3)
                                .textFieldStyle(.roundedBorder)
                        }
                        DatePicker("Checkpoint 3 Due Date", selection: $checkpoint3, in: Date.now...)
                            .datePickerStyle(.compact)
                    }.padding()
                }
            Text("Due Date Of Project:")
                .underline()
                .bold()
                .multilineTextAlignment(.center)
            DatePicker("Due Date Of Project",selection: $duedate, in: Date.now...)
                .datePickerStyle(.graphical)
        }.padding()
    }
        .navigationTitle("Create Project")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    ProjectDataController().addProject(name: name, goal1: goal1, goal2: goal2, goal3: goal3, checkpoint1: checkpoint1, checkpoint2: checkpoint2, checkpoint3: checkpoint3, duedate: duedate,startdate: Date.now, context: managedObjContext)
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success{
                            print("All Set For Test!")
                        }else if let error = error{
                            print(error.localizedDescription)
                        }
//                        addtopicusage.toggle()
                        let check1content = UNMutableNotificationContent()
                        check1content.title = goal1
                        check1content.body = "\(goal1) Should Be Complete!"
                        let date = checkpoint1
                        let Check1 = Calendar.current.date(byAdding: .day, value: 0, to: date)
                        check1content.sound = UNNotificationSound.default
                        let check1comp = Calendar.current.dateComponents([.year,.month,.day, .hour, .minute], from: Check1!)

                        let check1trigger = UNCalendarNotificationTrigger(dateMatching: check1comp, repeats: false)
                        let check1request = UNNotificationRequest(identifier: goal1 , content: check1content, trigger: check1trigger)
                        
                        UNUserNotificationCenter.current().add(check1request)
                    }
                    let check2content = UNMutableNotificationContent()
                    check2content.title = goal2
                    check2content.body = "\(goal2) Should Be Completed!"
                    let date = checkpoint2
                    let Check2 = Calendar.current.date(byAdding: .day, value: 0, to: date)
                    check2content.sound = UNNotificationSound.default
                    let check2comp = Calendar.current.dateComponents([.year,.month,.day, .hour,.minute], from: Check2!)
                    
                    let check2trigger  = UNCalendarNotificationTrigger(dateMatching: check2comp, repeats: false)
                    let check2request = UNNotificationRequest(identifier: goal2, content: check2content, trigger: check2trigger)
                    
                    UNUserNotificationCenter.current().add(check2request)
                    
                    let check3content = UNMutableNotificationContent()
                    check3content.title = goal3
                    check3content.body = "\(goal3) Should Be Completed!"
                    let date3 = checkpoint3
                    let Check3 = Calendar.current.date(byAdding: .day, value: 0, to: date3)
                    check3content.sound = UNNotificationSound.default
                    let check3comp = Calendar.current.dateComponents([.year,.month,.day, .hour,.minute], from: Check3!)
                    
                    let check3trigger  = UNCalendarNotificationTrigger(dateMatching: check3comp, repeats: false)
                    let check3request = UNNotificationRequest(identifier: goal3, content: check3content, trigger: check3trigger)
                    
                    UNUserNotificationCenter.current().add(check3request)
                    dismiss()
                } label: {
                    Text("Add")
                }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || goal1.trimmingCharacters(in: .whitespaces).isEmpty || goal2.trimmingCharacters(in: .whitespaces).isEmpty || goal3.trimmingCharacters(in: .whitespaces).isEmpty)

            }
        }
    }
    }
}

struct ProjectCreateView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectCreateView()
    }
}
