//
//  FolderView.swift
//  SchoolKit
//
//  Created by Nate on 8/1/22.
//

import SwiftUI
import AVKit
import AlertToast
struct FolderView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.link)]) var link: FetchedResults<Links>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.imagetitle)]) var Images: FetchedResults<Images>
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusontitle: Bool
    @State private var siteLink = ""
    @State private var linkname = ""
    @State private var showAlert = false
    @State private var addlink = false
    @State private var image: Data = .init(count: 0)
    @State private var imagetitle = ""
    @State private var imagepicker = false
    @State private var addimage = false
    @State private var camera = false
    @State private var Added = false
    @State private var AddedLink = false
    @State private var FrameImage = false
    @State private var addingValue: Int64 = 0
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
                            Menu {
                                ForEach(assignment){assign in
                                    Button {
                                        AddedLink.toggle()
                                        AssignmentDataController().editAssignLink(assign: assign, link: lin.link!, context: managedObjContext)
                                        simpleSuccess()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                                            dismiss()
                                        }
                                    } label: {
                                        HStack{
                                        Text(assign.name!)
                                            Spacer()
                                            Image(systemName: "plus")
                                        }
                                    }
                                }
                            } label: {
                                HStack{
                                    Spacer()
                                Image(systemName: "plus.app.fill")
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundColor(.blue)
                                        .font(.largeTitle)
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
            
                Section{
                    HStack{
            if image.count != 0 {
                Menu {
                    Button {
                        imagepicker.toggle()
                        camera = false
                    } label: {
                        Text("Photos Library")
                        Image(systemName: "photo.on.rectangle.angled")
                    }
                    Button {
                        imagepicker.toggle()
                        camera = true
                    } label: {
                        Text("Use Camera")
                        Image(systemName: "camera.fill")
                    }

                } label: {
                    HStack{
                    Image(uiImage: UIImage(data: image)!)
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 150, height: 150)
                        .cornerRadius(20)
                    }
                }
                VStack{
                TextField("Title of Picture", text: $imagetitle)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusontitle)
                    if !imagetitle.trimmingCharacters(in: .whitespaces).isEmpty{
                        Button {
                            withAnimation{
                            ImageDataController().addImage(imagetitle: imagetitle, imageD: image, context: managedObjContext)
                            image.count = 0
                            imagetitle = ""
                            }
                        } label: {
                            Text("Submit")
                        }

                    }
                }
            
            }else{
                Menu{
                            Button {
                                imagepicker.toggle()
                                camera = false
                            } label: {
                                Text("Photos Library")
                                Image(systemName: "photo.on.rectangle.angled")
                            }
                            Button {
                                imagepicker.toggle()
                                camera = true
                            } label: {
                                Text("Use Camera")
                                Image(systemName: "camera.fill")
                            }


                        }label: {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .frame(width: 150, height: 150)
                                .cornerRadius(20)
                                .foregroundColor(.accentColor)
                        }
                Text("No Photo Seleted")
                    .bold()
                    .foregroundColor(.gray)
                    .padding()
                    
            }
                    }.onChange(of: image.count) { newValue in
                        focusontitle.toggle()
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
                            VStack{
                        Text(imag.imagetitle!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    Menu{
                                         ForEach(assignment){assign in
                                             Button {
                                                 FrameImage.toggle()
                                             } label: {
                                                 HStack{
                                                 Text(assign.name!)
                                                     Spacer()
                                                     Image(systemName: "plus")
                                                 }.onChange(of: addingValue) { V in
                                                     AssignmentDataController().editAssignImage(assign: assign, imagedata: imag.imageD!, imagetitle: imag.imagetitle!, imagesize: addingValue, context: managedObjContext)
                                                     Added.toggle()
                                                     simpleSuccess()
                                                     DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                                                         dismiss()
                                                     }
                                                 }
                                             }

                                         }
                                    }label: {
                                        Text("Add To")
                                            .bold()
                                    }
                                .padding()

                            }.confirmationDialog("Select Image Size", isPresented: $FrameImage, titleVisibility: .visible){
                                Button {
                                    addingValue = 3
                                } label: {
                                    Text("Large")
                                }
                                Button {
                                    addingValue = 2
                                } label: {
                                    Text("Medium")
                                }
                                Button {
                                    addingValue = 1
                                } label: {
                                    Text("Small")
                                }

                            }
                        }
                    }.onDelete(perform: deleteImage)
            }

            }.alert(isPresented: $showAlert){
                Alert(title: Text("Missing Information"), message: Text("You must have a valid link and a name"), dismissButton: .cancel(Text("Ok")))
            }
            .sheet(isPresented: $imagepicker) {
                ImagePicker(images: $image, show: $imagepicker, camera: $camera)
            }
            .toast(isPresenting: $Added) {
                AlertToast(displayMode: .banner(.pop), type: .complete(.blue), title: "Image Added", style: .style(backgroundColor: Color(.systemGray4), titleColor: .black, subTitleColor: .black, titleFont: .system(size: 30, weight: .heavy, design: .rounded), subTitleFont: .title))
            }
            .toast(isPresenting: $AddedLink) {
                AlertToast(displayMode: .banner(.pop), type: .complete(.blue), title: "Link Added", style: .style(backgroundColor: Color(.systemGray4), titleColor: .black, subTitleColor: .black, titleFont: .system(size: 30, weight: .heavy, design: .rounded), subTitleFont: .title))
            }
        }
    }
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
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
