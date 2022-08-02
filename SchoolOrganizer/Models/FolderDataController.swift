//
//  FolderDataController.swift
//  SchoolKit
//
//  Created by Nate on 8/1/22.
//

import Foundation
import CoreData

class FolderDataController: ObservableObject {
    // Responsible for preparing a model
    let container = NSPersistentContainer(name: "Folder")
    
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
    
    func addFolder(foldername: String, context: NSManagedObjectContext) {
        let folder = Folder(context: context)
        folder.id = UUID()
        folder.foldername = foldername
        save(context: context)
    }
    
    func editFolder(folder: Folder,foldername: String, context: NSManagedObjectContext) {
        folder.foldername = foldername
        save(context: context)
    }
}
