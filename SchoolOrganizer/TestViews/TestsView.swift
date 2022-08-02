//
//  TestsView.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import SwiftUI

struct TestsView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.testname)]) var test: FetchedResults<Tests>
    @Environment(\.managedObjectContext) var managedObjContext
    @State private var AddTest = false
    var body: some View {
        NavigationView{
            List{
                ForEach(test){tes in
                    Text(tes.testname!)
                    //For some reason the date is nil even though its added
                    Text(tes.testdate!.addingTimeInterval(600), style: .date)
                }
            }
            .sheet(isPresented: $AddTest, content: {
                AddTestView()
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        AddTest.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                    }

                }
            }
            .navigationTitle("Tests")
        }
    }
}

struct TestsView_Previews: PreviewProvider {
    static var previews: some View {
        TestsView()
    }
}
