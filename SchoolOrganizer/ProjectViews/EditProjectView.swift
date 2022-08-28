//
//  EditProjectView.swift
//  SchoolOrganizerPlus
//
//  Created by Nate on 8/22/22.
//

import SwiftUI

struct EditProjectView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    var project: FetchedResults<Projects>.Element
    var body: some View {
        List{
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
                let percent = Int(between/daysnowandend * 100)
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
                        Text("\(percent)%")
                            .foregroundColor(.blue)
                            .bold()
                    }
                    Spacer()
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
                    let daysnowandend2 = daysBetween(start: Date.now, end: project.checkpoint2!)
                    let between2 = daysBetween(start: project.startdate!, end: Date.now)
                    let percent2 = Int(between2/daysnowandend2 * 100)
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
                            Text("\(percent2)%")
                                .foregroundColor(.blue)
                                .bold()
                        }
                        Spacer()
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
                    let percent3 = Int(between3/daysnowandend3 * 100)
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
                            Text("\(percent3)%")
                                .foregroundColor(.blue)
                                .bold()
                        }
                        Spacer()
                }

        }
            Section{
            VStack{
                if !project.check1done{
                    HStack{
                    Text(project.goal2!)
                            .bold()
                        Spacer()
                        Text("Upcoming")
                            .foregroundColor(.gray)
                        Image(systemName: "clock.fill")
                            .foregroundColor(.gray)
                    }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    Divider()
                    HStack{
                    Text(project.goal3!)
                            .bold()
                        Spacer()
                        Text("Upcoming")
                            .foregroundColor(.gray)
                        Image(systemName: "clock.fill")
                            .foregroundColor(.gray)
                    }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                }
                if project.check1done{
                    HStack{
                    Text(project.goal3!)
                            .bold()
                        Spacer()
                        Text("Upcoming")
                            .foregroundColor(.gray)
                        Image(systemName: "clock.fill")
                            .foregroundColor(.gray)
                    }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                }
            }
            }
        }.onAppear(){
            let check1 = daysBetweenNegative(start: Date.now, end: project.checkpoint1!)
            if check1 <= 0{
                project.check1done = true
            }
            let check2 = daysBetweenNegative(start: Date.now, end: project.checkpoint2!)
            if check2 <= 0{
                project.check2done = true
            }
            let check3 = daysBetweenNegative(start: Date.now, end: project.checkpoint3!)
            if check3 <= 0{
                project.check3done = true
            }
        }
    }
    func daysBetween(start: Date, end: Date) -> Double {
        return Double(Calendar.current.dateComponents([.second], from: start, to: end).second!)
    }
    func daysBetweenNegative(start: Date, end: Date) -> Int {
        return (Calendar.current.dateComponents([.second], from: start, to: end).second!)
    }
}
