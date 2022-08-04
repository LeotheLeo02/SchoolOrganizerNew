//
//  AddingResourceManagerView.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/4/22.
//

import SwiftUI

struct AddingResourceManagerView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @Environment(\.dismiss) var dismiss
    var link: FetchedResults<Links>.Element
    var body: some View {
        NavigationView{
            VStack{
                List{
                    ForEach(assignment){assign in
                        Button {
                            AssignmentDataController().editAssignResource(assign: assign, link: link.link!, context: managedObjContext)
                            dismiss()
                        } label: {
                            Text(assign.name!)
                        }
                    }
                }
            }
            .navigationTitle("\(link.linname!)")
        }
    }
}
