//
//
//

import Foundation
import CoreData
import os.log

class OptimizedTestController {
    
    private let dataController = SharedDataController.shared
    
    private let logger = Logger(subsystem: "com.schoolorganizer", category: "TestController")
    
    
    func addTest(testname: String, topic: String, testdate: Date) {
        let context = dataController.viewContext
        
        let test = Tests(context: context)
        test.id = UUID()
        test.testname = testname
        test.testtopic = topic
        test.testdate = testdate
        
        logger.debug("Adding new test: \(testname) for topic: \(topic)")
        dataController.saveViewContext()
    }
    
    func updateTestsTopic(oldTopic: String, newTopic: String) {
        let predicate = NSPredicate(format: "testtopic == %@", oldTopic)
        let propertiesToUpdate = ["testtopic": newTopic, "changedtopic": true]
        
        logger.debug("Batch updating tests from topic '\(oldTopic)' to '\(newTopic)'")
        dataController.batchUpdate(entityType: Tests.self, predicate: predicate, propertiesToUpdate: propertiesToUpdate)
    }
    
    func updateTest(test: Tests, updates: [TestUpdate]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.updateTest(test: test, updates: updates)
            }
            return
        }
        
        logger.debug("Updating test: \(test.testname ?? "unknown")")
        
        for update in updates {
            switch update {
            case .name(let name):
                test.testname = name
            case .topic(let topic):
                test.testtopic = topic
            case .date(let date):
                test.testdate = date
            case .score(let score):
                test.score = score
            case .dateSubmitted(let date):
                test.datesubmitted = date
            case .changedTopic(let changed):
                test.changedtopic = changed
            case .questions(let q1, let q2):
                test.question = q1
                test.question2 = q2
            }
        }
        
        dataController.saveViewContext()
    }
    
    func deleteTests(matching predicate: NSPredicate) {
        logger.debug("Batch deleting tests with predicate: \(predicate)")
        dataController.batchDelete(entityType: Tests.self, predicate: predicate)
    }
    
    
    func getTests(
        matching predicate: NSPredicate? = nil,
        sortedBy sortDescriptors: [NSSortDescriptor]? = nil,
        prefetchRelationships: [String]? = nil
    ) -> [Tests] {
        let request = dataController.optimizedFetchRequest(
            for: Tests.self,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            relationshipKeysToFetch: prefetchRelationships
        )
        
        do {
            let results = try dataController.viewContext.fetch(request)
            logger.debug("Fetched \(results.count) tests")
            return results
        } catch {
            logger.error("Error fetching tests: \(error.localizedDescription)")
            return []
        }
    }
    
    func getUpcomingTests(within hours: Int = 48) -> [Tests] {
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .hour, value: hours, to: now)!
        
        let predicate = NSPredicate(format: "testdate >= %@ AND testdate <= %@", now as NSDate, futureDate as NSDate)
        let sortDescriptors = [NSSortDescriptor(key: "testdate", ascending: true)]
        
        return getTests(matching: predicate, sortedBy: sortDescriptors)
    }
    
    func addCompletedTest(from test: Tests, score: Int64) {
        logger.debug("Adding completed test record for: \(test.testname ?? "unknown") with score: \(score)")
        
        dataController.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            let completedTest = CompletedTests(context: context)
            completedTest.id = UUID()
            completedTest.testname = test.testname
            completedTest.testtopic = test.testtopic
            completedTest.score = score
            completedTest.dateoftest = Date()
            
            self.logger.debug("Completed test record created successfully")
        }
    }
}

enum TestUpdate {
    case name(String)
    case topic(String)
    case date(Date)
    case score(Int64)
    case dateSubmitted(Date)
    case changedTopic(Bool)
    case questions(String, String?)
}
