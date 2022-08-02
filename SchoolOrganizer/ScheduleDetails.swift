//
//  ScheduleDetails.swift
//  SchoolKit
//
//  Created by Nate on 7/31/22.
//

import SwiftUI

struct ScheduleDetails: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Form{
            Section {
                ForEach(assignment){assign in
                    let days = daysBetween(start: Date.now, end: assign.duedate!)
                    if (days <= 3){
                        HStack{
                        Text(assign.topic!)
                            .foregroundColor(.black)
                            .bold()
                            .font(.title)
                            Spacer()
                            Text(assign.duedate!.addingTimeInterval(600), style: .date)
                            .foregroundColor(.black)
                            .bold()
                        }.padding()
                    }
                }
            } header: {
                Text("URGENT")
                    .underline()
                    .foregroundColor(.red)
                    .font(.largeTitle)
                    .bold()
            }
            Section {
                ForEach(assignment){assign in
                    let days = daysBetween(start: Date.now, end: assign.duedate!)
                    if (days < 7 && days > 3){
                        HStack{
                        Text(assign.topic!)
                            .foregroundColor(.black)
                            .bold()
                            .font(.title)
                        Spacer()
                            Text(assign.duedate!.addingTimeInterval(600), style: .date)
                                .foregroundColor(.black)
                                .bold()
                        }.padding()
                    }
                }
            } header: {
                Text("OK")
                    .underline()
                    .foregroundColor(.yellow)
                    .font(.largeTitle)
                    .bold()
            }

            Section {
                ForEach(assignment){assign in
                    let days = daysBetween(start: Date.now, end: assign.duedate!)
                    if (days >= 7){
                        HStack{
                        Text(assign.topic!)
                            .foregroundColor(.black)
                            .bold()
                            .font(.title)
                            Spacer()
                            Text(assign.duedate!.addingTimeInterval(600), style: .date)
                                .foregroundColor(.black)
                                .bold()
                        }.padding()
                    }
                }
            } header: {
                Text("Good")
                    .underline()
                    .foregroundColor(.green)
                    .font(.largeTitle)
                    .bold()
            }


        }
    }
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
}

struct ScheduleDetails_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleDetails()
    }
}
