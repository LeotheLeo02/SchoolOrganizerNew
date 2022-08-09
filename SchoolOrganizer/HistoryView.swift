//
//  HistoryView.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/9/22.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.assignname)]) var historya: FetchedResults<HistoryA>
    var body: some View {
        NavigationView{
            ScrollView{
        ForEach(historya){hisa in
            VStack{
            HStack{
            Text(hisa.assignname!)
                    .bold()
                Spacer()
                Text("A")
                    .font(.system(size: 50, weight: .heavy, design: .rounded))
                    .if(hisa.assigncolor == "Red") { Text in
                        Text.foregroundColor(.red)
                    }
                    .if(hisa.assigncolor == "Blue") { Text in
                        Text.foregroundColor(.blue)
                    }
                    .if(hisa.assigncolor == "Yellow") { Text in
                        Text.foregroundColor(.yellow)
                    }
                Text(hisa.assigndate!, style: .date)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.gray)
                Text(hisa.assigndate!, style: .time)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.gray)
            }.padding()
                
        }.padding()
            .background(Color(.systemGray6))
            .cornerRadius(20)
        }
            }.padding()
        .navigationTitle("History")
    }
    }
    //Add Delete
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
