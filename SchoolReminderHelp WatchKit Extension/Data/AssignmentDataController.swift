//
//  AssignmentDataController.swift
//  SchoolReminderHelp WatchKit Extension
//
//  Created by Nate on 8/12/22.
//

import Foundation
import CoreData

class AssignmentDataController: ObservableObject {
    // Responsible for preparing a model
    let container = NSPersistentContainer(name: "DataModel")
    
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
    
    func addAssign(name: String, reminddate: Date, context: NSManagedObjectContext) {
        let assign = Assignment(context: context)
        assign.id = UUID()
        assign.name = name
        assign.reminddate = reminddate
        save(context: context)
    }
}
