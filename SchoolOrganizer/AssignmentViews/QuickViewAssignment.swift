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
            DisclosureGroup("Resources") {
                if assignment.imagedata != nil{
                    VStack{
                    Image(uiImage: UIImage(data: assignment.imagedata!)!)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .if(assignment.imagesize == 1, transform: { View in
                            View.frame(width: 150, height: 150, alignment: .center)
                        })
                        .if(assignment.imagesize == 2, transform: { View in
                            View.frame(width: 250, height: 250, alignment: .center)
                        })
                        .if(assignment.imagesize == 3, transform: { View in
                            View.frame(width: 350, height: 350, alignment: .center)
                        })
                        Text(assignment.imagetitle!)
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                    }.padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    .contextMenu{
                        Button(role: .destructive) {
                            withAnimation{
                            assignment.imagedata = nil
                                assignment.imagetitle = ""
                                assignment.imagesize = 0
                                try? managedObjContext.save()
                            }
                        } label: {
                            HStack{
                            Text("Delete Image")
                                Image(systemName: "trash")
                            }
                        }

                    }
                }
            }
    }
    }
}
