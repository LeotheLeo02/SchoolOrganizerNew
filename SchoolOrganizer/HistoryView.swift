//
//  HistoryView.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/9/22.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.assignname)]) var historya: FetchedResults<HistoryA>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateoftest, order: .reverse)]) var completedtest: FetchedResults<CompletedTest>
    var body: some View {
        NavigationView{
            let count = completedtest.isEmpty ? 1 : Int(completedtest.count)
            let average = Int(completedtest.map(\.scoreoftest).reduce(0, +)) / count
            ScrollView{
                VStack{
        ForEach(historya){hisa in
            VStack{
            HStack{
            Text(hisa.assignname!)
                    .bold()
                Spacer()
                Text("A")
                    .font(.system(size: 50, weight: .heavy, design: .rounded))
                    .if(hisa.assigncolor == "Red") { Text in
                        Text.foregroundColor(.red)
                    }
                    .if(hisa.assigncolor == "Blue") { Text in
                        Text.foregroundColor(.blue)
                    }
                    .if(hisa.assigncolor == "Yellow") { Text in
                        Text.foregroundColor(.yellow)
                    }
                Text(hisa.assigndate!, style: .date)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.gray)
                Text(hisa.assigndate!, style: .time)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.gray)
            }.padding()
                
        }.padding()
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .contextMenu{
                Button(role: .destructive) {
                    withAnimation{
                    hisa.managedObjectContext?.delete(hisa)
                        HistoryADataController().save(context: managedObjContext)
                    }
                } label: {
                    Text("Delete")
                    Image(systemName: "trash")
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
                            }.padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(20)
                                .contextMenu{
                                    Button(role: .destructive) {
                                        withAnimation{
                                        com.managedObjectContext?.delete(com)
                                            CompletedTestsDataController().save(context: managedObjContext)
                                        }
                                    } label: {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                    }

                                }
                        }.onDelete(perform: deleteCompletedTest)
                    }header:{
                        if !completedtest.isEmpty{
                            HStack{
                        Text("Completed Tests")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .underline()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
            }
            }.padding()
        .navigationTitle("History")
        .toolbar {
            ToolbarItem(placement: .bottomBar){
                VStack{
                Text("Score Average: \(average)")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .if(average == 0 && completedtest.isEmpty){view in
                        view.foregroundColor(.gray)
                    }
                    .if(average <= 70){view in
                        view.foregroundColor(.red)
                    }
                    .if(average > 70){view in
                        view.foregroundColor(.green)
                    }
                }.padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
            }
        }
    }
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

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
