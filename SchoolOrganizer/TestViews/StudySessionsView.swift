//
//  StudySessionsView.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/15/22.
//

import SwiftUI
import AlertToast

struct StudySessionsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.start)]) var session: FetchedResults<StudySessions>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.intensity, order: .reverse)]) var studytopic: FetchedResults<StudyTopics>
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var add = false
    @State private var addedSession = false
    @State private var newtopic = false
    @State private var topicname = ""
    @State private var intensityValue: Double = 0
    @State private var intensitystatus = ""
    var body: some View {
        NavigationView{
            ScrollView{
        VStack{
            ForEach(session){study in
                NavigationLink(destination: SessionEditView(session: study)){
                    VStack(alignment: .leading){
                Text(study.name!)
                            .foregroundColor(.gray)
                            .underline()
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .fixedSize(horizontal: false, vertical: true)
                        HStack{
                            Text(study.start!, style: .date)
                                    .foregroundColor(.gray)
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            Text(study.start!, style: .time)
                                    .foregroundColor(.gray)
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .fixedSize(horizontal: false, vertical: true)
                            Text("-")
                                .foregroundColor(.gray)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            Text(study.end!, style: .time)
                                .foregroundColor(.gray)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                        }.padding()
                        let minuteend = daysBetweenMinute(start: Date.now, end: study.end!)
                        let hours = daysBetween(start: Date.now, end: study.start!)
                        if hours >= 2{
                            HStack{
                            Text("Session Set")
                                .underline()
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundColor(.green)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                        }
                    if hours == 1{
                        HStack{
                        Text("Starting Soon")
                            .underline()
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.yellow)
                            Image(systemName: "clock.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                        }
                    }
                    let minutes  = daysBetweenMinute(start: Date.now, end: study.start!)
                    if minutes <= 60 && minutes > 0{
                        Text("\(minutes) minute(s) til session starts")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.red)
                    }
                        if minuteend <= 0 && minutes <= 0{
                                Text("Session ended")
                                    .underline()
                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                                    .foregroundColor(.gray)
                        }else if minutes <= 0{
                        Text("Session Started")
                            .underline()
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.green)
                        let minuteend = daysBetweenMinute(start: Date.now, end: study.end!)
                        if minuteend > 60{
                            let hourend = daysBetween(start: Date.now, end: study.end!)
                            let leftoverminutes = minuteend % 60
                            HStack{
                                VStack{
                            Text("Session ends in \(hourend) hour(s) and")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundColor(.gray)
                                    Text("\(leftoverminutes) minute(s)")
                                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                            }
                        }else if minuteend > 0{
                        Text("Session ends in \(minuteend) minute(s)")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(.gray)
                        }
                    }
                }.padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding()
                }.onChange(of: add) { V in
                    simpleSuccess()
                    print("Change")
                }
            }
            VStack{
                HStack{
                Text("Important Topics To Study")
                        .bold()
                }.padding()
                if newtopic{
                    Slider(value: $intensityValue, in: 0...10)
                        .onChange(of: intensityValue) { Bob in
                            if intensityValue > 4 && intensityValue < 6{
                                intensitystatus = "Medium"
                            }
                            if intensityValue < 4{
                                intensitystatus = "Low"
                            }
                            if intensityValue > 6 {
                                intensitystatus = "High"
                            }
                        }
                        .onAppear(){
                            if intensityValue > 4 && intensityValue < 6{
                                intensitystatus = "Medium"
                            }
                            if intensityValue < 4{
                                intensitystatus = "Low"
                            }
                            if intensityValue > 6 {
                                intensitystatus = "High"
                            }
                        }
                    Text("Intensity: \(intensitystatus)")
                        .bold()
                        .if(intensitystatus == "Low"){view in
                            view.foregroundColor(.green)
                        }
                        .if(intensitystatus == "Medium"){view in
                            view.foregroundColor(.yellow)
                        }
                        .if(intensitystatus == "High"){view in
                            view.foregroundColor(.red)
                        }
                }
            ScrollView(.horizontal, showsIndicators: true) {
                HStack{
                    if studytopic.isEmpty && newtopic == false{
                        Text("No Topics Added")
                            .bold()
                            .foregroundColor(.gray)
                    }
                    ForEach(studytopic){topic in
                        HStack{
                            Text(topic.name!)
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .if (topic.intensity > 4 && topic.intensity < 6){ view in
                                    view.foregroundColor(.orange)
                                }
                                .if (topic.intensity < 4){view in
                                    view.foregroundColor(.green)
                                }
                                .if (topic.intensity > 6) {view in
                                  view.foregroundColor(.red)
                                }
                        }.padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(25)
                        .contextMenu {
                            Button(role: .destructive){
                                withAnimation{
                                topic.managedObjectContext?.delete(topic)
                                    StudyTopicsDataController().save(context: managedObjContext)
                                }
                            }label: {
                              Text("Delete")
                                Image(systemName: "trash.fill")
                            }
                        }
                    }
                    if newtopic{
                        TextField("Topic Name...", text: $topicname)
                            .textFieldStyle(.roundedBorder)
                    }
                    Button {
                        withAnimation{
                        newtopic.toggle()
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
            }.padding()
            .background(Color(.systemGray6))
                    .padding()
                    .cornerRadius(20)
                if newtopic{
                    Button {
                        if !topicname.trimmingCharacters(in: .whitespaces).isEmpty{
                            StudyTopicsDataController().addStudyTopic(name: topicname.trimmingCharacters(in: .whitespaces), intensity: intensityValue, context: managedObjContext)
                        topicname = ""
                        }
                        withAnimation{
                        newtopic = false
                        }
                    } label: {
                        Text("Add")
                    }.buttonStyle(.borderedProminent)
                        .padding()

                }
            }.background(colorScheme == .dark ? Color(.systemGray4) : .white)
        }
        }
        .toast(isPresenting: $addedSession, alert: {
            AlertToast(type: .complete(.green), title: "Added", style: .style(backgroundColor: Color(.systemGray5)))
        })
        .sheet(isPresented: $add, content: {
            SessionAdd(added: $addedSession)
        })
        .navigationTitle(session.isEmpty ? "No Sessions":"Study Sessions")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    add.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title)
                }

            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                   dismiss()
                } label: {
                    Text("Cancel")
                }

            }
        }
    }
        .navigationViewStyle(.stack)
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: start, to: end).hour!
    }
    func daysBetweenMinute(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: start, to: end).minute!
    }
    private func deleteSession(offsets: IndexSet) {
        withAnimation {
            offsets.map { session[$0] }
            .forEach(managedObjContext.delete)
            
            // Saves to our database
            StudyDataController().save(context: managedObjContext)
        }
    }
}

struct StudySessionsView_Previews: PreviewProvider {
    static var previews: some View {
        StudySessionsView()
    }
}

struct SessionAdd: View{
    @FetchRequest(sortDescriptors: [SortDescriptor(\.testdate)]) var test: FetchedResults<Tests>
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var startdate = Date()
    @State private var same = false
    @State private var enddate = Date()
    @State private var startday: Int = 0
    @FocusState var focusname: Bool
    @Binding var added: Bool
    var body: some View{
        NavigationView{
        Form{
            TextField("Name...", text: $name)
                .focused($focusname)
                .multilineTextAlignment(.center)
                .onAppear(){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6){
                        focusname = true
                    }
                }
            DatePicker(selection: $startdate, in: Date.now..., label: {
                Text("Starting...")
                    .italic()
                    .bold()
                    .foregroundColor(.gray)
            }).datePickerStyle(.compact)
                .onChange(of: startdate) { newValue in
                    let calendar  = Calendar.current
                    let day = calendar.component(.day, from: startdate)
                    startday = day
                    let automatic = Calendar.current.date(bySetting: .day, value: startday, of: startdate)
                    enddate = automatic!
                    if enddate != startdate{
                        same = false
                    }else{
                        same = true
                    }
                }
                .onAppear(){
                        same = true
                }
            DatePicker(selection: $enddate, in: startdate..., displayedComponents: .hourAndMinute, label: {
                Text("Ending...")
                    .italic()
                    .bold()
                    .foregroundColor(.gray)
            }).datePickerStyle(.compact)
                .onChange(of: enddate) { newValue in
                    if enddate != startdate{
                        same = false
                    }else{
                        same = true
                    }
                }
            if !test.isEmpty{
            ScrollView(.horizontal){
                HStack{
            ForEach(test){tes in
                Button {
                    name = tes.testname! + " Session"
                } label: {
                    Text(tes.testname!)
                }.tint(.blue)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 30))
            }
            }
        }
        }
        }
        .navigationTitle("Add Session")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success{
                            print("All Set")
                        }else if let error = error{
                            print(error.localizedDescription)
                        }
                    }
                    StudyDataController().addStudySession(name: name, start: startdate, end: enddate, context: managedObjContext)
                    let content = UNMutableNotificationContent()
                    content.title = name
                    let saydate = startdate
                    content.body = "In 15 minutes! \(saydate.formatted(.dateTime.hour().minute()))"
                    let date = startdate
                    let fifteenminutes = Calendar.current.date(byAdding: .minute, value: -15, to: date)
                    content.sound = UNNotificationSound.default
                    let earlycomp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fifteenminutes!)
                    let earlycalendartrigger = UNCalendarNotificationTrigger(dateMatching: earlycomp, repeats: false)
                    let firstrequest = UNNotificationRequest(identifier: name, content: content, trigger: earlycalendartrigger)
                    
                    UNUserNotificationCenter.current().add(firstrequest)
                    
                    let currentcontent = UNMutableNotificationContent()
                    currentcontent.title = name
                    currentcontent.body = "\(name) Session Started"
                    let currentdate = startdate
                    let currenttime = Calendar.current.date(byAdding: .day, value: 0, to: currentdate)
                    content.sound = UNNotificationSound.default
                    let currentcomp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: currenttime!)
                    let currenttrigger = UNCalendarNotificationTrigger(dateMatching: currentcomp, repeats: false)
                    let identifier = name + "CC"
                    let currentrequest = UNNotificationRequest(identifier: identifier, content: currentcontent, trigger: currenttrigger)
                    UNUserNotificationCenter.current().add(currentrequest)
                    
                    let endcontent = UNMutableNotificationContent()
                    endcontent.title = "\(name) Session Ending"
                    endcontent.body = "Finish Up Last Thoughts"
                    let enddate = enddate
                    let endtime = Calendar.current.date(byAdding: .day, value: 0, to: enddate)
                    endcontent.sound = UNNotificationSound.default
                    let endcomp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: endtime!)
                    let endtrigger = UNCalendarNotificationTrigger(dateMatching: endcomp, repeats: false)
                    let endidentifier = name + "EE"
                    let endrequest = UNNotificationRequest(identifier: endidentifier, content: endcontent, trigger: endtrigger)
                    UNUserNotificationCenter.current().add(endrequest)
                    added.toggle()
                    dismiss()
                } label: {
                    Text("Submit")
                }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || same)

            }
            ToolbarItem(placement: .cancellationAction) {
                Button {
                   dismiss()
                } label: {
                    Text("Cancel")
                }

            }
        }
    }
        .navigationViewStyle(.stack)
    }
}

struct SessionAddPlus: View{
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    @State private var startdate = Date()
    @State private var same = false
    @State private var session = ""
    @State private var enddate = Date()
    @FocusState var focusname: Bool
    @State private var startday: Int = 0
    var body: some View{
        NavigationView{
        Form{
            TextField("Name...", text: $session)
                .focused($focusname)
                .multilineTextAlignment(.center)
                .onAppear(){
                    session = name + " Session"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6){
                        focusname = true
                    }
                }
            DatePicker(selection: $startdate, in: Date.now..., label: {
                Text("Starting...")
                    .italic()
                    .bold()
                    .foregroundColor(.gray)
            }).datePickerStyle(.compact)
                .onChange(of: startdate) { newValue in
                    let calendar  = Calendar.current
                    let day = calendar.component(.day, from: startdate)
                    startday = day
                    let automatic = Calendar.current.date(bySetting: .day, value: startday, of: startdate)
                    enddate = automatic!
                    if enddate != startdate{
                        same = false
                    }else{
                        same = true
                    }
                }
                .onAppear(){
                        same = true
                }
            DatePicker(selection: $enddate, in: startdate..., displayedComponents: .hourAndMinute, label: {
                Text("Ending...")
                    .italic()
                    .bold()
                    .foregroundColor(.gray)
            }).datePickerStyle(.compact)
                .onChange(of: enddate) { newValue in
                    if enddate != startdate{
                        same = false
                    }else{
                        same = true
                    }
                }
        }
        .navigationTitle("Add Session")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success{
                            print("All Set")
                        }else if let error = error{
                            print(error.localizedDescription)
                        }
                    }
                    StudyDataController().addStudySession(name: session, start: startdate, end: enddate, context: managedObjContext)
                    let content = UNMutableNotificationContent()
                    content.title = session
                    let saydate = startdate
                    content.body = "In 15 minutes! \(saydate.formatted(.dateTime.hour().minute()))"
                    let date = startdate
                    let fifteenminutes = Calendar.current.date(byAdding: .minute, value: -15, to: date)
                    content.sound = UNNotificationSound.default
                    let earlycomp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fifteenminutes!)
                    let earlycalendartrigger = UNCalendarNotificationTrigger(dateMatching: earlycomp, repeats: false)
                    let firstrequest = UNNotificationRequest(identifier: session, content: content, trigger: earlycalendartrigger)
                    
                    UNUserNotificationCenter.current().add(firstrequest)
                    
                    let currentcontent = UNMutableNotificationContent()
                    currentcontent.title = session
                    currentcontent.body = "\(session) Session Started"
                    let currentdate = startdate
                    let currenttime = Calendar.current.date(byAdding: .day, value: 0, to: currentdate)
                    content.sound = UNNotificationSound.default
                    let currentcomp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: currenttime!)
                    let currenttrigger = UNCalendarNotificationTrigger(dateMatching: currentcomp, repeats: false)
                    let identifier = session + "CC"
                    let currentrequest = UNNotificationRequest(identifier: identifier, content: currentcontent, trigger: currenttrigger)
                    UNUserNotificationCenter.current().add(currentrequest)
                    
                    let endcontent = UNMutableNotificationContent()
                    endcontent.title = "\(session) Session Ending"
                    endcontent.body = "Finish Up Last Thoughts"
                    let enddate = enddate
                    let endtime = Calendar.current.date(byAdding: .day, value: 0, to: enddate)
                    endcontent.sound = UNNotificationSound.default
                    let endcomp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: endtime!)
                    let endtrigger = UNCalendarNotificationTrigger(dateMatching: endcomp, repeats: false)
                    let endidentifier = session + "EE"
                    let endrequest = UNNotificationRequest(identifier: endidentifier, content: endcontent, trigger: endtrigger)
                    UNUserNotificationCenter.current().add(endrequest)
                    dismiss()
                } label: {
                    Text("Submit")
                }.disabled(session.trimmingCharacters(in: .whitespaces).isEmpty || same)

            }
            ToolbarItem(placement: .cancellationAction) {
                Button {
                   dismiss()
                } label: {
                    Text("Cancel")
                }

            }
        }
    }
        .navigationViewStyle(.stack)
    }
}
