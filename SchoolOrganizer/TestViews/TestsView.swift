//
//  TestsView.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI

struct TestsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.score)]) var test: FetchedResults<Tests>
    @Environment(\.managedObjectContext) var managedObjContext
    @State private var AddTest = false
    @State private var Delete = false
    var body: some View {
        NavigationView{
            ScrollView{
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
        }.sheet(isPresented: $AddTest, content: {
                AddTestView()
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
        }
    }
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
}

struct TestsView_Previews: PreviewProvider {
    static var previews: some View {
        TestsView()
    }
}
