//
//  ExpenseManager.swift
//  Qoop
//
//  Created by Vlad on 14/7/25.
//

import Foundation
import CoreData

final class ExpenseManager {
    
    static func addExpense(title: String, amount: Double, quantity: Int?, emoji: String, location: String, budget: Budget, context: NSManagedObjectContext) throws {
        
        guard !title.isEmptyOrWhitespace, amount > 0 else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid input"])
        }
        
        let newExpense = Expense(context: context)
        newExpense.title = title
        newExpense.amount = amount
        newExpense.quantity = Int16(quantity ?? 0)
        newExpense.emoji = emoji
        newExpense.location = location
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
