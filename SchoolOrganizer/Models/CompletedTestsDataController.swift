//
//  CompletedTestsDataController.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/10/22.
//
import Foundation
import CoreData

class CompletedTestsDataController: ObservableObject {
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
    
    func addTest(nameoftest: String, scoreoftest: Int64, dateoftest: Date,  context: NSManagedObjectContext) {
        let test = CompletedTest(context: context)
        test.id = UUID()
        test.nameoftest = nameoftest
        test.scoreoftest = scoreoftest
        test.dateoftest = dateoftest
        save(context: context)
    }
    
    func editTestView(completedtest: CompletedTest, hidescore: Bool, context: NSManagedObjectContext) {
        completedtest.hidescore = hidescore
        save(context: context)
    }
}
