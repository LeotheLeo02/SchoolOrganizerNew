//
//  TopicDataController.swift
//  SchoolKit
//
//  Created by Nate on 8/1/22.
//


import Foundation
import CoreData

class TopicDataController: ObservableObject {
    // Responsible for preparing a model
    let container = NSPersistentContainer(name: "Topics")
    
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
    
    func addTopic(topicname: String, context: NSManagedObjectContext) {
        let topic = Topics(context: context)
        topic.id = UUID()
        topic.topicname = topicname
        save(context: context)
    }
    
}
