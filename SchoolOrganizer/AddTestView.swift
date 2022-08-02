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
    @State private var testname = ""
    @State private var testtopic = ""
    @State private var addtopic = false
    @State private var newtopic = ""
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    Section {
                        TextField("Test Name...", text: $testname)
                    } header: {
                        Text("Test Name")
                    }
                    
                    Section {
                        Text(testtopic)
                        ScrollView(.horizontal){
                            HStack{
                                if !topic.isEmpty{
                                    ForEach(topic){top in
                                        Button {
                                            testtopic = top.topicname!
                                        } label: {
                                            Text(top.topicname!)
                                        }.buttonStyle(.bordered)
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
                                }

                            }
                        }
                        if addtopic{
                            TextField("Enter New Topic Name", text: $newtopic)
                                .onSubmit {
                                    TopicDataController().addTopic(topicname: newtopic, context: managedObjContext)
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
                        } label: {
                            Text("Delete All Topics")
                                .foregroundColor(.red)
                                .bold()
                        }.buttonStyle(.bordered)

                    }


                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        TestDataController().addTest(testname: testname, topic: testtopic, context: managedObjContext)
                        dismiss()
                    } label: {
                        Text("Confirm")
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
