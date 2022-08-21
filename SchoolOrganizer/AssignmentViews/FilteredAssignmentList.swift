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
            ScrollView{
            VStack{
            if fetchRequest.isEmpty{
                Text("No Items Found")
                    .foregroundColor(.gray)
            }
        ForEach(fetchRequest, id: \.self){ assign in
            HStack{
                Spacer()
            QuickViewAssignment(assignment: assign)
                    .scaledToFill()
                Spacer()
            }
        }
        }
        }
        .navigationBarHidden(true)
    }
        .navigationViewStyle(.stack)
    }
    
    init(filter: String){
        _fetchRequest = FetchRequest<Assignment>(sortDescriptors: [], predicate: NSPredicate(format: "name CONTAINS[c] %@", filter))
    }
}
