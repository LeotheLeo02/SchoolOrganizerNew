//
//  HistoryADataController.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/9/22.
//

import Foundation
import CoreData

class HistoryADataController: ObservableObject {
    // Responsible for preparing a model
    let container = NSPersistentContainer(name: "HistoryA")
    
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
    
    func addAssign(assignname: String, context: NSManagedObjectContext) {
        let historya = HistoryA(context: context)
        historya.id = UUID()
        historya.assignname = assignname
        save(context: context)
    }
}
