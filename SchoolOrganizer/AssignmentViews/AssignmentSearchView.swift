//
//  AssignmentSearchView.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/6/22.
//

import SwiftUI

struct AssignmentSearchView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @State private var filter = ""
    @FocusState private var focusField: Bool
    @Environment(\.dismiss) var dismiss
    var body: some View{
        VStack{
            HStack{
                Button {
                    dismiss()
                } label: {
                    Text("Leave")
                        .bold()
                }
            TextField("Search", text: $filter)
                .padding()
                .textFieldStyle(.roundedBorder)
                .focused($focusField)
                if filter.isEmpty{
                Image(systemName: "magnifyingglass")
                    .font(.title)
                    .foregroundColor(.blue)
                }else{
                    Button {
                       focusField = false
                    } label: {
                        Text("Done")
                    }
                    Button {
                        filter = ""
                    } label: {
                        Text("Clear")
                    }

                }
            }.padding()
            FilteredAssignmentList(filter: filter)
        }
    }
}

struct AssignmentSearchView_Previews: PreviewProvider {
    static var previews: some View {
        AssignmentSearchView()
    }
}
