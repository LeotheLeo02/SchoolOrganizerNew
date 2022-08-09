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
    @Environment(\.dismiss) var dismiss
    @State private var newtopic = ""
    @State private var done = false
    @State private var editing = false
    @State private var nothing = false
    var body: some View {
        NavigationView{
        Form{
            ForEach(assignment){assign in
                Section{
                    HStack{
                    VStack{
                        if !editing{
                    Text(assign.name!)
                                .if(!assign.topic!.trimmingCharacters(in: .whitespaces).isEmpty){ view in
                                    view.foregroundColor(.green)
                                }

                            .onTapGesture {
                                withAnimation{
                                    if assign.topic == "" {
                                AssignmentDataController().editAssignTopic(assign: assign, changedtopic: true, context: managedObjContext)
                                    newtopic = assign.topic!
                                editing = true
                                    }
                                }
                            }
                        }
                        if assign.changedtopic && editing{
                        TextField("New Assigned Topic", text: $newtopic)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: newtopic, perform: { V in
                                if !newtopic.trimmingCharacters(in: .whitespaces).isEmpty{
                                    nothing = false
                                }
                            })
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
                            Text(assign.name!)
                                .foregroundColor(.gray)
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
                        Text(assign.name!)
                    }
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
    }
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct ChangeAllTopicsView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeAllTopicsView()
    }
}
