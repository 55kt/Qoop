//
//  ExpenseViewModel.swift
//  Qoop
//
//  Created by Vlad on 14/7/25.
//

import Foundation
import CoreData

@MainActor
final class ExpenseViewModel: ObservableObject {
    
    func addExpense(title: String, amount: Double, quantity: Int?, emoji: String, location: String, budget: Budget, context: NSManagedObjectContext) throws {
        guard !title.isEmptyOrWhitespace, amount > 0, (quantity ?? 0) > 0, !location.isEmpty else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid input"])
        }
        
        let newExpense = Expense(context: context)
        newExpense.title = title
        newExpense.amount = amount
        newExpense.quantity = Int16(quantity ?? 0)
        newExpense.emoji = emoji
        newExpense.location = location
        newExpense.dateCreated = Date()
        
        let expensesSet = budget.mutableSetValue(forKey: "expenses")
        expensesSet.add(newExpense)
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    func addExpenseIsFormValid(title: String, amount: Double) -> Bool {
        return !title.isEmptyOrWhitespace && amount > 0
    }
    
    func deleteExpense(_ expense: Expense, context: NSManagedObjectContext) {
        context.delete(expense)
        if let budget = expense.budget {
            do {
                try context.save()
                context.refresh(budget, mergeChanges: true)
            } catch {
                print("Failed to delete expense: \(error.localizedDescription)")
            }
        }
    }
    
    func calculateBudgetDetails(for budget: Budget) -> (spent: Double, remaining: Double) {
        let spent = (budget.expenses as? Set<Expense> ?? []).reduce(0) { total, expense in
            total + (expense.amount * Double(expense.quantity))
        }
        let remaining = max(0, budget.limit - spent)
        return (spent, remaining)
    }
}
