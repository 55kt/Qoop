//
//  BudgetManager.swift
//  Qoop
//
//  Created by Vlad on 13/7/25.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
final class BudgetViewModel: ObservableObject {
    
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false
    
    static func addBudget(title: String, limit: Double, emoji: String, context: NSManagedObjectContext) throws {
        guard !title.isEmptyOrWhitespace, limit > 0, !Budget.exists(context: context, title: title) else {
            throw NSError(domain: "Qoop", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid input or budget title already exists"])
        }
        
        let newBudget = Budget(context: context)
        newBudget.title = title
        newBudget.limit = limit
        newBudget.emoji = emoji
        newBudget.dateCreated = Date()
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    func deleteBudgets(offsets: IndexSet, budgets: FetchedResults<Budget>, context: NSManagedObjectContext) {
            offsets.forEach { index in
                let budget = budgets[index]
                context.delete(budget)
            }

            do {
                try context.save()
            } catch {
                errorMessage = "❌ Failed to delete budget: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    
    static func updateBudget(_ budget: Budget, newTitle: String, newLimit: Double, newEmoji: String, context: NSManagedObjectContext) throws {
        guard !newTitle.isEmptyOrWhitespace, newLimit > 0, !Budget.exists(context: context, title: newTitle) || budget.title == newTitle else {
            throw NSError(domain: "Qoop", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid input or budget title already exists"])
        }
        
        budget.title = newTitle
        budget.limit = newLimit
        budget.emoji = newEmoji
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
