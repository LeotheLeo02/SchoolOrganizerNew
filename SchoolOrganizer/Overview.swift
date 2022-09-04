//
//  Overview.swift
//  SchoolOrganizerPlus
//
//  Created by Nate on 9/4/22.
//

import SwiftUI

struct Overview: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var assignment: FetchedResults<Assignment>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.testname)]) var test: FetchedResults<Tests>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var session: FetchedResults<StudySessions>
    @State private var notoday = true
    @State private var notomorrow = true
    var body: some View {
        NavigationView{
        ScrollView{
            VStack{
                Section {
                    if notoday{
                        HStack{
                        Text("No Assignments Or Tests Today")
                            .underline()
                            .italic()
                            .bold()
                            .foregroundColor(.gray)
                        }.padding()
                    }
                    ForEach(test){tes in
                        let hours = daysBetween(start: Date.now, end: tes.testdate!)
                        if hours <= 24 && hours >= 0{
                            HStack{
                            Text(tes.testname!)
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                            Text(tes.testdate!, style: .time)
                                .bold()
                                .foregroundColor(.white)
                            Image(systemName: "doc.on.clipboard")
                                    .foregroundColor(.white)
                            }.padding()
                            .background(Color(.systemGray2))
                            .cornerRadius(20)
                            .padding()
                            .onAppear(){
                                notoday = false
                            }
                            .onDisappear(){
                                notoday = true
                            }
                        }
                    }
                    ForEach(assignment){assign in
                        let hours = daysBetween(start: Date.now, end: assign.duedate!)
                        if hours <= 24 && hours >= 0{
                            HStack{
                                Text(assign.name!)
                                    .bold()
                                    .foregroundColor(.white)
                                Spacer()
                                Text(assign.duedate!, style: .time)
                                    .bold()
                                    .foregroundColor(.white)
                                Image(systemName: "doc.plaintext.fill")
                                    .foregroundColor(.white)
                            }.padding()
                            .if(assign.color == "Blue"){view in
                                view.background(.blue)
                            }
                            .if(assign.color == "Green"){ view in
                                view.background(.green)
                            }
                            .if(assign.color == "Red"){ view in
                                view.background(.red)
                            }
                            .if(assign.color == "Purple"){ view in
                                view.background(.purple)
                            }
                            .cornerRadius(20)
                            .padding()
                            .onAppear(){
                                notoday = false
                            }
                            .onDisappear(){
                                notoday = true
                            }
                        }
                    }
                } header: {
                    Text("Today:")
                        .underline()
                        .font(.system(.largeTitle, design: .rounded))
                        .bold()
                }
                Divider()
                Section {
                    if notomorrow{
                        HStack{
                        Text("No Assignments Or Tests Tomorrow")
                            .underline()
                            .italic()
                            .bold()
                            .foregroundColor(.gray)
                        }.padding()
                    }
                    ForEach(test){tes in
                        let hours = daysBetween(start: Date.now, end: tes.testdate!)
                        if hours > 24 && hours <= 48{
                            HStack{
                            Text(tes.testname!)
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                            Text(tes.testdate!, style: .time)
                                .bold()
                                .foregroundColor(.white)
                            Image(systemName: "doc.on.clipboard")
                                    .foregroundColor(.white)
                            }.padding()
                            .background(Color(.systemGray2))
                            .cornerRadius(20)
                            .padding()
                            .onAppear(){
                                notomorrow = false
                            }
                            .onDisappear(){
                                notomorrow = true
                            }
                        }
                    }
                    ForEach(assignment){assign in
                        let hours = daysBetween(start: Date.now, end: assign.duedate!)
                        if hours > 24 && hours <= 48{
                            HStack{
                                Text(assign.name!)
                                    .bold()
                                    .foregroundColor(.white)
                                Spacer()
                                Text(assign.duedate!, style: .time)
                                    .bold()
                                    .foregroundColor(.white)
                                Image(systemName: "doc.plaintext.fill")
                                    .foregroundColor(.white)
                            }.padding()
                            .if(assign.color == "Blue"){view in
                                view.background(.blue)
                            }
                            .if(assign.color == "Green"){ view in
                                view.background(.green)
                            }
                            .if(assign.color == "Red"){ view in
                                view.background(.red)
                            }
                            .if(assign.color == "Purple"){ view in
                                view.background(.purple)
                            }
                            .cornerRadius(20)
                            .padding()
                            .onAppear(){
                                notomorrow = false
                            }
                            .onDisappear(){
                                notomorrow = true
                            }
                        }
                    }
                } header: {
                    Text("Tomorrow:")
                        .underline()
                        .font(.system(.largeTitle, design: .rounded))
                        .bold()
                }

            }
        }
        .navigationTitle("Overview")
        }
    }
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: start, to: end).hour!
    }
}
