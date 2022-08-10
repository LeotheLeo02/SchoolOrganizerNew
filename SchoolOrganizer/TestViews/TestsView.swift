//
//  TestsView.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI

struct TestsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.score)]) var test: FetchedResults<Tests>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateoftest, order: .reverse)]) var completedtest: FetchedResults<CompletedTest>
    @Environment(\.managedObjectContext) var managedObjContext
    @State private var AddTest = false
    @State private var Delete = false
    var body: some View {
        NavigationView{
            let count = completedtest.isEmpty ? 1 : Int(completedtest.count)
            let average = Int(completedtest.map(\.scoreoftest).reduce(0, +)) / count
            Form{
            List{
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
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                                .allowsTightening(true)
                            
                        }
                            HStack{
                                if tes.score == 0{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.green)
                                }
                            }
                        }
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
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.gray)
                                }
                            }
                        }
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
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .allowsTightening(true)
                            
                        }
                            HStack{
                                if tes.score == 0{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.yellow)
                                }
                            }
                        }
                    }
                    if days <= 3{
                        VStack(alignment: .leading){
                        HStack{
                        Text(tes.testname!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Spacer()
                            Text("Test is coming really soon!")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                            HStack{
                                if tes.score == 0{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                }
            }
                Section{
                    ForEach(completedtest){com in
                        VStack(alignment: .leading){
                        HStack{
                        Text(com.nameoftest!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Spacer()
                            VStack{
                                if com.hidescore{
                                    Image(systemName: "eye.slash")
                                        .foregroundColor(.gray)
                                        .font(.title)
                                }else{
                            Text("\(Int(com.scoreoftest))")
                                .if(com.scoreoftest < 70){ view in
                                    view.foregroundColor(.red)
                            }
                                .if(com.scoreoftest >= 70){ view in
                                    view.foregroundColor(.green)
                                }
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                                if com.scoreoftest >= 90{
                                    Image(systemName: "rosette")
                                        .font(.title)
                                        .foregroundColor(.yellow)
                                }
                            }
                                if com.scoreoftest < 70{
                                    Spacer()
                                    if !com.hidescore{
                                    Button {
                                        withAnimation{
                                        CompletedTestsDataController().editTestView(completedtest: com, hidescore: true, context: managedObjContext)
                                        }
                                    } label: {
                                        HStack{
                                        Text("Hide Score")
                                        Image(systemName: "eye.slash")
                                        }
                                    }.buttonStyle(.bordered)
                                    }else{
                                        Button {
                                            withAnimation{
                                            CompletedTestsDataController().editTestView(completedtest: com, hidescore: false, context: managedObjContext)
                                            }
                                        } label: {
                                            HStack{
                                            Text("Show Score")
                                            Image(systemName: "eye")
                                            }
                                        }.buttonStyle(.borderedProminent)
                                    }
                                }
                            }
                        }
                            Text(com.dateoftest!, style: .date)
                                .font(.system(size: 13, weight: .heavy, design: .serif))
                            Text(com.dateoftest!, style: .time)
                                .font(.system(size: 13, weight: .heavy, design: .serif))
                        }
                    }.onDelete(perform: deleteCompletedTest)
                }header:{
                    if !completedtest.isEmpty{
                    Text("Completed Tests")
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
                ToolbarItem(placement: .bottomBar){
                    Text("Score Average: \(average)")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                }
            }
            .navigationTitle("Tests")
        }
    }
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    private func deleteCompletedTest(offsets: IndexSet) {
        withAnimation {
            offsets.map { completedtest[$0] }
            .forEach(managedObjContext.delete)
            
            // Saves to our database
            CompletedTestsDataController().save(context: managedObjContext)
        }
    }
}

struct TestsView_Previews: PreviewProvider {
    static var previews: some View {
        TestsView()
    }
}
