//
//  FolderView.swift
//  SchoolKit
//
//  Created by Nate on 8/1/22.
//

import SwiftUI
import AVKit
struct FolderView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.link)]) var link: FetchedResults<Links>
    @State private var siteLink = ""
    @State private var linkname = ""
    @State private var showAlert = false
    var body: some View {
        VStack{
            Form{
                Section{
                    TextField("Link Name", text: $linkname)
                    TextField("Link", text: $siteLink)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                    List{
                        ForEach(link){lin in
                            if lin.linname != nil{
                                HStack{
                                    Spacer()
                                VStack(alignment: .center){
                                    Text(lin.linname!)
                                        .bold()
                                        .underline()
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                Link("\(lin.link!)", destination: URL(string: lin.link!)!)
                                        .foregroundColor(.white)
                                }.padding()
                                    .background(Color.blue)
                                    .cornerRadius(20)
                                    Spacer()
                            }
                            }
                        }.onDelete(perform: deleteLink)
                    }
                } header: {
                    Text("Links")
                        .bold()
                        .foregroundColor(.blue)
                }
                Button {
                    withAnimation{
                    let isValid = canOpenURL(siteLink)
                    if isValid && !linkname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                    LinksDataController().addLink(linkn: siteLink, linkname: linkname, context: managedObjContext)
                        siteLink = ""
                        linkname = ""
                    }else{
                        showAlert.toggle()
                    }
                    }
                } label: {
                    HStack{
                        Spacer()
                    Text("Submit")
                        Spacer()
                    }
                }

            }.alert(isPresented: $showAlert){
                Alert(title: Text("Missing Information"), message: Text("You must have a valid link and a name"), dismissButton: .cancel(Text("Ok")))
            }
        }
    }
    func canOpenURL(_ string: String?) -> Bool {
        guard let urlString = string,
            let url = URL(string: urlString)
            else { return false }

        if !UIApplication.shared.canOpenURL(url) { return false }

        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    private func deleteLink(offsets: IndexSet) {
        withAnimation {
            offsets.map { link[$0] }
            .forEach(managedObjContext.delete)
            
            // Saves to our database
            LinksDataController().save(context: managedObjContext)
        }
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView()
    }
}
