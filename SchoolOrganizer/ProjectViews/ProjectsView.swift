//
//  ProjectsView.swift
//  SchoolOrganizerPlus
//
//  Created by Nate on 8/22/22.
//

import SwiftUI

struct ProjectsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startdate)]) var project: FetchedResults<Projects>
    @Environment(\.managedObjectContext) var managedObjContext
    @State private var add = false
    var body: some View {
        NavigationView{
            ScrollView{
                VStack{
                    ForEach(project){pro in
                        NavigationLink(destination: EditProjectView(project: pro)){
                        VStack{
                        Rectangle()
                            .frame(width: .infinity, height: 200)
                            .foregroundColor(Color(.systemGray6))
                            .cornerRadius(20)
                            .overlay {
                                VStack{
                                    Text(pro.name!)
                                        .font(.title)
                                        .foregroundColor(.black)
                                    HStack{
                                        if pro.check1done && pro.check2done && pro.check3done{
                                            HStack{
                                            Text("All Checkpoints Completed")
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.green)
                                                    .font(.title3)
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            }
                                        }else{
                                    let daysnowandend = daysBetween(start: Date.now, end: pro.checkpoint1!)
                                    let between = daysBetween(start: pro.startdate!, end: Date.now)
                                    if !pro.check1done{
                                        VStack{
                                            Text(pro.goal1!)
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        Circle()
                                            .trim(from: 0, to: 1)
                                            .stroke(Color(.systemGray5), style: StrokeStyle(lineWidth: 8.0, lineCap: .round))
                                            .opacity(0.8)
                                            .rotationEffect(.degrees(-90))
                                            .frame(width: 25, height: 25)
                                            .padding()
                                        .overlay {
                                            ProgressView("CheckPoint 1", value: between, total: daysnowandend)
                                                .onTapGesture {
                                                    print(between)
                                                    print(daysnowandend)
                                                }
                                                .onAppear(){
                                                    if daysnowandend <= 0{
                                                        ProjectDataController().editCheck1(project: pro, check1done: true, context: managedObjContext)
                                                    }
                                                }
                                                .progressViewStyle(GaugeProgressStyle())
                                                .frame(width: 25, height: 25)
                                            }
                                    }
                                    }else{
                                        HStack{
                                            Text(pro.goal1!)
                                                .multilineTextAlignment(.center)
                                                .font(.caption)
                                                .foregroundColor(.green)
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    let daysnowandend2 = daysBetween(start: Date.now, end: pro.checkpoint2!)
                                    let between2 = daysBetween(start: pro.startdate!, end: Date.now)
                                        if !pro.check2done{
                                            VStack{
                                                Text(pro.goal2!)
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            Circle()
                                                .trim(from: 0, to: 1)
                                                .stroke(Color(.systemGray5), style: StrokeStyle(lineWidth: 8.0, lineCap: .round))
                                                .opacity(0.8)
                                                .rotationEffect(.degrees(-90))
                                                .frame(width: 25, height: 25)
                                                .padding()
                                            .overlay {
                                                ProgressView("CheckPoint 2", value: between2, total: daysnowandend2)
                                                    .onTapGesture {
                                                        print(between2)
                                                        print(daysnowandend2)
                                                    }
                                                    .onAppear(){
                                                        if daysnowandend2 <= 0{
                                                            ProjectDataController().editCheck2(project: pro, check2done: true, context: managedObjContext)
                                                        }
                                                    }
                                                    .progressViewStyle(GaugeProgressStyle())
                                                    .frame(width: 25, height: 25)
                                                }
                                        }
                                        }else{
                                            HStack{
                                                Text(pro.goal2!)
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.green)
                                                    .font(.caption)
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        let daysnowandend3 = daysBetween(start: Date.now, end: pro.checkpoint3!)
                                        let between3 = daysBetween(start: pro.startdate!, end: Date.now)
                                            if !pro.check2done{
                                                VStack{
                                                    Text(pro.goal3!)
                                                        .font(.caption)
                                                        .foregroundColor(.blue)
                                                Circle()
                                                    .trim(from: 0, to: 1)
                                                    .stroke(Color(.systemGray5), style: StrokeStyle(lineWidth: 8.0, lineCap: .round))
                                                    .opacity(0.8)
                                                    .rotationEffect(.degrees(-90))
                                                    .frame(width: 25, height: 25)
                                                    .padding()
                                                .overlay {
                                                    ProgressView("CheckPoint 3", value: between3, total: daysnowandend3)
                                                        .onTapGesture {
                                                            print(between3)
                                                            print(daysnowandend3)
                                                        }
                                                        .onAppear(){
                                                            if daysnowandend3 <= 0{
                                                                ProjectDataController().editCheck3(project: pro, check3done: true, context: managedObjContext)
                                                            }
                                                        }
                                                        .progressViewStyle(GaugeProgressStyle())
                                                        .frame(width: 25, height: 25)
                                                    }
                                            }
                                            }else{
                                                HStack{
                                                    Text(pro.goal3!)
                                                        .multilineTextAlignment(.center)
                                                        .foregroundColor(.green)
                                                        .font(.caption)
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                }
                                            }
                                    }
                                }
                                }
                                .padding()
                    }
                    }.contextMenu{
                        Button(role: .destructive) {
                            withAnimation{
                                UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                                    var identifiers: [String] = [pro.goal1!, pro.goal2!, pro.goal3!]
                                        for notification:UNNotificationRequest in notificationRequests {
                                            if notification.identifier == "identifierCancel" {
                                               identifiers.append(notification.identifier)
                                            }
                                        }
                                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
                                         print("Deleted Notifcation")
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                            pro.managedObjectContext?.delete(pro)
                                ProjectDataController().save(context: managedObjContext)
                                }
                            }
                        } label: {
                            Text("Delete")
                            Image(systemName: "trash")
                        }

                    }
                    }
                    }
                }.padding()
                .sheet(isPresented: $add) {
                    ProjectCreateView()
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        add.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                    }

                }
            }
        }
    }
    func daysBetween(start: Date, end: Date) -> Double {
        return Double(Calendar.current.dateComponents([.second], from: start, to: end).second!)
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView()
    }
}
struct GaugeProgressStyle: ProgressViewStyle {
    var strokeColor = Color.blue
    var strokeWidth = 8.0

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0

        return ZStack {
            Circle()
                .trim(from: 0, to: fractionCompleted)
                .stroke(strokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
