//
//  PeriodDataController.swift
//  SchoolOrganizerHelper
//
//  Created by Nate on 8/10/22.
//

import Foundation
import CoreData

class PeriodDataController: ObservableObject {
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
    
    func addPeriod(number: Int64, perioddate: Date, name: String, context: NSManagedObjectContext) {
        let period = Periods(context: context)
        period.id = UUID()
        period.number = number
        period.name = name
        period.perioddate = perioddate
        save(context: context)
    }
    func editSelect(period: Periods, selected: Bool, context: NSManagedObjectContext){
        period.selected = selected
        save(context: context)
    }
}
