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
    
    func addAssign(topic: String, color: String, duedate: Date, name: String, complete: Bool, book: Bool, sidenotes: String, context: NSManagedObjectContext) {
        let assign = Assignment(context: context)
        assign.id = UUID()
        assign.topic = topic
        assign.color = color
        assign.duedate = duedate
        assign.name = name
        assign.complete = complete
        assign.book = book
        assign.sidenotes = sidenotes
        save(context: context)
    }
    func editAssignNotes(assign: Assignment, sidenotes: String, context: NSManagedObjectContext){
        assign.sidenotes = sidenotes
        save(context: context)
    }
    
    func editAssign(assign: Assignment, complete: Bool, context: NSManagedObjectContext) {
        assign.complete = complete
        save(context: context)
    }
    func editAssignLink(assign: Assignment, link: String, context: NSManagedObjectContext){
        assign.link = link
        save(context: context)
    }
    func editAssignName(assign: Assignment, name: String, context: NSManagedObjectContext){
        assign.name = name
        save(context: context)
    }
    func editAssignEdit(assign: Assignment, editmode: Bool, context: NSManagedObjectContext){
        assign.editmode = editmode
        save(context: context)
    }
    func editAssignTopic(assign: Assignment, changedtopic: Bool, context: NSManagedObjectContext){
        assign.changedtopic = changedtopic
        save(context: context)
    }
    func editAssignTopicName(assign: Assignment, topic: String, changedtopic: Bool, context: NSManagedObjectContext){
        assign.topic = topic
        assign.changedtopic = changedtopic
        save(context: context)
    }
    func editAssignImage(assign: Assignment, imagedata: Data, imagetitle: String, imagesize: Int64, context: NSManagedObjectContext)
    {
        assign.imagedata = imagedata
        assign.imagetitle = imagetitle
        assign.imagesize = imagesize
        save(context: context)
    }
}
