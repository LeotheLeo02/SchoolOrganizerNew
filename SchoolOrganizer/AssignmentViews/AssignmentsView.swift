//
//  ContentView.swift
//  SchoolKit
//
//  Created by Nate on 7/31/22.
//

import SwiftUI

struct AssignmentsView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.foldername)]) var folder: FetchedResults<Folder>
    @Environment(\.dismiss) var dismiss
    @State private var Add = false
    @State private var Schedule = false
    @State private var addfolder = false
    @State private var foldername = ""
    @State private var editname = false
    @State private var showFolder = false
   private let adaptiveColumns = [
    GridItem(.adaptive(minimum: 160))
   ]
    var body: some View{
        NavigationView{
            ScrollView{
                if addfolder{
                    VStack{
                        TextField("Folder Name", text: $foldername)
                            .onSubmit {
                                FolderDataController().addFolder(foldername: foldername, context: managedObjContext)
                                addfolder = false
                            }
                            .textFieldStyle(.roundedBorder)
                    }.padding()
                }
                LazyVGrid(columns: adaptiveColumns) {
                    ForEach(assignment){assign in
                        VStack{
                        NavigationLink(destination: EditAssignment(assignment: assign)){
                            Rectangle()
                                .frame(width: 160, height: 160)
                                .cornerRadius(30)
                                .if(assign.color == "Blue"){view in
                                    view.foregroundColor(.blue)
                                }
                                .if(assign.color == "Yellow"){ view in
                                    view.foregroundColor(.yellow)
                                }
                                .if(assign.color == "Red"){ view in
                                    view.foregroundColor(.red)
                                }
                                .overlay {
                                    VStack{
                                        let days = daysBetween(start: Date.now, end: assign.duedate!)
                                    Text(assign.topic!)
                                            .fontWeight(.light)
                                        .foregroundColor(.white)
                                        Text(assign.name!)
                                            .fontWeight(.heavy)
                                            .foregroundColor(.white)
                                        Text(assign.duedate?.addingTimeInterval(600) ?? Date.now, style: .date)
                                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                                            .if(days >= 7){ view in
                                                view.foregroundColor(.green)
                                            }
                                            .if( days < 7 && days > 3){ view in
                                                view.foregroundColor(.yellow)
                                            }
                                            .if(days <= 3){ view in
                                                view.foregroundColor(.red)
                                            }
                                            .padding()
                                            .background(Color(.systemGray4))
                                            .cornerRadius(20)
                                    }
                                }
                                .navigationViewStyle(.stack)
                    }
                            Rectangle()
                                .foregroundColor(Color(.systemGray6))
                                .frame(width: assign.complete ? 175 : 160, height: 50)
                                .animation(.spring(), value: assign.complete)
                                .cornerRadius(20)
                                .overlay{
                            Button {
                                assign.complete.toggle()
                                AssignmentDataController().editAssign(assign: assign, complete: assign.complete, context: managedObjContext)
                                if assign.complete{
                                    simpleSuccess()
                                }
                            } label: {
                                HStack{
                                    Image(systemName: assign.complete ? "checkmark.circle.fill" : "circle")
                                        .font(.largeTitle)
                                    .foregroundColor(.green)
                                }
                            }
                                }
                    }
                    }
                }
            }.sheet(isPresented: $showFolder, content: {
                FolderView()
            })
            .sheet(isPresented: $Add, content: {
                AddAssignment()
            })
            .navigationTitle("Assignments")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Add.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                    }

                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        Schedule.toggle()
                    } label: {
                        HStack{
                        Text("View Schedule")
                        Image(systemName: "calendar")
                        }
                    }.disabled(assignment.isEmpty)
                        .buttonStyle(.borderedProminent)
                    .sheet(isPresented: $Schedule) {
                        AssignmentScheduleDetails()
                    }

                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if folder.isEmpty{
                        Button {
                            withAnimation{
                            addfolder.toggle()
                            }
                        } label: {
                            Image(systemName: "folder.fill.badge.plus")
                                .font(.title)
                        }
                    }else{
                    ForEach(folder){fol in
                        Button {
                            showFolder.toggle()
                        } label: {
                        VStack{
                            Image(systemName: "folder.fill")
                                .font(.title2)
                            Text(fol.foldername!)
                                .multilineTextAlignment(.center)
                                .font(.caption)
                                .onLongPressGesture {
                                    withAnimation{
                                    deleteFolder()
                                    addfolder.toggle()
                                    }
                                }
                        }
                        }
                    }
                }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        addfolder.toggle()
                        deleteFolder()
                    } label: {
                        Text("Edit")
                    }.disabled(folder.isEmpty)

                }
            }
        }
    }
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    private func deleteFolder() {
        withAnimation {
            folder
            .forEach(managedObjContext.delete)
            
            // Saves to our database
            FolderDataController().save(context: managedObjContext)
        }
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        AssignmentsView()
    }
}
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
