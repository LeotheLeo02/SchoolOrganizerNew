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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.imagetitle)]) var Images: FetchedResults<Images>
    @State private var siteLink = ""
    @State private var linkname = ""
    @State private var showAlert = false
    @State private var addresource = false
    @State private var image: Data = .init(count: 0)
    @State private var imagetitle = ""
    @State private var imagepicker = false
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
                            Button {
                                addresource.toggle()
                            } label: {
                                HStack{
                                    Spacer()
                                Image(systemName: "plus.app.fill")
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundColor(.blue)
                                        .font(.largeTitle)
                                    Spacer()
                                }
                            }.sheet(isPresented: $addresource) {
                                AddingResourceManagerView(link: lin)
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
                Section{
                    ForEach(Images){imag in
                        HStack{
                        Image(uiImage: UIImage(data: imag.imageD ?? image)!)
                            .resizable()
                            .frame(width: 200, height: 200, alignment: .center)
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(15)
                            .padding()
                        Text(imag.imagetitle!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                        }
                    }.onDelete(perform: deleteImage)
                    HStack{
                        Spacer()
                if image.count != 0 {
                    Button {
                        imagepicker.toggle()
                    } label: {
                        HStack{
                        Image(uiImage: UIImage(data: image)!)
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 150, height: 150)
                            .cornerRadius(20)
                        }
                    }
                
                }else{
                    Button {
                        imagepicker.toggle()
                    } label: {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .cornerRadius(20)
                            .foregroundColor(.accentColor)
                    }

                }
                        Spacer()
                    }
                TextField("Title of Image", text: $imagetitle)
                        .multilineTextAlignment(.center)
                Button {
                    withAnimation{
                    ImageDataController().addImage(imagetitle: imagetitle, imageD: image, context: managedObjContext)
                    image.count = 0
                    imagetitle = ""
                    }
                } label: {
                    HStack{
                        Spacer()
                    Text("Submit")
                        Spacer()
                    }
                }
            }

            }.alert(isPresented: $showAlert){
                Alert(title: Text("Missing Information"), message: Text("You must have a valid link and a name"), dismissButton: .cancel(Text("Ok")))
            }
            .sheet(isPresented: $imagepicker) {
                ImagePicker(images: $image, show: $imagepicker)
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
    private func deleteImage(offsets: IndexSet) {
        withAnimation {
            offsets.map { Images[$0] }
            .forEach(managedObjContext.delete)
            
            // Saves to our database
            ImageDataController().save(context: managedObjContext)
        }
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView()
    }
}
