//
//
//

import Foundation
import CoreData
import os.log

class OptimizedAssignmentController {
    
    private let dataController = SharedDataController.shared
    
    private let logger = Logger(subsystem: "com.schoolorganizer", category: "AssignmentController")
    
    
    func addAssignment(topic: String, color: String, duedate: Date, name: String, complete: Bool, book: Bool, sidenotes: String) {
        let context = dataController.viewContext
        
        let assign = Assignment(context: context)
        assign.id = UUID()
        assign.topic = topic
        assign.color = color
        assign.duedate = duedate
        assign.name = name
        assign.complete = complete
        assign.book = book
        assign.sidenotes = sidenotes
        
        logger.debug("Adding new assignment: \(name) for topic: \(topic)")
        dataController.saveViewContext()
    }
    
    func updateAssignmentsTopic(oldTopic: String, newTopic: String) {
        let predicate = NSPredicate(format: "topic == %@", oldTopic)
        let propertiesToUpdate = ["topic": newTopic, "changedtopic": true]
        
        logger.debug("Batch updating assignments from topic '\(oldTopic)' to '\(newTopic)'")
        dataController.batchUpdate(entityType: Assignment.self, predicate: predicate, propertiesToUpdate: propertiesToUpdate)
    }
    
    func completeAssignments(ids: [UUID]) {
        let uuidStrings = ids.map { $0.uuidString }
        let predicate = NSPredicate(format: "id IN %@", uuidStrings)
        let propertiesToUpdate = ["complete": true]
        
        logger.debug("Batch completing \(ids.count) assignments")
        dataController.batchUpdate(entityType: Assignment.self, predicate: predicate, propertiesToUpdate: propertiesToUpdate)
    }
    
    func updateAssignment(assignment: Assignment, updates: [AssignmentUpdate]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.updateAssignment(assignment: assignment, updates: updates)
            }
            return
        }
        
        logger.debug("Updating assignment: \(assignment.name ?? "unknown")")
        
        for update in updates {
            switch update {
            case .name(let name):
                assignment.name = name
            case .topic(let topic):
                assignment.topic = topic
            case .color(let color):
                assignment.color = color
            case .dueDate(let date):
                assignment.duedate = date
            case .complete(let complete):
                assignment.complete = complete
            case .book(let book):
                assignment.book = book
            case .sideNotes(let notes):
                assignment.sidenotes = notes
            case .link(let link):
                assignment.link = link
            case .editMode(let mode):
                assignment.editmode = mode
            case .changedTopic(let changed):
                assignment.changedtopic = changed
            case .image(let data, let title, let size):
                assignment.imagedata = data
                assignment.imagetitle = title
                assignment.imagesize = size
            }
        }
        
        dataController.saveViewContext()
    }
    
    func deleteAssignments(matching predicate: NSPredicate) {
        logger.debug("Batch deleting assignments with predicate: \(predicate)")
        dataController.batchDelete(entityType: Assignment.self, predicate: predicate)
    }
    
    
    func getAssignments(
        matching predicate: NSPredicate? = nil,
        sortedBy sortDescriptors: [NSSortDescriptor]? = nil,
        prefetchRelationships: [String]? = nil
    ) -> [Assignment] {
        let request = dataController.optimizedFetchRequest(
            for: Assignment.self,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            relationshipKeysToFetch: prefetchRelationships
        )
        
        do {
            let results = try dataController.viewContext.fetch(request)
            logger.debug("Fetched \(results.count) assignments")
            return results
        } catch {
            logger.error("Error fetching assignments: \(error.localizedDescription)")
            return []
        }
    }
    
    func getUpcomingAssignments(within hours: Int = 48) -> [Assignment] {
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .hour, value: hours, to: now)!
        
        let predicate = NSPredicate(format: "duedate >= %@ AND duedate <= %@ AND complete == NO", 
                                   now as NSDate, futureDate as NSDate)
        let sortDescriptors = [NSSortDescriptor(key: "duedate", ascending: true)]
        
        return getAssignments(matching: predicate, sortedBy: sortDescriptors)
    }
}

enum AssignmentUpdate {
    case name(String)
    case topic(String)
    case color(String)
    case dueDate(Date)
    case complete(Bool)
    case book(Bool)
    case sideNotes(String)
    case link(String)
    case editMode(Bool)
    case changedTopic(Bool)
    case image(Data, String, Int64)
}
