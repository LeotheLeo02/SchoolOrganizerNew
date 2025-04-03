//
//
//

import Foundation
import CoreData

class SharedDataController: ObservableObject {
    static let shared = SharedDataController()
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    private init() {
        container = NSPersistentContainer(name: "SchoolModel")
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Failed to load Core Data stack: \(error.localizedDescription)")
            }
        }
    }
    
    
    func saveViewContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving view context: \(error.localizedDescription)")
            }
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { context in
            block(context)
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Error saving background context: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func batchDelete<T: NSManagedObject>(entityType: T.Type, predicate: NSPredicate) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: entityType))
        fetchRequest.predicate = predicate
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        performBackgroundTask { context in
            do {
                let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    let changes = [NSDeletedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
                }
            } catch {
                print("Error performing batch delete: \(error.localizedDescription)")
            }
        }
    }
    
    func batchUpdate<T: NSManagedObject>(entityType: T.Type, predicate: NSPredicate, propertiesToUpdate: [String: Any]) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: entityType))
        fetchRequest.predicate = predicate
        
        let batchUpdateRequest = NSBatchUpdateRequest(fetchRequest: fetchRequest)
        batchUpdateRequest.propertiesToUpdate = propertiesToUpdate
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        
        performBackgroundTask { context in
            do {
                let result = try context.execute(batchUpdateRequest) as? NSBatchUpdateResult
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    let changes = [NSUpdatedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
                }
            } catch {
                print("Error performing batch update: \(error.localizedDescription)")
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
        
        return request
    }
}
