//
//  PastNamesDataController.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/4/22.
//
import Foundation
import CoreData

class PastNamesDataController: ObservableObject {
    // Responsible for preparing a model
    let container = NSPersistentContainer(name: "Past")
    
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
    
    func addName(pastnames: String, context: NSManagedObjectContext) {
        let past = PastNames(context: context)
        past.id = UUID()
        past.pastnames = pastnames
        save(context: context)
    }
}
