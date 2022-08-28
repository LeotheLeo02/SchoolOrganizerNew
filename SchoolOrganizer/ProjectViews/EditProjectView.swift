//
//  EditProjectView.swift
//  SchoolOrganizerPlus
//
//  Created by Nate on 8/22/22.
//

import SwiftUI

struct EditProjectView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @State private var edit = false
    @State private var checkpoint1 = Date()
    @State private var checkpoint2 = Date()
    @State private var checkpoint3 = Date()
    @State private var extend = false
    var project: FetchedResults<Projects>.Element
    var body: some View {
        NavigationView{
            ScrollView{
            HStack{
            if project.check1done{
                HStack{
                    Text(project.goal1!)
                        .bold()
                        .foregroundColor(.green)
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }else{
                let daysnowandend = daysBetween(start: Date.now, end: project.checkpoint1!)
                let between = daysBetween(start: project.startdate!, end: Date.now)
                let percent = Double(between/daysnowandend * 100)
                if percent > 100 && !extend{
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding()
                }else{
                    Spacer()
                    VStack{
                        Text(project.goal1!)
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
                                print(daysnowandend)
                                print(between)
                                print(percent)
                            }
                            .progressViewStyle(GaugeProgressStyle())
                            .frame(width: 25, height: 25)
                    }
                        Text("\(Int(percent))%")
                            .foregroundColor(.blue)
                            .bold()
                    }.onLongPressGesture {
                        withAnimation{
                        extend = true
                        }
                    }
                    if extend{
                        DatePicker("", selection: $checkpoint3, in: Date.now...)
                            .onAppear(){
                                checkpoint3 = project.checkpoint1!
                            }
                            .onChange(of: checkpoint3) { newValue in
                                ProjectDataController().editPoint(project: project, checkpoint1: checkpoint3, context: managedObjContext)
                            }
                    }
                    Spacer()
            }
            }
                if project.check2done{
                    HStack{
                        Text(project.goal2!)
                            .bold()
                            .foregroundColor(.green)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }else{
                    if project.check1done{
                    let daysnowandend2 = daysBetween(start: Date.now, end: project.checkpoint2!)
                    let between2 = daysBetween(start: project.startdate!, end: Date.now)
                    let percent2 = Double(between2/daysnowandend2 * 100)
                        if percent2 > 100 && !extend{
                            ProgressView()
                                .progressViewStyle(.circular)
                                .padding()
                        }else{
                        Spacer()
                        VStack{
                            Text(project.goal2!)
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
                                    print(daysnowandend2)
                                    print(between2)
                                    print(percent2)
                                }
                                .progressViewStyle(GaugeProgressStyle())
                                .frame(width: 25, height: 25)
                        }
                            Text("\(Int(percent2))%")
                                .foregroundColor(.blue)
                                .bold()
                        }.onLongPressGesture {
                            withAnimation{
                            extend = true
                            }
                        }
                            if extend{
                                DatePicker("", selection: $checkpoint3,in: Date.now...)
                                    .onAppear(){
                                        checkpoint3 = project.checkpoint2!
                                    }
                                    .onChange(of: checkpoint3) { newValue in
                                        ProjectDataController().editPoint2(project: project, checkpoint2: checkpoint3, context: managedObjContext)
                                    }
                            }
                        Spacer()
                    }
                }
                }
                if project.check3done{
                    HStack{
                        Text(project.goal3!)
                            .bold()
                            .foregroundColor(.green)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }else{
                    let daysnowandend3 = daysBetween(start: Date.now, end: project.checkpoint3!)
                    let between3 = daysBetween(start: project.startdate!, end: Date.now)
                    let percent3 = Double(between3/daysnowandend3 * 100)
                    if percent3 > 100 && !extend{
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding()
                    }else{
                    if project.check2done{
                        Spacer()
                        VStack{
                            Text(project.goal3!)
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
                            ProgressView("CheckPoint 2", value: between3, total: daysnowandend3)
                                .onTapGesture {
                                    print(daysnowandend3)
                                    print(between3)
                                    print(percent3)
                                }
                                .progressViewStyle(GaugeProgressStyle())
                                .frame(width: 25, height: 25)
                        }
                            Text("\(Int(percent3))%")
                                .foregroundColor(.blue)
                                .bold()
                        }.onLongPressGesture {
                            withAnimation{
                            extend = true
                            }
                        }
                        if extend{
                            DatePicker("", selection: $checkpoint3,in: Date.now...)
                                .onAppear(){
                                    checkpoint3 = project.checkpoint3!
                                }
                                .onChange(of: checkpoint3) { newValue in
                                    ProjectDataController().editPoint3(project: project, checkpoint3: checkpoint3, context: managedObjContext)
                                }
                        }
                        Spacer()
                    }
                }
                }

            }.padding()
                    .onChange(of: extend, perform: { newValue in
                        let check1 = daysBetweenNegative(start: Date.now, end: project.checkpoint1!)
                        if check1 <= 0{
                            ProjectDataController().editCheck1(project: project, check1done: true, context: managedObjContext)
                        }
                        let check2 = daysBetweenNegative(start: Date.now, end: project.checkpoint2!)
                        if check2 <= 0{
                            ProjectDataController().editCheck2(project: project, check2done: true, context: managedObjContext)
                        }
                        let check3 = daysBetweenNegative(start: Date.now, end: project.checkpoint3!)
                        if check3 <= 0{
                            ProjectDataController().editCheck3(project: project, check3done: true, context: managedObjContext)
                        }
                    })
            .onAppear(){
            let check1 = daysBetweenNegative(start: Date.now, end: project.checkpoint1!)
            if check1 <= 0{
                ProjectDataController().editCheck1(project: project, check1done: true, context: managedObjContext)
            }
            let check2 = daysBetweenNegative(start: Date.now, end: project.checkpoint2!)
            if check2 <= 0{
                ProjectDataController().editCheck2(project: project, check2done: true, context: managedObjContext)
            }
            let check3 = daysBetweenNegative(start: Date.now, end: project.checkpoint3!)
            if check3 <= 0{
                ProjectDataController().editCheck3(project: project, check3done: true, context: managedObjContext)
            }
        }
            if !project.check2done{
            Section{
            VStack{
                if !project.check1done{
                    HStack{
                    Text(project.goal2!)
                            .bold()
                        Spacer()
                        if edit{
                            DatePicker("", selection: $checkpoint1, in: Date.now...)
                                .onChange(of: checkpoint1) { newValue in
                                    ProjectDataController().editPoint(project: project, checkpoint1: checkpoint1, context: managedObjContext)
                                }
                        }else{
                        let formatted = checkpoint1.formatted()
                        Text(formatted)
                            .foregroundColor(.gray)
                            .onLongPressGesture {
                                withAnimation{
                                edit = true
                                }
                            }
                        Image(systemName: "clock.fill")
                            .foregroundColor(.gray)
                        }
                    }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    Divider()
                    HStack{
                    Text(project.goal3!)
                            .bold()
                        Spacer()
                        if edit{
                            DatePicker("", selection: $checkpoint2, in: Date.now...)
                                .onChange(of: checkpoint2) { newValue in
                                    ProjectDataController().editPoint2(project: project, checkpoint2: checkpoint2, context: managedObjContext)
                                }
                        }else{
                        let formatted = checkpoint2.formatted()
                        Text(formatted)
                            .foregroundColor(.gray)
                            .onLongPressGesture {
                                withAnimation {
                                    edit = true
                                }
                            }
                        Image(systemName: "clock.fill")
                            .foregroundColor(.gray)
                        }
                    }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                }
                if project.check1done && !project.check2done{
                    HStack{
                    Text(project.goal3!)
                            .bold()
                        Spacer()
                        Text(project.checkpoint3!, style: .date)
                            .foregroundColor(.gray)
                        Image(systemName: "clock.fill")
                            .foregroundColor(.gray)
                    }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                }
            }.padding()
            .onAppear(){
                checkpoint1 = project.checkpoint1!
                checkpoint2 = project.checkpoint2!
            }
            }header: {
                if edit{
                    Button {
                        withAnimation{
                        edit = false
                        }
                    } label: {
                        Text("Done")
                            .bold()
                    }
                }
            }
        }
        }
        .toolbar{
            ToolbarItem(placement: .bottomBar) {
                if extend{
                        Button {
                            withAnimation {
                                extend = false
                            }
                        } label: {
                            Text("Done")
                                .bold()
                        }.buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle(radius: 30))

                    }
            }
        }
        .navigationBarHidden(true)
    }
    }
    func daysBetween(start: Date, end: Date) -> Double {
        return Double(Calendar.current.dateComponents([.second], from: start, to: end).second!)
    }
    func daysBetweenNegative(start: Date, end: Date) -> Int {
        return (Calendar.current.dateComponents([.second], from: start, to: end).second!)
    }
}
