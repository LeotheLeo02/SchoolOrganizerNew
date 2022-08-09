//
//  ContentView.swift
//  SchoolKit
//
//  Created by Nate on 7/31/22.
//

import SwiftUI
import AlertToast
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
    @State private var editpop = false
    @State private var deletealltopics = false
    @State private var confirm = false
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
                                    if assign.editmode{
                                        Text("Edit Here")
                                      EditPopupView(assignment: assign,isPresented: $editname, editpop: $editpop)
                                            .padding()
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
                                                        let formatter1 = DateFormatter()
                                                        formatter1.dateStyle = .long
                                                        var identifiers: [String] = [assign.name!, formatter1.string(from: assign.duedate!)]
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
                                        
                                }
                                .contextMenu{
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
                                Button {
                                    withAnimation{
                                        AssignmentDataController().editAssignEdit(assign: assign, editmode: true, context: managedObjContext)
                                    }
                                } label: {
                                    Text("Edit")
                                    Image(systemName: "pencil")
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
                            if assign.editmode{
                                Text("Edit Here")
                                EditPopupView(assignment: assign,isPresented: $editname, editpop: $editpop)
                                    .padding()
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
                                                let formatter1 = DateFormatter()
                                                formatter1.dateStyle = .long
                                                var identifiers: [String] = [assign.name!, formatter1.string(from: assign.duedate!)]
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
                                
                        }
                        .contextMenu{
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
                        Button {
                            withAnimation{
                                AssignmentDataController().editAssignEdit(assign: assign, editmode: true, context: managedObjContext)
                            }
                        } label: {
                            Text("Edit")
                            Image(systemName: "pencil")
                        }

                    }
                    }
                    }
                }
            }.sheet(isPresented: $showFolder, content: {
                FolderView()
            })
            .toast(isPresenting: $editpop) {
                AlertToast(displayMode: .banner(.pop), type: .complete(.blue), title: "Edited", style: .style(backgroundColor: Color(.systemGray6), titleColor: .black, subTitleColor: .black, titleFont: .system(size: 30, weight: .heavy, design: .rounded), subTitleFont: .title))
            }
            .sheet(isPresented: $Add, content: {
                AddAssignment()
            })
            .sheet(isPresented: $search, content: {
                AssignmentSearchView()
            })
            .sheet(isPresented: $confirm, content: {
                ChangeAllTopicsView()
            })
            .alert(isPresented: $deletealltopics){
                Alert(title: Text("Are You Sure?"), message: Text("Deleting all topics will also delete all assignments below it."), primaryButton: .cancel(Text("Cancel")), secondaryButton: .destructive(Text("Delete All"), action: {
                    withAnimation {
                        confirm.toggle()
                        withAnimation {
                            topic
                            .forEach(managedObjContext.delete)
                            
                            // Saves to our database
                            TopicDataController().save(context: managedObjContext)
                        }
                    }
                }))
            }
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
                        Button(role: .destructive) {
                            deletealltopics.toggle()
                        } label: {
                            Text("Delete All Topics")
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

struct EditPopupView: View{
    var assignment: FetchedResults<Assignment>.Element
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @Binding var isPresented: Bool
    @Binding var editpop: Bool
    @State private var newname = ""
    var body: some View{
            VStack{
                TextField("New Name", text: $newname)
                    .onAppear(){
                        newname = assignment.name!
                    }
                    .textFieldStyle(.roundedBorder)
                Button {
                    withAnimation{
                    AssignmentDataController().editAssignName(assign: assignment, name: newname, context: managedObjContext)
                        AssignmentDataController().editAssignEdit(assign: assignment, editmode: false, context: managedObjContext)
                    isPresented = false
                        editpop.toggle()
                    }
                } label: {
                    Text("Done")
                }.tint(.green)
                .buttonStyle(.borderedProminent)

            }.padding()
            .if(assignment.color == "Blue"){view in
                view.background(.blue)
            }
            .if(assignment.color == "Yellow"){ view in
                view.background(.yellow)
            }
            .if(assignment.color == "Red"){ view in
                view.background(.red)
            }
                .cornerRadius(20)
    }
}
