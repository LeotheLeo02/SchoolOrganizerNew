//
//  QuickViewAssignment.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/14/22.
//

import SwiftUI

struct QuickViewAssignment: View {
    var assignment: FetchedResults<Assignment>.Element
    @State private var edit = false
    @State private var name = ""
    var body: some View {
        VStack{
        Rectangle()
            .frame(width: 200, height: 200)
            .cornerRadius(20)
            .foregroundColor(Color(.systemGray6))
            .overlay {
                VStack{
                Text(assignment.name!)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .if(assignment.color == "Red") { View in
                            View.foregroundColor(.red)
                        }
                        .if(assignment.color == "Blue") { View in
                            View.foregroundColor(.blue)
                        }
                        .if(assignment.color == "Green") { View in
                            View.foregroundColor(.green)
                        }
                Text(assignment.topic!)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
            }
            Button {
                withAnimation{
                    edit.toggle()
                }
            } label: {
                if edit == false{
                Text("Edit")
                }else{
                    Text("Done")
                }
                
            }
            if edit{
                TextField("Name...", text: $name)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .onAppear(){
                        name = assignment.name!
                    }
                    .onChange(of: name) { newValue in
                        AssignmentDataController().editAssignName(assign: <#T##Assignment#>, name: <#T##String#>, context: <#T##NSManagedObjectContext#>)
                    }
            }
    }
    }
}
