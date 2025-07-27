//
//  Persistence.swift
//  Qoop
//
//  Created by Vlad on 12/7/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let groceries = Budget(context: viewContext)
        groceries.title = "Groceries"
        groceries.limit = 200
        groceries.emoji = "🛒"
        groceries.dateCreated = Date()
        
        let entertainment = Budget(context: viewContext)
        entertainment.title = "Entertainment"
        entertainment.limit = 100
        entertainment.emoji = "🎬"
        entertainment.isActive = true
        entertainment.dateCreated = Date()
        
        let milk = Expense(context: viewContext)
        milk.title = "Milk"
        milk.amount = 3.49
        milk.quantity = 5000
        milk.location = "Milk Shop"
        milk.emoji = "🥛"
        milk.dateCreated = Date()
        
        let cookies = Expense(context: viewContext)
        cookies.title = "Cookies"
        cookies.quantity = 3
        cookies.amount = 2.99
        cookies.location = "Cookies Shop"
        cookies.emoji = "🍪"
        cookies.dateCreated = Date()
        
        entertainment.addToExpenses(cookies)
        entertainment.addToExpenses(milk)
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Qoop")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.transactionAuthor = "app"
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
