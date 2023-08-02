//
//  CoreDataStore.swift
//  RecipesApp
//
//  Created by Hyusein Hyusein on 25.10.21.
//

import CoreData

enum StorageType {
    case persistent
    case inMemory
}

protocol CoreDataStoreProtocol {
    var persistentContainer: NSPersistentContainer { get }
    func newDerivedContext() -> NSManagedObjectContext

}
class CoreDataStore: CoreDataStoreProtocol {
    let persistentContainer: NSPersistentContainer
    
    init(_ storageType: StorageType = .persistent) {
        self.persistentContainer = NSPersistentContainer(name: "RecipesModel")
        
        if storageType == .inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            self.persistentContainer.persistentStoreDescriptions = [description]
        }
        
        self.persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func newDerivedContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
        return context
    }
}

// used for testing for some reason
public extension NSManagedObject {
    
    convenience init(context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }
    
    @nonobjc class func fetchRequest<T: NSManagedObject>() -> NSFetchRequest<T> {
         return NSFetchRequest<T>(entityName: String(describing: T.self))
     }
}
