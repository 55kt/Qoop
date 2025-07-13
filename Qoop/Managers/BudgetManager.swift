//
//  BudgetManager.swift
//  Qoop
//
//  Created by Vlad on 13/7/25.
//

import Foundation
import CoreData

final class BudgetManager {
    static func addBudget(title: String, limit: Double, icon: String, context: NSManagedObjectContext) throws {
        guard !Budget.exists(context: context, title: title) else {
            throw NSError(domain: "Qoop", code: -1, userInfo: [NSLocalizedDescriptionKey: "Budget title already exists"])
        }
        
        let newBudget = Budget(context: context)
        newBudget.title = title
        newBudget.limit = limit
        newBudget.icon = icon
        newBudget.dateCreated = Date()
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    static func deleteBudget(_ budget: Budget, context: NSManagedObjectContext) throws {
        context.delete(budget)
        try context.save()
    }
    
    static func updateBudget(_ budget: Budget, newTitle: String, newLimit: Double, newIcon: String, context: NSManagedObjectContext) throws {
        guard !Budget.exists(context: context, title: newTitle) || budget.title == newTitle else {
            throw NSError(domain: "Qoop", code: -1, userInfo: [NSLocalizedDescriptionKey: "Budget title already exists"])
        }
        
        budget.title = newTitle
        budget.limit = newLimit
        budget.icon = newIcon
        try context.save()
    }
}
