//
//  HistoryDataController.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/3/22.
//

import Foundation
import CoreData

class HistoryDataController: ObservableObject {
    // Responsible for preparing a model
    let container = NSPersistentContainer(name: "History")
    
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
    
    func addHistoryTest(testnames: String, context: NSManagedObjectContext) {
        let history = History(context: context)
        history.testnames = testnames
        save(context: context)
    }
    
    func addHistroyAssignment(assignmentnames: String, context: NSManagedObjectContext) {
        let history = History(context: context)
        history.assignmentnames = assignmentnames
        save(context: context)
    }
}
