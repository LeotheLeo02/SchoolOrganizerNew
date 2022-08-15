//
//  StudyDataController.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/15/22.
//

import Foundation
import CoreData

class StudyDataController: ObservableObject {
    // Responsible for preparing a model
    let container = NSPersistentContainer(name: "Period")
    
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
    
    func addStudySession(name: String, start: Date, end: Date, context: NSManagedObjectContext) {
        let study = StudySessions(context: context)
        study.id = UUID()
        study.name = name
        study.start = start
        study.end = end
        save(context: context)
    }
    func editStudyTime(study: StudySessions, start: Date, end: Date, context: NSManagedObjectContext){
        study.start = start
        study.end = end
        save(context: context)
    }
}
