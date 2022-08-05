//
//  ImageDataController.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/4/22.
//

import Foundation
import CoreData

class ImageDataController: ObservableObject {
    // Responsible for preparing a model
    let container = NSPersistentContainer(name: "Images")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Failed to load data in DataController \(error.localizedDescription)")
            }
        }
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Data saved successfully. WUHU!!!")
        } catch {
            // Handle errors in our database
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
        func addImage(imagetitle: String, imageD: Data,  context: NSManagedObjectContext) {
        let image = Images(context: context)
        image.id = UUID()
        image.imagetitle = imagetitle
        image.imageD = imageD
        save(context: context)
    }
}
