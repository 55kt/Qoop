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
    
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
        
    func handle(error: Error) {
        errorMessage = error.localizedDescription
        showErrorAlert = true
    }
    
    func addExpense(title: String, amount: Double, quantity: Int?, emoji: String, location: String?, budget: Budget, context: NSManagedObjectContext) throws {
        guard !title.isEmptyOrWhitespace, amount > 0, (quantity ?? 0) > 0 else {
            throw ExpenseError.invalidInput
        }
        
        let newExpense = Expense(context: context)
        newExpense.title = title
        newExpense.amount = amount
        newExpense.quantity = Int16(quantity ?? 0)
        newExpense.emoji = emoji
        newExpense.location = location ?? ""
        newExpense.dateCreated = Date()
        
        let expensesSet = budget.mutableSetValue(forKey: "expenses")
        expensesSet.add(newExpense)
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw ExpenseError.failedToSave
        }
    }
    
    func isExpenseFormValid(title: String, amount: Double?, quantity: Int?) -> Bool {
        guard let amount = amount, amount > 0 else { return false }
        guard let quantity = quantity, quantity > 0 else { return false }
        return !title.isEmptyOrWhitespace
    }
    
    func editExpense(
        _ expense: Expense,
        newTitle: String,
        newAmount: Double,
        newQuantity: Int?,
        newLocation: String?,
        newEmoji: String,
        context: NSManagedObjectContext
    ) throws {
        guard !newTitle.isEmptyOrWhitespace, newAmount > 0, (newQuantity ?? 0) > 0 else {
            throw ExpenseError.invalidInput
        }
        
        expense.title = newTitle
        expense.amount = newAmount
        expense.quantity = Int16(newQuantity ?? 0)
        expense.location = newLocation ?? ""
        expense.emoji = newEmoji
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw ExpenseError.failedToEdit
        }
    }
    
    func deleteExpense(_ expense: Expense, context: NSManagedObjectContext) throws {
        context.delete(expense)
        if let budget = expense.budget {
            do {
                try context.save()
                context.refresh(budget, mergeChanges: true)
            } catch {
                throw ExpenseError.failedToDelete
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
