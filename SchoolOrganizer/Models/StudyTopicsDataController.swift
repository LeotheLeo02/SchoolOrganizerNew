//
//  StudyTopicsDataController.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/16/22.
//
import Foundation
import CoreData

class StudyTopicsDataController: ObservableObject {
    // Responsible for preparing a model
    let container = NSPersistentContainer(name: "StudyTopics")
    
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
    
    func addStudyTopic(name: String, intensity: Double, context: NSManagedObjectContext) {
        let stopic = StudyTopics(context: context)
        stopic.id = UUID()
        stopic.name = name
        stopic.intensity = intensity
        save(context: context)
    }
    func editTopic(stopic: StudyTopics, studied: Bool, context: NSManagedObjectContext){
        stopic.studied = studied
        save(context: context)
    }
}
