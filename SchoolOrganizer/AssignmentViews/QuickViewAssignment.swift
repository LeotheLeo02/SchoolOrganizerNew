//
//  QuickViewAssignment.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/14/22.
//

import SwiftUI

struct QuickViewAssignment: View {
    var assignment: FetchedResults<Assignment>.Element
    @Environment(\.managedObjectContext) var managedObjContext
    @State private var edit = false
    @State private var name = ""
    @State private var complete = false
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
                        .if(assignment.color == "Purple"){ view in
                            view.foregroundColor(.purple)
                        }
                Text(assignment.topic!)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
            }
            Button {
                withAnimation{
                    if edit{
                    AssignmentDataController().editAssignName(assign: assignment, name: name, context: managedObjContext)
                    }
                    edit.toggle()
                }
            } label: {
                if edit == false{
                Image(systemName: "square.and.pencil")
                        .font(.title)
                }else{
                    Text("Done")
                        .bold()
                }
                
            }.buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
            if edit{
                TextField("Name...", text: $name)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .onAppear(){
                        name = assignment.name!
                    }
            }
            Button {
                withAnimation{
                    complete.toggle()
                    AssignmentDataController().editAssign(assign: assignment, complete: complete, context: managedObjContext)
                    if complete{
                    simpleSuccess()
                    }
                }
            } label: {
                Image(systemName: complete ?  "checkmark.circle.fill":"circle")
                    .foregroundColor(.green)
                    .font(.largeTitle)
            }.onAppear(){
                complete = assignment.complete
            }

        }.padding()
        .background(Color(.systemGray5))
        .cornerRadius(20)
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
