//
//  FilteredAssignmentList.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/6/22.
//

import SwiftUI

struct FilteredAssignmentList: View {
    @FetchRequest var fetchRequest: FetchedResults<Assignment>
    var body: some View {
        NavigationView{
            if fetchRequest.isEmpty{
                Text("No Items Found")
                    .foregroundColor(.gray)
            }
        List(fetchRequest, id: \.self){ assign in
            NavigationLink(destination: EditAssignment(assignment: assign)){
            Text(assign.name!)
            }
        }
        .navigationBarHidden(true)
    }
    }
    
    init(filter: String){
        _fetchRequest = FetchRequest<Assignment>(sortDescriptors: [], predicate: NSPredicate(format: "name CONTAINS[c] %@", filter))
    }
}
