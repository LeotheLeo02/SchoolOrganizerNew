//
//  FolderView.swift
//  SchoolKit
//
//  Created by Nate on 8/1/22.
//

import SwiftUI
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
    @Environment(\.colorScheme) var colorScheme
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
    @State private var addedName = ""
    @State private var sizename = ""
    var body: some View {
        NavigationView{
        VStack{
            Form{
                Section{
                    TextField("Link Name", text: $linkname)
                    TextField("Link", text: $siteLink)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .textInputAutocapitalization(.never)
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
                                if assignment.isEmpty{
                                    Text("No Assignments Made")
                                }
                                ForEach(assignment){assign in
                                    Button {
                                        AddedLink.toggle()
                                        AssignmentDataController().editAssignLink(assign: assign, link: lin.link!, context: managedObjContext)
                                        simpleSuccess()
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
                .headerProminence(.increased)
                Button {
                    withAnimation{
                        if !siteLink.contains("https://"){
                            siteLink = "https://\(siteLink)"
                        }
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
            if !image.isEmpty {
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
                        .aspectRatio(contentMode: .fit)
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
                }header: {
                    Text("Add a Photo")
                }
                .headerProminence(.increased)
                Section{
                    ForEach(Images){imag in
                        VStack{
                        HStack{
                            Spacer()
                            VStack{
                        Image(uiImage: UIImage(data: imag.imageD ?? image)!)
                            .resizable()
                            .frame(width: 200, height: 200, alignment: .center)
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(15)
                            .padding()
                        Text(imag.imagetitle!)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                        }
                            Spacer()
                        }.padding()
                            AssignImageData(image: imag, added: $Added, sizename: $sizename, addedName: $addedName)
                                .onChange(of: Added) { V in
                                    simpleSuccess()
                                }
                        }
                    }.onDelete(perform: deleteImage)
                }header: {
                    if !Images.isEmpty{
                        Text("Images")
                    }
                }
                .headerProminence(.increased)
            }.alert(isPresented: $showAlert){
                Alert(title: Text("Missing Information"), message: Text("You must have a valid link and a name"), dismissButton: .cancel(Text("Ok")))
            }
            .sheet(isPresented: $imagepicker) {
                ImagePicker(images: $image, show: $imagepicker, camera: $camera)
            }
            .toast(isPresenting: $Added) {
                AlertToast(displayMode: .banner(.pop), type: .complete(.blue), title: "\(sizename) \(addedName) Added", style: .style(backgroundColor: Color(.systemGray4), titleColor: colorScheme == .dark ? .white:.black, subTitleColor: .black, titleFont: .system(size: 20, weight: .heavy, design: .rounded), subTitleFont: .title))
            }
            .toast(isPresenting: $AddedLink) {
                AlertToast(displayMode: .banner(.pop), type: .complete(.blue), title: "Link Added", style: .style(backgroundColor: Color(.systemGray4), titleColor: colorScheme == .dark ? .white:.black, subTitleColor: .black, titleFont: .system(size: 30, weight: .heavy, design: .rounded), subTitleFont: .title))
            }
        }
        .navigationTitle("Folder")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction){
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }

            }
        }
    }
        .navigationViewStyle(.stack)
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
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
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


struct AddSchoolPeriod: View{
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: [SortDescriptor(\.number)]) var period: FetchedResults<Periods>
    @FocusState var focusonname: Bool
    @State private var periodname = ""
    @State private var periodtime = Date()
    @State private var periodnumber: Int64 = 0
    @State private var numbers: [Int64] = [1, 2, 3, 4, 5, 6, 7]
    @State private var existingalert = false
    @State private var present = false
    @State private var replacenumber: Int = 0
    @Binding var swapped: Bool
    var body: some View{
        Form{
            Section{
                VStack{
                TextField("Enter School Period Name", text: $periodname)
                        .focused($focusonname)
                        .textFieldStyle(.roundedBorder)
                        .onAppear(){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            focusonname = true
                        }
                        }
                    DatePicker("Choose Time", selection: $periodtime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.graphical)
                    Menu{
                        ForEach(numbers, id: \.self){num in
                            Button {
                                periodnumber = num
                            } label: {
                                Text("\(Int64(num))")
                            }
                        }
                    }label: {
                        Text("Choose School Period Number")
                    }
                    if periodnumber != 0 {
                        Text("\(Int64(periodnumber))")
                    }                }
            }.alert("This period is already filled. What Do you Want To Do", isPresented: $present) {
                Button("Replace") {
                    replacenumber = Int(periodnumber)
                    PeriodDataController().addPeriod(number: periodnumber, perioddate: periodtime, name: periodname, context: managedObjContext)
                    dismiss()
                    swapped.toggle()
                }
                Button("Cancel"){
                    
                }
            }
            Button {
                if existingalert{
                    present.toggle()
                }
                if !existingalert{
                PeriodDataController().addPeriod(number: periodnumber, perioddate: periodtime, name: periodname, context: managedObjContext)
                dismiss()
                }
            } label: {
                HStack{
                    Spacer()
                Text("Submit")
                    Spacer()
                }.buttonStyle(.bordered)
            }.disabled(periodnumber == 0 || periodname.trimmingCharacters(in: .whitespaces).isEmpty)
            List{
                ForEach(period){per in
                    HStack{
                        Text("\(per.number)")
                            .italic()
                            .foregroundColor(.gray)
                        Spacer()
                        Text(per.name!)
                            .italic()
                            .bold()
                            .foregroundColor(.gray)
                    }.onChange(of: periodnumber) { newValue in
                        if periodnumber == per.number{
                            withAnimation{
                            existingalert  = true
                            }
                        }else{
                            withAnimation{
                            existingalert = false
                            }
                        }
                    }
                    .onChange(of: replacenumber) { newValue in
                        if replacenumber == per.number {
                            per.managedObjectContext?.delete(per)
                                PeriodDataController().save(context: managedObjContext)
                        }
                    }
                }
            }
        }
    }
}
struct AssignImageData: View{
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.topic)]) var assignment: FetchedResults<Assignment>
    var image: FetchedResults<Images>.Element
    @Binding var added: Bool
    @State private var size = false
    @Binding var sizename: String
    @Binding var addedName: String
    var body: some View{
        ScrollView{
            ForEach(assignment){assign in
                Menu{
                    Button("Large"){
                        AssignmentDataController().editAssignImage(assign: assign, imagedata: image.imageD!, imagetitle: image.imagetitle!, imagesize: 3, context: managedObjContext)
                        added.toggle()
                        addedName = image.imagetitle!
                        sizename = "Large"
                    }
                    Button("Medium"){
                        AssignmentDataController().editAssignImage(assign: assign, imagedata: image.imageD!, imagetitle: image.imagetitle!, imagesize: 2, context: managedObjContext)
                        added.toggle()
                        addedName = image.imagetitle!
                        sizename = "Medium"
                    }
                    Button("Small"){
                        AssignmentDataController().editAssignImage(assign: assign, imagedata: image.imageD!, imagetitle: image.imagetitle!, imagesize: 1, context: managedObjContext)
                        added.toggle()
                        addedName = image.imagetitle!
                        sizename = "Small"
                    }
                }label: {
                    Text(assign.name!)
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .if(assign.color == "Blue"){view in
                            view.foregroundColor(.blue)
                        }
                        .if(assign.color == "Green"){ view in
                            view.foregroundColor(.green)
                        }
                        .if(assign.color == "Red"){ view in
                            view.foregroundColor(.red)
                        }
                        .if(assign.color == "Purple"){ view in
                            view.foregroundColor(.purple)
                        }
                        .padding(7)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                }
            }
        }
    }
}
