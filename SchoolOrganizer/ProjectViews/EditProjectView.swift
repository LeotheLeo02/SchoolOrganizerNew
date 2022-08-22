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
        VStack{
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
                if !project.check1done{
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
                                print(between)
                                print(daysnowandend)
                            }
                            .progressViewStyle(GaugeProgressStyle())
                            .frame(width: 25, height: 25)
                    }
                    }
                }
            }
        }
    }
    func daysBetween(start: Date, end: Date) -> Double {
        return Double(Calendar.current.dateComponents([.second], from: start, to: end).second!)
    }
}
