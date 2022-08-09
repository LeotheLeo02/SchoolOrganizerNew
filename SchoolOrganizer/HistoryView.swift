//
//  HistoryView.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/9/22.
//

import SwiftUI

struct HistoryView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.assignname)]) var historya: FetchedResults<HistoryA>
    var body: some View {
        ForEach(historya){hisa in
            Text(hisa.assignname!)
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
