//
//  AddingResourceManagerView.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/4/22.
//

import SwiftUI
import AlertToast

struct AddingResourceManagerView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @Environment(\.dismiss) var dismiss
    var link: FetchedResults<Links>.Element
    @State private var Added = false
    var body: some View {
        NavigationView{
            Form{
            VStack{
                List{
                    ForEach(assignment){assign in
                        Button {
                            Added.toggle()
                            AssignmentDataController().editAssignLink(assign: assign, link: link.link!, context: managedObjContext)
                            simpleSuccess()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                                dismiss()
                            }
                        } label: {
                            HStack{
                            Text(assign.name!)
                                Spacer()
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
        }
            .navigationTitle("\(link.linname!)")
        }.toast(isPresenting: $Added) {
            AlertToast(displayMode: .banner(.pop), type: .complete(.blue), title: "Link Added", style: .style(backgroundColor: Color(.systemGray4), titleColor: .black, subTitleColor: .black, titleFont: .system(size: 30, weight: .heavy, design: .rounded), subTitleFont: .title))
        }
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct AddingImageManagerView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @Environment(\.dismiss) var dismiss
    var image: FetchedResults<Images>.Element
    @State private var Added = false
    var body: some View {
        NavigationView{
            Form{
                HStack{
                Image(uiImage: UIImage(data: image.imageD!)!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150, alignment: .leading)
                    .cornerRadius(20)
                    
                    Text(image.imagetitle!)
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                }.padding()
                Section{
                List{
                    ForEach(assignment){assign in
                        Button {
                            Added.toggle()
                            AssignmentDataController().editAssignImage(assign: assign, imagedata: image.imageD!, imagetitle: image.imagetitle!, context: managedObjContext)
                            simpleSuccess()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                                dismiss()
                            }
                        } label: {
                            HStack{
                            Text(assign.name!)
                                Spacer()
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
        }
        }.toast(isPresenting: $Added) {
            AlertToast(displayMode: .banner(.pop), type: .complete(.blue), title: "Image Added", style: .style(backgroundColor: Color(.systemGray4), titleColor: .black, subTitleColor: .black, titleFont: .system(size: 30, weight: .heavy, design: .rounded), subTitleFont: .title))
        }
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

