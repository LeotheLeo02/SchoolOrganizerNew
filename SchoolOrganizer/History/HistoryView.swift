//
//  History View.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/3/22.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateadded)]) var historyassignment: FetchedResults<HistoryA>
    var body: some View {
        NavigationView{
        VStack{
            List{
                ForEach(historyassignment){hisa in
                    HStack{
                    Text(hisa.historynamea!)
                        .font(.system(size: 25, weight: .heavy, design: .rounded))
                        Spacer()
                        Text(hisa.dateadded ?? Date.distantFuture.addingTimeInterval(600), style: .time)
                    }
                }
            }
        }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
