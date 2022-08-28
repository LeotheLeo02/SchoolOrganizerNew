//
//  ProjectDataController.swift
//  SchoolOrganizerPlus
//
//  Created by Nate on 8/22/22.
//

import Foundation
import CoreData

class ProjectDataController: ObservableObject {
    // Responsible for preparing a model
    let container = NSPersistentContainer(name: "Projects")
    
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
    
    func addProject(name: String, goal1: String, goal2: String, goal3: String, checkpoint1: Date, checkpoint2: Date, checkpoint3: Date,duedate: Date, startdate: Date, context: NSManagedObjectContext) {
        let project = Projects(context: context)
        project.name = name
        project.goal1 = goal1
        project.goal2 = goal2
        project.goal3 = goal3
        project.checkpoint1 = checkpoint1
        project.checkpoint2 = checkpoint2
        project.checkpoint3 = checkpoint3
        project.duedate = duedate
        project.startdate = startdate
        project.id = UUID()
        save(context: context)
    }
    func editCheck1(project: Projects, check1done: Bool, context: NSManagedObjectContext){
        project.check1done = check1done
        save(context: context)
    }
    func editCheck2(project: Projects, check2done: Bool, context: NSManagedObjectContext){
        project.check2done = check2done
        save(context: context)
    }
    func editCheck3(project: Projects, check3done: Bool, context: NSManagedObjectContext){
        project.check3done = check3done
        save(context: context)
    }
    func editPoint(project: Projects, checkpoint1: Date, context: NSManagedObjectContext){
        project.checkpoint1 = checkpoint1
        save(context: context)
    }
    func editPoint2(project: Projects, checkpoint2: Date, context: NSManagedObjectContext){
        project.checkpoint2 = checkpoint2
        save(context: context)
    }
    func editPoint3(project: Projects, checkpoint3: Date, context: NSManagedObjectContext){
        project.checkpoint3 = checkpoint3
        save(context: context)
    }
    
}
