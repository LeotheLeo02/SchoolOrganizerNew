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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topicname)]) var topic: FetchedResults<Topics>
    @Environment(\.dismiss) var dismiss
    @State private var Add = false
    @State private var Schedule = false
    @State private var foldername = ""
    @State private var editname = false
    @State private var showFolder = false
    @State private var filter = false
    @State private var filtername = ""
    @State private var search = false
   private let adaptiveColumns = [
    GridItem(.adaptive(minimum: 160))
   ]
    var body: some View{
        NavigationView{
            ScrollView{
                LazyVGrid(columns: adaptiveColumns) {
                    ForEach(assignment){assign in
                        if filter{
                            if assign.topic == filtername{
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
                                    Button {
                                        assign.complete.toggle()
                                        AssignmentDataController().editAssign(assign: assign, complete: assign.complete, context: managedObjContext)
                                        if assign.complete{
                                            simpleSuccess()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                withAnimation{
                                                    if assign.complete != false{
                                                    UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                                                        var identifiers: [String] = [assign.name!]
                                                       for notification:UNNotificationRequest in notificationRequests {
                                                           if notification.identifier == "identifierCancel" {
                                                              identifiers.append(notification.identifier)
                                                           }
                                                       }
                                                       UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                                                        print("Deleted Notifcation")
                                                    }
                                                assign.managedObjectContext?.delete(assign)
                                                    AssignmentDataController().save(context: managedObjContext)
                                                }
                                            }
                                            }
                                        }
                                    } label: {
                                        HStack{
                                            Image(systemName: assign.complete ? "checkmark.circle.fill" : "circle")
                                                .font(.largeTitle)
                                            .foregroundColor(.green)
                                        }
                                    }
                                        
                            }.contextMenu{
                                Button(role: .destructive) {
                                    withAnimation {
                                        assign.managedObjectContext?.delete(assign)
                                        AssignmentDataController().save(context: managedObjContext)
                                    }
                                } label: {
                                    HStack{
                                    Text("Delete")
                                        Image(systemName: "trash")
                                    }
                                }

                            }
                            }
                        }else{
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
                            Button {
                                assign.complete.toggle()
                                AssignmentDataController().editAssign(assign: assign, complete: assign.complete, context: managedObjContext)
                                if assign.complete{
                                    simpleSuccess()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        withAnimation{
                                            if assign.complete != false{
                                            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                                                var identifiers: [String] = [assign.name!]
                                               for notification:UNNotificationRequest in notificationRequests {
                                                   if notification.identifier == "identifierCancel" {
                                                      identifiers.append(notification.identifier)
                                                   }
                                               }
                                               UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                                                print("Deleted Notifcation")
                                            }
                                        assign.managedObjectContext?.delete(assign)
                                            AssignmentDataController().save(context: managedObjContext)
                                        }
                                    }
                                    }
                                }
                            } label: {
                                HStack{
                                    Image(systemName: assign.complete ? "checkmark.circle.fill" : "circle")
                                        .font(.largeTitle)
                                    .foregroundColor(.green)
                                }
                            }
                                
                    }.contextMenu{
                        Button(role: .destructive) {
                            withAnimation {
                                assign.managedObjectContext?.delete(assign)
                                AssignmentDataController().save(context: managedObjContext)
                            }
                        } label: {
                            HStack{
                            Text("Delete")
                                Image(systemName: "trash")
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
            .sheet(isPresented: $search, content: {
                AssignmentSearchView()
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
                    Button {
                        showFolder.toggle()
                    } label: {
                        Image(systemName: "folder.fill")
                    }

                }
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        search.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu{
                        ForEach(topic){top in
                            Button {
                                withAnimation{
                                filter = true
                                filtername = top.topicname!
                                }
                            } label: {
                                Text(top.topicname!)
                                if top.topicname! == filtername && filter{
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        Button {
                            withAnimation {
                                filter = false
                            }
                        } label: {
                            Text("All")
                        }
                    }label:{
                        Image(systemName: filter ? "line.3.horizontal.decrease.circle.fill" :"line.3.horizontal.decrease.circle")
                    }

                }
            }
        }
    }
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
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
