//
//  ChangeAllTopicsView.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/9/22.
//

import SwiftUI

struct ChangeAllTopicsView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.changedtopic)]) var assignment: FetchedResults<Assignment>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topicname)]) var topic: FetchedResults<Topics>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.score)]) var test: FetchedResults<Tests>
    @Environment(\.dismiss) var dismiss
    @State private var newtopic = ""
    @State private var done = false
    @State private var editing = false
    @State private var nothing = false
    @State private var editingtest = false
    var body: some View {
        NavigationView{
        VStack{
            ForEach(assignment){assign in
                Section{
                    HStack{
                    VStack{
                        if !editing{
                            HStack{
                    Text(assign.name!)
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Text("A")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .if(assign.color == "Red") { Text in
                                    Text.foregroundColor(.red)
                                }
                                .if(assign.color == "Blue") { Text in
                                    Text.foregroundColor(.blue)
                                }
                                .if(assign.color == "Yellow") { Text in
                                    Text.foregroundColor(.yellow)
                                }
                                .if(!assign.topic!.trimmingCharacters(in: .whitespaces).isEmpty){ view in
                                    view.foregroundColor(.green)
                                }
                            }

                            .onTapGesture {
                                withAnimation{
                                    if assign.topic == "" && !editingtest {
                                AssignmentDataController().editAssignTopic(assign: assign, changedtopic: true, context: managedObjContext)
                                    newtopic = assign.topic!
                                editing = true
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        }
                        if assign.changedtopic && editing{
                        TextField("New Assigned Topic", text: $newtopic)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: newtopic, perform: { V in
                                if !newtopic.trimmingCharacters(in: .whitespaces).isEmpty{
                                    nothing = false
                                }
                            })
                            .padding()
                            .onSubmit {
                                if !newtopic.trimmingCharacters(in: .whitespaces).isEmpty{
                                withAnimation{
                                simpleSuccess()
                                AssignmentDataController().editAssignTopicName(assign: assign, topic: newtopic, changedtopic: false, context: managedObjContext)
                                    TopicDataController().addTopic(topicname: newtopic, context: managedObjContext)
                                editing = false
                                }
                            }else{
                                nothing = true
                            }
                            }
                            if nothing{
                            Text("Cannot Submit Nothing")
                                .bold()
                                .foregroundColor(.red)
                                .underline()
                            }
                        }
                        if !assign.changedtopic && editing{
                            HStack{
                            Text(assign.name!)
                                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                                .foregroundColor(.gray)
                                Text("A")
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .if(assign.color == "Red") { Text in
                                        Text.foregroundColor(.red)
                                    }
                                    .if(assign.color == "Blue") { Text in
                                        Text.foregroundColor(.blue)
                                    }
                                    .if(assign.color == "Yellow") { Text in
                                        Text.foregroundColor(.yellow)
                                    }
                                    .if(!assign.topic!.trimmingCharacters(in: .whitespaces).isEmpty){ view in
                                        view.foregroundColor(.green)
                                    }
                            }
                        }
                    }
                        if !assign.topic!.trimmingCharacters(in: .whitespaces).isEmpty{
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(assign.topic!)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }.onAppear(){
                        assign.topic = ""
                        assign.changedtopic = false
                    }
                }header: {
                    if assign.changedtopic{
                        HStack{
                        Text(assign.name!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Text("A")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .if(assign.color == "Red") { Text in
                                    Text.foregroundColor(.red)
                                }
                                .if(assign.color == "Blue") { Text in
                                    Text.foregroundColor(.blue)
                                }
                                .if(assign.color == "Yellow") { Text in
                                    Text.foregroundColor(.yellow)
                                }
                                .if(!assign.topic!.trimmingCharacters(in: .whitespaces).isEmpty){ view in
                                    view.foregroundColor(.green)
                                }
                        }.padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                    }
                }
            }
            Section{
                ChangeTestTopics(editing: $editingtest ,assignmentediting: $editing)
            }header: {
                if !test.isEmpty{
                Text("Tests")
                }
            }
            Section {
                ForEach(topic){top in
                    Button {
                        
                    } label: {
                        HStack{
                            Spacer()
                        Text(top.topicname!)
                            Spacer()
                        }
                    }.tint(.green)
                        .buttonStyle(.bordered)
                }
            } header: {
                Text("Added Topics")
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction){
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }
                //Maybe add restrictions later

            }
        }
        .navigationTitle("Reassign")
    }
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
struct ChangeTestTopics: View{
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.score)]) var test: FetchedResults<Tests>
    @State private var newtopic = ""
    @State private var done = false
    @Binding var editing: Bool
    @State private var nothing = false
    @Binding var assignmentediting: Bool
    var body: some View{
        VStack{
            ForEach(test){tes in
                Section{
                    HStack{
                    VStack{
                        if !editing{
                    Text(tes.testname!)
                                .if(!tes.testtopic!.trimmingCharacters(in: .whitespaces).isEmpty){ view in
                                    view.foregroundColor(.green)
                                }

                            .onTapGesture {
                                withAnimation{
                                    if tes.testtopic == "" && !assignmentediting {
                                TestDataController().editTestTopic(test: tes, changedtopic: true, context: managedObjContext)
                                    newtopic = tes.testtopic!
                                editing = true
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        }
                        if tes.changedtopic && editing{
                        TextField("New Assigned Topic", text: $newtopic)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: newtopic, perform: { V in
                                if !newtopic.trimmingCharacters(in: .whitespaces).isEmpty{
                                    nothing = false
                                }
                            })
                            .padding()
                            .onSubmit {
                                if !newtopic.trimmingCharacters(in: .whitespaces).isEmpty{
                                withAnimation{
                                simpleSuccess()
                                    TestDataController().editTestTopicName(test: tes, testtopic: newtopic, changedtopic: false, context: managedObjContext)
                                    TopicDataController().addTopic(topicname: newtopic, context: managedObjContext)
                                editing = false
                                }
                            }else{
                                nothing = true
                            }
                            }
                            if nothing{
                            Text("Cannot Submit Nothing")
                                .bold()
                                .foregroundColor(.red)
                                .underline()
                            }
                        }
                        if !tes.changedtopic && editing{
                            Text(tes.testname!)
                                .foregroundColor(.gray)
                        }
                    }
                        if !tes.testtopic!.trimmingCharacters(in: .whitespaces).isEmpty{
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(tes.testtopic!)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }.onAppear(){
                        tes.testtopic = ""
                        tes.changedtopic = false
                    }
                }header: {
                    if tes.changedtopic{
                        Text(tes.testname!)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                    }
                }
            }
    }
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
