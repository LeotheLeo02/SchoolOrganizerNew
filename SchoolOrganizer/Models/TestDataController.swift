//
//  TestDataController.swift
//  SchoolOrganizer
//
//  Created by Nate on 8/2/22.
//

import Foundation
import CoreData

class TestDataController: ObservableObject {
    // Responsible for preparing a model
    let container = NSPersistentContainer(name: "Tests")
    
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
    
    func addTest(testname: String, topic: String, testdate: Date, context: NSManagedObjectContext) {
        let test = Tests(context: context)
        test.id = UUID()
        test.testname = testname
        test.testtopic = topic
        test.testdate = testdate
        save(context: context)
    }
    
    func editTestScore(test: Tests,testscore: Int64, context: NSManagedObjectContext) {
        test.score = testscore
        save(context: context)
    }
    
    func AddTestQuestion(test: Tests, question: String, question2: String?, context: NSManagedObjectContext){
        test.question = question
        test.question2 = question2
    }
}
