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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.score)]) var test: FetchedResults<Tests>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topicname)]) var topic: FetchedResults<Topics>
    @AppStorage("NumberOfAsCompleted") var assignmentscompleted: Int = 0
    @Environment(\.dismiss) var dismiss
    @State private var Add = false
    @Environment(\.colorScheme) var colorScheme
    @State private var Schedule = false
    @State private var foldername = ""
    @State private var editname = false
    @State private var showFolder = false
    @State private var filter = false
    @State private var filtername = ""
    @State private var search = false
    @State private var editpop = false
    @State private var confirm = false
    @State private var newvalue = false
    @State private var complete = false
    @AppStorage("OnBoarding") var onboarding = true
   private let adaptiveColumns = [
    GridItem(.adaptive(minimum: 160))
   ]
    var body: some View{
        NavigationView{
            ScrollView{
                HStack{
                    Text("Assignments Completed: \(assignmentscompleted)")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .onChange(of: newvalue, perform: { _ in
                        assignmentscompleted += 1
                    })
                    .if(assignmentscompleted <= 25){ view in
                        view.foregroundColor(.brown)
                    }
                    .if(assignmentscompleted <= 50 && assignmentscompleted > 25){ view in
                        view.foregroundColor(.gray)
                    }
                    .if(assignmentscompleted <= 100 && assignmentscompleted > 50){ view in
                        view.foregroundColor(.yellow)
                    }
                    Spacer()
                    if assignmentscompleted <= 25{
                            Text("Bronze")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.brown)
                    }
                    if assignmentscompleted <= 50 && assignmentscompleted > 25{
                            Text("Silver")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    if assignmentscompleted <= 100 && assignmentscompleted > 50{
                            Text("Gold")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.yellow)
                    }
                }.padding()
                Divider()
                if assignment.isEmpty{
                    HStack{
                    Text("No Assignments")
                        .font(.system(size: 25, weight: .heavy, design: .rounded))
                        .foregroundColor(.gray)
                        Image(systemName:"exclamationmark.octagon")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                LazyVGrid(columns: adaptiveColumns) {
                    ForEach(assignment){assign in
                        if filter{
                            if assign.topic == filtername{
                                VStack{
                                NavigationLink(destination: EditAssignment(assignment: assign, newvalue: $newvalue)){
                                    ZStack{
                                    Rectangle()
                                        .frame(minWidth: 160, idealWidth: 160, maxWidth: 200, minHeight: 160, idealHeight: 160, maxHeight: 200)
                                        .cornerRadius(30)
                                        .if(assign.color == "Blue"){view in
                                            view.foregroundColor(.blue)
                                        }
                                        .if(assign.color == "Green"){ view in
                                            view.foregroundColor(.green)
                                        }
                                        .if(assign.color == "Red"){ view in
                                            view.foregroundColor(.red)
                                        }
                                        .if(assign.color == "Purple"){ view in
                                            view.foregroundColor(.purple)
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
                                                    .fixedSize(horizontal: false, vertical: true)
                                                Text(assign.duedate ?? Date.now, style: .date)
                                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .if(days >= 7){ view in
                                                        view.foregroundColor(.green)
                                                    }
                                                    .if( days < 7 && days > 3){ view in
                                                        view.foregroundColor(.orange)
                                                    }
                                                    .if(days <= 3){ view in
                                                        view.foregroundColor(.red)
                                                    }
                                                    .padding()
                                                    .background(Color(.systemGray4))
                                                    .cornerRadius(20)
                                                if assign.book{
                                                    Image(systemName: "book.closed.fill")
                                                        .foregroundColor(.black)
                                                        .font(.title)
                                                }
                                            }
                                        }
                                        Rectangle()
                                            .fill(.green)
                                            .frame(width: assign.complete ? 200:0, height: assign.complete ? 200:0)
                                            .onChange(of: assign.complete, perform: { V in
                                                if assign.complete{
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                                        withAnimation{
                                                        complete = true
                                                        }
                                                    }
                                                }
                                                if !assign.complete{
                                                    withAnimation{}
                                                    complete = false
                                                }
                                            })
                                            .cornerRadius(30)
                                            .animation(.spring(), value: assign.complete)
                                            .overlay{
                                                if complete{
                                                Image(systemName: "checkmark")
                                                    .font(.largeTitle)
                                                    .foregroundColor(.white)
                                                }
                                            }.padding()
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
                                    } label: {
                                        HStack{
                                            Image(systemName: assign.complete ? "checkmark.circle.fill" : "circle")
                                                .font(.largeTitle)
                                            .foregroundColor(.green)
                                        }.onChange(of: assign.complete) { _ in
                                            AssignmentDataController().editAssign(assign: assign, complete: assign.complete, context: managedObjContext)
                                            if assign.complete{
                                                simpleSuccess()
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                    withAnimation{
                                                        assignmentscompleted += 1
                                                        if assign.complete != false{
                                                        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                                                            let formatter1 = DateFormatter()
                                                            formatter1.dateStyle = .long
                                                            let bookassign = assign.name! + "B"
                                                            let bookcomplete = assign.name! + "C"
                                                            let notif1 = assign.name! + "notif1"
                                                            let notif2 = assign.name! + "notif2"
                                                            let ontime = assign.name! + "ON"
                                                            let rep = assign.name! + "Rep"
                                                            if assign.book{
                                                            var identifiers: [String] = [bookassign, bookcomplete]
                                                                for notification:UNNotificationRequest in notificationRequests {
                                                                    if notification.identifier == "identifierCancel" {
                                                                       identifiers.append(notification.identifier)
                                                                    }
                                                                }
                                                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                                                                 print("Deleted Notifcation")
                                                            }else{
                                                                var identifiers: [String] = [assign.name!, formatter1.string(from: assign.duedate!), notif1, notif2,ontime,rep]
                                                                for notification:UNNotificationRequest in notificationRequests {
                                                                    if notification.identifier == "identifierCancel" {
                                                                       identifiers.append(notification.identifier)
                                                                    }
                                                                }
                                                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                                                                 print("Deleted Notifcation")
                                                            }
                                                        }
                                                    assign.managedObjectContext?.delete(assign)
                                                        AssignmentDataController().save(context: managedObjContext)
                                                    }
                                                }
                                                }
                                            }
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
                            NavigationLink(destination: EditAssignment(assignment: assign, newvalue: $newvalue)){
                                ZStack{
                            Rectangle()
                                .frame(minWidth: 160, idealWidth: 160, maxWidth: 200, minHeight: 160, idealHeight: 160, maxHeight: 200)
                                .cornerRadius(30)
                                .if(assign.color == "Blue"){view in
                                    view.foregroundColor(.blue)
                                }
                                .if(assign.color == "Green"){ view in
                                    view.foregroundColor(.green)
                                }
                                .if(assign.color == "Red"){ view in
                                    view.foregroundColor(.red)
                                }
                                .if(assign.color == "Purple"){ view in
                                    view.foregroundColor(.purple)
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
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text(assign.duedate ?? Date.now, style: .date)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                                            .if(days >= 7){ view in
                                                view.foregroundColor(.green)
                                            }
                                            .if( days < 7 && days > 3){ view in
                                                view.foregroundColor(.orange)
                                            }
                                            .if(days <= 3){ view in
                                                view.foregroundColor(.red)
                                            }
                                            .padding()
                                            .background(Color(.systemGray4))
                                            .cornerRadius(20)
                                        if assign.book{
                                            Image(systemName: "book.closed.fill")
                                                .foregroundColor(.black)
                                                .font(.title)
                                        }
                                    }
                                }
                                    Rectangle()
                                        .fill(.green)
                                        .frame(width: assign.complete ? 200:0, height: assign.complete ? 200:0)
                                        .onChange(of: assign.complete, perform: { V in
                                            if assign.complete{
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                                    withAnimation{
                                                    complete = true
                                                    }
                                                }
                                            }
                                            if !assign.complete{
                                                withAnimation{}
                                                complete = false
                                            }
                                        })
                                        .cornerRadius(30)
                                        .animation(.spring(), value: assign.complete)
                                        .overlay{
                                            if complete{
                                            Image(systemName: "checkmark")
                                                    .font(.largeTitle)
                                                .foregroundColor(.white)
                                            }
                                        }.padding()
                                    
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
                            } label: {
                                HStack{
                                    Image(systemName: assign.complete ? "checkmark.circle.fill" : "circle")
                                        .font(.largeTitle)
                                    .foregroundColor(.green)
                                }.onChange(of: assign.complete) { _ in
                                    AssignmentDataController().editAssign(assign: assign, complete: assign.complete, context: managedObjContext)
                                    if assign.complete{
                                        simpleSuccess()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                            withAnimation{
                                                assignmentscompleted += 1
                                                if assign.complete != false{
                                                UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                                                    let formatter1 = DateFormatter()
                                                    formatter1.dateStyle = .long
                                                    let bookassign = assign.name! + "B"
                                                    let bookcomplete = assign.name! + "C"
                                                    let notif1 = assign.name! + "notif1"
                                                    let notif2 = assign.name! + "notif2"
                                                    let ontime = assign.name! + "ON"
                                                    let rep = assign.name! + "Rep"
                                                    if assign.book{
                                                        let identifiers: [String] = [bookassign, bookcomplete]
                                                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                                                         print(identifiers)
                                                    }else{
                                                    let identifiers: [String] = [assign.name!, formatter1.string(from: assign.duedate!), notif1,notif2,ontime,rep]
                                                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                                                         print("Deleted Notifcation")
                                                    }
                                                }
                                            assign.managedObjectContext?.delete(assign)
                                                AssignmentDataController().save(context: managedObjContext)
                                            }
                                        }
                                        }
                                    }
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
            }
            .fullScreenCover(isPresented: $onboarding, content: {
                OnBoardingView()
            })
            .sheet(isPresented: $showFolder, content: {
                FolderView()
            })
            .toast(isPresenting: $editpop) {
                AlertToast(displayMode: .banner(.pop), type: .complete(.blue), title: "Edited", style: .style(backgroundColor: Color(.systemGray6), titleColor: colorScheme == .dark ?  .white :.black, subTitleColor: .black, titleFont: .system(size: 30, weight: .heavy, design: .rounded), subTitleFont: .title))
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
                        .buttonBorderShape(.roundedRectangle)
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
                    }.disabled(assignment.isEmpty)
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
                            if filter == false{
                                Image(systemName: "checkmark")
                            }
                        }
                        if !topic.isEmpty{
                        Button(role: .destructive) {
                            withAnimation {
                                if !assignment.isEmpty || !test.isEmpty{
                                confirm.toggle()
                                }
                                    topic
                                    .forEach(managedObjContext.delete)
                                    
                                    TopicDataController().save(context: managedObjContext)
                            }
                        } label: {
                            Text("Delete All")
                            Image(systemName: "trash")
                        }
                    }
                    }label:{
                        Image(systemName: filter ? "line.3.horizontal.decrease.circle.fill" :"line.3.horizontal.decrease.circle")
                    }

                }
            }
        }
        .navigationViewStyle(.stack)
    }
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
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
                }.tint(assignment.color == "Green" ? .blue :.green)
                .buttonStyle(.borderedProminent)

            }.frame(width: .infinity, height: .infinity)
            .padding()
            .if(assignment.color == "Blue"){view in
                view.background(.blue)
            }
            .if(assignment.color == "Green"){ view in
                view.background(.green)
            }
            .if(assignment.color == "Red"){ view in
                view.background(.red)
            }
            .if(assignment.color == "Purple"){ view in
                view.background(.purple)
            }
                .cornerRadius(20)
    }
}
