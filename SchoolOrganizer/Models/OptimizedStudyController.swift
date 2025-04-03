//
//
//

import Foundation
import CoreData
import os.log

class OptimizedStudyController {
    
    private let dataController = SharedDataController.shared
    
    private let logger = Logger(subsystem: "com.schoolorganizer", category: "StudyController")
    
    
    func addStudySession(name: String, topic: String, startTime: Date, endTime: Date, intensity: Int64) {
        let context = dataController.viewContext
        
        let session = StudySessions(context: context)
        session.id = UUID()
        session.name = name
        session.topic = topic
        session.starttime = startTime
        session.endtime = endTime
        session.intensity = intensity
        
        logger.debug("Adding new study session: \(name) for topic: \(topic)")
        dataController.saveViewContext()
    }
    
    func updateStudySession(session: StudySessions, updates: [StudySessionUpdate]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.updateStudySession(session: session, updates: updates)
            }
            return
        }
        
        logger.debug("Updating study session: \(session.name ?? "unknown")")
        
        for update in updates {
            switch update {
            case .name(let name):
                session.name = name
            case .topic(let topic):
                session.topic = topic
            case .startTime(let time):
                session.starttime = time
            case .endTime(let time):
                session.endtime = time
            case .intensity(let intensity):
                session.intensity = intensity
            }
        }
        
        dataController.saveViewContext()
    }
    
    func updateStudySessionsTopic(oldTopic: String, newTopic: String) {
        let predicate = NSPredicate(format: "topic == %@", oldTopic)
        let propertiesToUpdate = ["topic": newTopic]
        
        logger.debug("Batch updating study sessions from topic '\(oldTopic)' to '\(newTopic)'")
        dataController.batchUpdate(entityType: StudySessions.self, predicate: predicate, propertiesToUpdate: propertiesToUpdate)
    }
    
    func deleteStudySessions(matching predicate: NSPredicate) {
        logger.debug("Batch deleting study sessions with predicate: \(predicate)")
        dataController.batchDelete(entityType: StudySessions.self, predicate: predicate)
    }
    
    
    func getStudySessions(
        matching predicate: NSPredicate? = nil,
        sortedBy sortDescriptors: [NSSortDescriptor]? = nil
    ) -> [StudySessions] {
        let request = dataController.optimizedFetchRequest(
            for: StudySessions.self,
            predicate: predicate,
            sortDescriptors: sortDescriptors
        )
        
        do {
            let results = try dataController.viewContext.fetch(request)
            logger.debug("Fetched \(results.count) study sessions")
            return results
        } catch {
            logger.error("Error fetching study sessions: \(error.localizedDescription)")
            return []
        }
    }
    
    func getUpcomingStudySessions(within hours: Int = 48) -> [StudySessions] {
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .hour, value: hours, to: now)!
        
        let predicate = NSPredicate(format: "starttime >= %@ AND starttime <= %@", now as NSDate, futureDate as NSDate)
        let sortDescriptors = [NSSortDescriptor(key: "starttime", ascending: true)]
        
        return getStudySessions(matching: predicate, sortedBy: sortDescriptors)
    }
}

enum StudySessionUpdate {
    case name(String)
    case topic(String)
    case startTime(Date)
    case endTime(Date)
    case intensity(Int64)
}
