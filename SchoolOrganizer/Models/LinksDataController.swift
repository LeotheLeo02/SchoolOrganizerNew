//
//  LinksDataController.swift
//  SchoolKit
//
//  Created by Nate on 8/1/22.
//

import Foundation
import CoreData

class LinksDataController: ObservableObject {
    // Responsible for preparing a model
    let container = NSPersistentContainer(name: "Links")
    
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
    
    func addLink(linkn: String, linkname: String, context: NSManagedObjectContext) {
        let link = Links(context: context)
        link.id = UUID()
        link.link = linkn
        link.linname = linkname
        save(context: context)
    }
}
