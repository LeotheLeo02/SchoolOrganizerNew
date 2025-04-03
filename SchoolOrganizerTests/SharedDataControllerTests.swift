//
//
//

import XCTest
import CoreData
@testable import SchoolOrganizer

class SharedDataControllerTests: XCTestCase {
    
    var sut: SharedDataController!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = SharedDataController.shared
        
        #if DEBUG
        sut.resetCoreDataStack()
        #endif
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    
    func testSharedInstanceExists() {
        XCTAssertNotNil(SharedDataController.shared)
    }
    
    func testViewContextExists() {
        XCTAssertNotNil(sut.viewContext)
    }
    
    
    func testAddAndFetchAssignment() {
        let context = sut.viewContext
        let assignment = Assignment(context: context)
        assignment.id = UUID()
        assignment.name = "Test Assignment"
        assignment.topic = "Math"
        assignment.duedate = Date()
        
        sut.saveViewContext()
        
        let fetchRequest = sut.optimizedFetchRequest(
            for: Assignment.self,
            predicate: NSPredicate(format: "name == %@", "Test Assignment")
        )
        
        do {
            let results = try context.fetch(fetchRequest)
            XCTAssertEqual(results.count, 1, "Should fetch exactly one assignment")
            XCTAssertEqual(results.first?.name, "Test Assignment")
            XCTAssertEqual(results.first?.topic, "Math")
        } catch {
            XCTFail("Failed to fetch assignment: \(error.localizedDescription)")
        }
    }
    
    func testBatchUpdate() {
        let context = sut.viewContext
        
        for i in 1...5 {
            let assignment = Assignment(context: context)
            assignment.id = UUID()
            assignment.name = "Assignment \(i)"
            assignment.topic = "Science"
            assignment.duedate = Date()
        }
        
        sut.saveViewContext()
        
        let predicate = NSPredicate(format: "topic == %@", "Science")
        let propertiesToUpdate = ["topic": "Physics"]
        
        sut.batchUpdate(entityType: Assignment.self, predicate: predicate, propertiesToUpdate: propertiesToUpdate)
        
        let fetchRequest = sut.optimizedFetchRequest(
            for: Assignment.self,
            predicate: NSPredicate(format: "topic == %@", "Physics")
        )
        
        do {
            let results = try context.fetch(fetchRequest)
            XCTAssertEqual(results.count, 5, "All 5 assignments should have been updated")
        } catch {
            XCTFail("Failed to fetch updated assignments: \(error.localizedDescription)")
        }
    }
    
    func testBatchDelete() {
        let context = sut.viewContext
        
        for i in 1...3 {
            let assignment = Assignment(context: context)
            assignment.id = UUID()
            assignment.name = "Delete Test \(i)"
            assignment.topic = "ToDelete"
            assignment.duedate = Date()
        }
        
        sut.saveViewContext()
        
        let initialFetchRequest = sut.optimizedFetchRequest(
            for: Assignment.self,
            predicate: NSPredicate(format: "topic == %@", "ToDelete")
        )
        
        do {
            let initialResults = try context.fetch(initialFetchRequest)
            XCTAssertEqual(initialResults.count, 3, "Should have created 3 assignments")
            
            let predicate = NSPredicate(format: "topic == %@", "ToDelete")
            sut.batchDelete(entityType: Assignment.self, predicate: predicate)
            
            let expectation = XCTestExpectation(description: "Wait for batch delete")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1.0)
            
            let finalResults = try context.fetch(initialFetchRequest)
            XCTAssertEqual(finalResults.count, 0, "All assignments should have been deleted")
        } catch {
            XCTFail("Failed in batch delete test: \(error.localizedDescription)")
        }
    }
    
    func testBackgroundTaskExecution() {
        let expectation = XCTestExpectation(description: "Background task execution")
        
        sut.performBackgroundTask { context in
            let test = Tests(context: context)
            test.id = UUID()
            test.testname = "Background Test"
            test.testtopic = "Background Topic"
            test.testdate = Date()
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        let fetchRequest = sut.optimizedFetchRequest(
            for: Tests.self,
            predicate: NSPredicate(format: "testname == %@", "Background Test")
        )
        
        do {
            let results = try sut.viewContext.fetch(fetchRequest)
            XCTAssertEqual(results.count, 1, "Should fetch exactly one test created in background")
            XCTAssertEqual(results.first?.testname, "Background Test")
        } catch {
            XCTFail("Failed to fetch test created in background: \(error.localizedDescription)")
        }
    }
    
    func testOptimizedFetchRequest() {
        let fetchRequest = sut.optimizedFetchRequest(
            for: Assignment.self,
            predicate: NSPredicate(format: "topic == %@", "Math"),
            sortDescriptors: [NSSortDescriptor(key: "duedate", ascending: true)],
            relationshipKeysToFetch: ["topic"],
            batchSize: 30
        )
        
        XCTAssertEqual(fetchRequest.entityName, "Assignment")
        XCTAssertNotNil(fetchRequest.predicate)
        XCTAssertEqual(fetchRequest.sortDescriptors?.count, 1)
        XCTAssertEqual(fetchRequest.fetchBatchSize, 30)
        XCTAssertEqual(fetchRequest.relationshipKeyPathsForPrefetching?.count, 1)
    }
}
