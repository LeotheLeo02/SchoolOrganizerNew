//
//  AssignIndiviualTopicView.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/11/22.
//

import SwiftUI

struct AssignIndiviualTopicView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.score)]) var test: FetchedResults<Tests>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topicname)]) var topic: FetchedResults<Topics>
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjContext
    @Binding var topicname: String
    @State private var newtopic = ""
    @State private var editing = false
    @State private var exits = false
    var body: some View {
        NavigationView{
        VStack{
        ForEach(assignment){assign in
            if assign.topic == topicname{
                Section{
                VStack{
                    HStack{
                Text(assign.name!)
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .onTapGesture {
                            withAnimation{
                            if !editing{
                                AssignmentDataController().editAssignTopic(assign: assign, changedtopic: true, context: managedObjContext)
                                editing = true
                            }
                            }
                        }
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
                    if assign.book{
                        Image(systemName: "book.closed.fill")
                            .font(.title)
                    }
                    Text((assign.topic?.trimmingCharacters(in: .whitespaces).isEmpty)! ? "" : assign.topic!)
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.gray)
                    if editing && assign.changedtopic{
                    TextField("New Assigned topic", text: $newtopic)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        withAnimation{
                            if !exits{
                                TopicDataController().addTopic(topicname: newtopic, context: managedObjContext)
                            }
                        AssignmentDataController().editAssignTopicName(assign: assign, topic: newtopic, changedtopic: false, context: managedObjContext)
                            editing = false
                            newtopic = ""
                        }
                    } label: {
                        HStack{
                            Spacer()
                        Text("Submit")
                            Spacer()
                        }
                    }
                    }
                }.padding()
                }
            }
        }
            ForEach(test){tes in
                if tes.testtopic == topicname{
                    Section{
                    VStack{
                    Text(tes.testname!)
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .onTapGesture {
                                if !editing{
                                    withAnimation{
                                TestDataController().editTestTopic(test: tes, changedtopic: true, context: managedObjContext)
                                editing = true
                                    }
                                }
                            }
                        Text((tes.testtopic?.trimmingCharacters(in: .whitespaces).isEmpty)! ? "" : tes.testtopic!)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(.gray)
                        if tes.changedtopic && editing{
                        TextField("New Assigned topic", text: $newtopic)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            withAnimation{
                                if !exits{
                                    TopicDataController().addTopic(topicname: newtopic, context: managedObjContext)
                                }
                            TestDataController().editTestTopicName(test: tes, testtopic: newtopic, changedtopic: false, context: managedObjContext)
                                editing = false
                                newtopic = ""
                            }
                        } label: {
                            HStack{
                                Spacer()
                            Text("Submit")
                                Spacer()
                            }
                        }
                        }
                    }.padding()
                    }
                }
            }
            if !topic.isEmpty{
            Divider()
            Text("Existing Topics:")
                .bold()
                .underline()
            }
            ForEach(topic){top in
                Button {
                    newtopic = top.topicname!
                } label: {
                    Text(top.topicname!)
                }.buttonStyle(.bordered)
                .onChange(of: newtopic) { newValue in
                    if newtopic == top.topicname{
                        exits = true
                    }else{
                        exits = false
                    }
                }

            }
        }.padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .navigationTitle("Reassign")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }

            }
        }
    }
        .navigationViewStyle(.stack)
    }
}
