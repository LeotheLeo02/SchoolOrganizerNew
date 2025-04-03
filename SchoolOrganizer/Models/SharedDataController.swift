//
//
//

import Foundation
import CoreData
import os.log

class SharedDataController: ObservableObject {
    
    static let shared = SharedDataController()
    
    private let logger = Logger(subsystem: "com.schoolorganizer", category: "DataController")
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    
    private init() {
        container = NSPersistentContainer(name: "SchoolModel")
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        container.loadPersistentStores { [weak self] description, error in
            if let error = error {
                self?.logger.error("Failed to load Core Data stack: \(error.localizedDescription)")
            } else {
                self?.logger.info("Core Data stack loaded successfully")
            }
        }
    }
    
    
    func saveViewContext() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.saveViewContext()
            }
            return
        }
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                logger.debug("View context saved successfully")
            } catch {
                logger.error("Error saving view context: \(error.localizedDescription)")
            }
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            block(context)
            
            if context.hasChanges {
                do {
                    try context.save()
                    self.logger.debug("Background context saved successfully")
                } catch {
                    self.logger.error("Error saving background context: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func performBackgroundTaskAndWait(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = container.newBackgroundContext()
        context.performAndWait { [weak self] in
            guard let self = self else { return }
            
            block(context)
            
            if context.hasChanges {
                do {
                    try context.save()
                    self.logger.debug("Background context saved successfully")
                } catch {
                    self.logger.error("Error saving background context: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func batchDelete<T: NSManagedObject>(entityType: T.Type, predicate: NSPredicate) {
        let entityName = String(describing: entityType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        logger.debug("Performing batch delete for \(entityName) with predicate: \(predicate)")
        
        performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            do {
                let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    DispatchQueue.main.async {
                        let changes = [NSDeletedObjectsKey: objectIDs]
                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
                        self.logger.debug("Batch delete completed: \(objectIDs.count) objects deleted")
                    }
                }
            } catch {
                self.logger.error("Error performing batch delete: \(error.localizedDescription)")
            }
        }
    }
    
    func batchUpdate<T: NSManagedObject>(entityType: T.Type, predicate: NSPredicate, propertiesToUpdate: [String: Any]) {
        let entityName = String(describing: entityType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        
        let batchUpdateRequest = NSBatchUpdateRequest(fetchRequest: fetchRequest)
        batchUpdateRequest.propertiesToUpdate = propertiesToUpdate
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        
        logger.debug("Performing batch update for \(entityName) with predicate: \(predicate)")
        
        performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            do {
                let result = try context.execute(batchUpdateRequest) as? NSBatchUpdateResult
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    DispatchQueue.main.async {
                        let changes = [NSUpdatedObjectsKey: objectIDs]
                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
                        self.logger.debug("Batch update completed: \(objectIDs.count) objects updated")
                    }
                }
            } catch {
                self.logger.error("Error performing batch update: \(error.localizedDescription)")
            }
        }
    }
    
    
    func optimizedFetchRequest<T: NSManagedObject>(
        for entityType: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        relationshipKeysToFetch: [String]? = nil,
        batchSize: Int = 20
    ) -> NSFetchRequest<T> {
        let entityName = String(describing: entityType)
        let request = NSFetchRequest<T>(entityName: entityName)
        
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchBatchSize = batchSize
        
        if let relationshipKeys = relationshipKeysToFetch, !relationshipKeys.isEmpty {
            request.relationshipKeyPathsForPrefetching = relationshipKeys
        }
        
        logger.debug("Created optimized fetch request for \(entityName)")
        return request
    }
    
    
    #if DEBUG
    func resetCoreDataStack() {
        logger.debug("Resetting Core Data stack for testing")
        
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            logger.error("Failed to get persistent store URL")
            return
        }
        
        do {
            try container.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
            try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            logger.debug("Core Data stack reset successfully")
        } catch {
            logger.error("Failed to reset Core Data stack: \(error.localizedDescription)")
        }
    }
    #endif
}
