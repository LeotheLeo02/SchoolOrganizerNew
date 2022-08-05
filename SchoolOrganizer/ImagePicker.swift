//
//  ImagePicker.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/4/22.
//
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var images: Data
    @Binding var show: Bool
    @Binding var camera: Bool
    func makeCoordinator() -> Coordinator {
        return ImagePicker.Coordinator(img1: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        
        let picker = UIImagePickerController()
        if camera{
            picker.sourceType = .camera
        }else{
        picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator
        
        return picker
        
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        //
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var img0 : ImagePicker
        init(img1 : ImagePicker){
            img0 = img1
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.img0.show.toggle()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            
            let data = image?.jpegData(compressionQuality: 0.50)
            
            self.img0.images = data!
            self.img0.show.toggle()
        }
    }
}

