//
//  ExpenseManager.swift
//  Qoop
//
//  Created by Vlad on 14/7/25.
//

import Foundation
import CoreData

final class ExpenseManager {
    
    static func addExpense(title: String, amount: Double, emoji: String, budget: Budget, context: NSManagedObjectContext) throws {
        
        guard !title.isEmptyOrWhitespace, amount > 0 else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid input"])
        }
        
        let newExpense = Expense(context: context)
        newExpense.title = title
        newExpense.amount = amount
        newExpense.emoji = emoji
        newExpense.dateCreated = Date()
        
        budget.addToExpenses(newExpense)
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
