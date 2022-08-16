//
//  TestsView.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI

struct TestsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.score)]) var test: FetchedResults<Tests>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topicname)]) var topic: FetchedResults<Topics>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @Environment(\.managedObjectContext) var managedObjContext
    @State private var AddTest = false
    @State private var Delete = false
    @State private var filter  = false
    @State private var filtername = ""
    @State private var reconfigure = false
    @State private var Study = false
    @Binding var Background: Color
    var body: some View {
        NavigationView{
            ScrollView{
                if test.isEmpty{
                    HStack{
                        StrokeText(text: "No Upcoming Assignments", width: 0.2, color: .black)
                        .font(.system(size: 25, weight: .heavy, design: .rounded))
                        .foregroundColor(.gray)
                        Image(systemName:"checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }.padding()
                }
                if filter{
                Section{
                ForEach(test){tes in
                    if tes.testtopic == filtername{
                    NavigationLink(destination: EditTestView(test: tes)){
                    let days = daysBetween(start: Date.now, end: tes.testdate ?? Date.now)
                    if days >= 7 && days < 14{
                        VStack(alignment: .leading){
                        HStack{
                        Text(tes.testname!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Spacer()
                            Text("Test is next week, start studying soon.")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                                .allowsTightening(true)
                            
                        }
                            HStack{
                                if tes.score == 0{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                .foregroundColor(.gray)
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                }
                            }
                            HStack{
                            Text("Score")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                Image(systemName: "square.and.pencil")
                                    .font(.title3)
                            }.padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            HStack{
                                Spacer()
                            Text(tes.testtopic!)
                                    .foregroundColor(.green)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(20)
                                Spacer()
                            }
                            Divider()
                        }.padding()
                    } else if days >= 14{
                        VStack(alignment: .leading){
                        HStack{
                        Text(tes.testname!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Spacer()
                            Text("No need to worry, this is test is pretty far")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .allowsTightening(true)
                            
                        }
                            HStack{
                                if tes.score == 0{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                .foregroundColor(.gray)
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.title3)
                                }
                            }
                            HStack{
                            Text("Score")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                Image(systemName: "square.and.pencil")
                                    .font(.title3)
                            }.padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            HStack{
                                Spacer()
                            Text(tes.testtopic!)
                                    .foregroundColor(.green)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(20)
                                Spacer()
                            }
                            Divider()
                        }.padding()
                    }
                    if days < 7 && days > 3 {
                        VStack(alignment: .leading){
                        HStack{
                        Text(tes.testname!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Spacer()
                            Text("Test is less than 7 days away, be ready.")
                                .foregroundColor(.yellow)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .allowsTightening(true)
                            
                        }
                            HStack{
                                if tes.score == 0{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                .foregroundColor(.gray)
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.yellow)
                                    .font(.title)
                                }
                            }
                            HStack{
                            Text("Score")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                Image(systemName: "square.and.pencil")
                                    .font(.title3)
                            }.padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            HStack{
                                Spacer()
                            Text(tes.testtopic!)
                                    .foregroundColor(.green)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(20)
                                Spacer()
                            }
                            Divider()
                        }.padding()
                    }
                    if days <= 3{
                        VStack(alignment: .leading){
                        HStack{
                        Text(tes.testname!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Spacer()
                            Text("Test is coming really soon!")
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                            HStack{
                                if tes.score == 0{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                .foregroundColor(.gray)
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.largeTitle)
                                }
                            }
                            HStack{
                            Text("Score")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                Image(systemName: "square.and.pencil")
                                    .font(.title3)
                            }.padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            HStack{
                                Spacer()
                            Text(tes.testtopic!)
                                    .foregroundColor(.green)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(20)
                                Spacer()
                            }
                            Divider()
                        }.padding()
                    }
                }
                }
                }
                }header:{
                    if !test.isEmpty{
                        HStack{
                    Text("Upcoming Tests")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .underline()
                            Image(systemName: "calendar")
                    }
                    }
                }
                }else{
                Section{
                ForEach(test){tes in
                    NavigationLink(destination: EditTestView(test: tes)){
                    let days = daysBetween(start: Date.now, end: tes.testdate ?? Date.now)
                    if days >= 7 && days < 14{
                        VStack(alignment: .leading){
                        HStack{
                        Text(tes.testname!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Spacer()
                            Text("Test is next week, start studying soon.")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                                .allowsTightening(true)
                            
                        }
                            HStack{
                                if tes.score == 0{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                .foregroundColor(.gray)
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                }
                            }
                            HStack{
                            Text("Score")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                Image(systemName: "square.and.pencil")
                                    .font(.title3)
                            }.padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            HStack{
                                Spacer()
                            Text(tes.testtopic!)
                                    .foregroundColor(.green)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(20)
                                Spacer()
                            }
                            Divider()
                        }.padding()
                    } else if days >= 14{
                        VStack(alignment: .leading){
                        HStack{
                        Text(tes.testname!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Spacer()
                            Text("No need to worry, this is test is pretty far")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .allowsTightening(true)
                            
                        }
                            HStack{
                                if tes.score == 0{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                .foregroundColor(.gray)
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.title3)
                                }
                            }
                            HStack{
                            Text("Score")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                Image(systemName: "square.and.pencil")
                                    .font(.title3)
                            }.padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            HStack{
                                Spacer()
                            Text(tes.testtopic!)
                                    .foregroundColor(.green)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(20)
                                Spacer()
                            }
                            Divider()
                        }.padding()
                    }
                    if days < 7 && days > 3 {
                        VStack(alignment: .leading){
                        HStack{
                        Text(tes.testname!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Spacer()
                            Text("Test is less than 7 days away, be ready.")
                                .foregroundColor(.yellow)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .allowsTightening(true)
                            
                        }
                            HStack{
                                if tes.score == 0{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                .foregroundColor(.gray)
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.yellow)
                                    .font(.title)
                                }
                            }
                            HStack{
                            Text("Score")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                Image(systemName: "square.and.pencil")
                                    .font(.title3)
                            }.padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            HStack{
                                Spacer()
                            Text(tes.testtopic!)
                                    .foregroundColor(.green)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(20)
                                Spacer()
                            }
                            Divider()
                        }.padding()
                    }
                    if days <= 3{
                        VStack(alignment: .leading){
                        HStack{
                        Text(tes.testname!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Spacer()
                            Text("Test is coming really soon!")
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                            HStack{
                                if tes.score == 0{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                .foregroundColor(.gray)
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.largeTitle)
                                }
                            }
                            HStack{
                            Text("Score")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                Image(systemName: "square.and.pencil")
                                    .font(.title3)
                            }.padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            HStack{
                                Spacer()
                            Text(tes.testtopic!)
                                    .foregroundColor(.green)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(20)
                                Spacer()
                            }
                            Divider()
                        }.padding()
                    }
                }
                }
                }header:{
                    if !test.isEmpty{
                        HStack{
                    Text("Upcoming Tests")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .underline()
                            Image(systemName: "calendar")
                    }
                    }
                }
            }
                
            }.frame(maxWidth: .infinity,maxHeight: .infinity)
            .background(Background)
            .sheet(isPresented: $AddTest, content: {
                AddTestView()
            })
        .sheet(isPresented: $reconfigure, content: {
            ChangeAllTopicsView()
        })
        .sheet(isPresented: $Study, content: {
            StudySessionsView()
        })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        AddTest.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                    }

                }
            }
            .navigationTitle("Tests")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Menu {
                        ForEach(topic){top in
                            Button {
                                withAnimation{
                                filtername = top.topicname!
                                filter = true
                                }
                            } label: {
                                Text(top.topicname!)
                                if filtername == top.topicname!{
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        Button {
                            withAnimation{
                            filter = false
                            }
                        } label: {
                            Text("All")
                            if filter == false{
                                Image(systemName: "checkmark")
                            }
                        }
                        if !topic.isEmpty{
                        Button(role: .destructive){
                            if !test.isEmpty || !assignment.isEmpty{
                                reconfigure.toggle()
                            }
                            withAnimation {
                                topic
                                .forEach(managedObjContext.delete)
                                
                                TopicDataController().save(context: managedObjContext)
                            }
                        }label:{
                            Text("Delete All")
                            Image(systemName: "trash")
                        }
                    }
                    } label: {
                        Image(systemName: filter ? "line.3.horizontal.decrease.circle.fill":"line.3.horizontal.decrease.circle")
                    }

                }
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        Study.toggle()
                    } label: {
                        Image(systemName: "rectangle.fill.badge.person.crop")
                    }

                }
            }
        }
        .navigationViewStyle(.stack)
    }
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
}

