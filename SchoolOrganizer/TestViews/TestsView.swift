//
//  TestsView.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI

struct TestsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.testdate)]) var test: FetchedResults<Tests>
    @Environment(\.managedObjectContext) var managedObjContext
    @State private var AddTest = false
    @State private var Delete = false
    var body: some View {
        NavigationView{
            List{
                ForEach(test){tes in
                    NavigationLink(destination: EditTestView(test: tes)){
                    let days = daysBetween(start: Date.now, end: tes.testdate ?? Date.now)
                    if days >= 7 && days < 14{
                        VStack(alignment: .leading){
                        HStack{
                        Text(tes.testname!)
                            Spacer()
                            if tes.score != 0{
                            Text("\(tes.score)")
                                    .if(tes.score < 70){ view in
                                        view.foregroundColor(.red)
                                }
                                    .if(tes.score >= 70){ view in
                                        view.foregroundColor(.green)
                                    }
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                            }else{
                            Text("Test is next week, start studying soon.")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                                .allowsTightening(true)
                            }
                        }
                            HStack{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    } else if days >= 14{
                        VStack(alignment: .leading){
                        HStack{
                        Text(tes.testname!)
                            Spacer()
                            if tes.score != 0{
                                Text("\(tes.score)")
                                    .if(tes.score < 70){ view in
                                        view.foregroundColor(.red)
                                }
                                    .if(tes.score >= 70){ view in
                                        view.foregroundColor(.green)
                                    }
                                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                            }else{
                            Text("No need to worry, this is test is pretty far")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .allowsTightening(true)
                            }
                        }
                            HStack{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    if days < 7 && days > 3 {
                        VStack(alignment: .leading){
                        HStack{
                        Text(tes.testname!)
                            Spacer()
                            if tes.score != 0{
                                Text("\(tes.score)")
                                    .if(tes.score < 70){ view in
                                        view.foregroundColor(.red)
                                }
                                    .if(tes.score >= 70){ view in
                                        view.foregroundColor(.green)
                                    }
                                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                            }else{
                            Text("Test is less than 7 days away, be ready.")
                                .foregroundColor(.yellow)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .allowsTightening(true)
                            }
                        }
                            HStack{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    if days <= 3{
                        VStack(alignment: .leading){
                        HStack{
                        Text(tes.testname!)
                            Spacer()
                            if tes.score != 0 {
                            Text("\(tes.score)")
                                    .if(tes.score < 70){ view in
                                        view.foregroundColor(.red)
                                }
                                    .if(tes.score >= 70){ view in
                                        view.foregroundColor(.green)
                                    }
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                            }else{
                            Text("Test is coming really soon!")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                            }
                        }
                            HStack{
                            Text(tes.testdate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                .bold()
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                }.onDelete(perform: deleteTest)
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
    private func deleteTest(offsets: IndexSet) {
        withAnimation {
            offsets.map { test[$0] }
            .forEach(managedObjContext.delete)
            TestDataController().save(context: managedObjContext)
        }
    }
}

struct TestsView_Previews: PreviewProvider {
    static var previews: some View {
        TestsView()
    }
}
