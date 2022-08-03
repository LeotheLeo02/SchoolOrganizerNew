//
//  AssignmentDataController.swift
//  SchoolKit
//
//  Created by Nate on 7/31/22.
//

import Foundation
import CoreData

class AssignmentDataController: ObservableObject {
    // Responsible for preparing a model
    let container = NSPersistentContainer(name: "SchoolModel")
    
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
    
    func addAssign(notes: String, topic: String, color: String, duedate: Date, name: String, complete: Bool, context: NSManagedObjectContext) {
        let assign = Assignment(context: context)
        assign.notes = notes
        assign.id = UUID()
        assign.topic = topic
        assign.color = color
        assign.duedate = duedate
        assign.name = name
        assign.complete = complete
        save(context: context)
    }
    
    func editAssign(assign: Assignment, complete: Bool, context: NSManagedObjectContext) {
        assign.complete = complete
        save(context: context)
    }
}
