//
//  Persistence.swift
//  Qoop
//
//  Created by Vlad on 12/7/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    static let emojiData = EmojiDataModel()
    
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let newBudget = Budget(context: viewContext)
        newBudget.title = "Test Budget"
        newBudget.limit = Double.random(in: 100...1000)
        newBudget.emoji = emojiData.emoji["money_with_wings"] ?? EmojiDataModel.defaultEmoji
        newBudget.dateCreated = Date()
        
        let groceries = Budget(context: viewContext)
        groceries.title = "Groceries"
        groceries.limit = 200
        groceries.emoji = emojiData.emoji["shopping"] ?? EmojiDataModel.defaultEmoji
        groceries.dateCreated = Date()
        
        let entertainment = Budget(context: viewContext)
        entertainment.title = "Entertainment"
        entertainment.limit = 100
        entertainment.emoji = emojiData.emoji["film"] ?? EmojiDataModel.defaultEmoji
        entertainment.dateCreated = Date()
        
        let travel = Budget(context: viewContext)
        travel.title = "Travel"
        travel.limit = 500
        travel.emoji = emojiData.emoji["airplane"] ?? EmojiDataModel.defaultEmoji
        travel.dateCreated = Date()
        
        let car = Budget(context: viewContext)
        car.title = "Car"
        car.limit = 1000
        car.emoji = emojiData.emoji["car"] ?? EmojiDataModel.defaultEmoji
        car.dateCreated = Date()
        
        let health = Budget(context: viewContext)
        health.title = "Health"
        health.limit = 500
        health.emoji = emojiData.emoji["heart"] ?? EmojiDataModel.defaultEmoji
        health.dateCreated = Date()
        
        let food = Budget(context: viewContext)
        food.title = "Food"
        food.limit = 100
        food.emoji = emojiData.emoji["fork_and_knife"] ?? EmojiDataModel.defaultEmoji
        food.dateCreated = Date()
        
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
