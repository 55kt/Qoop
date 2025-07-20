//
//  BudgetViewModel.swift
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
    
    func addBudget(title: String, limit: Double, emoji: String, context: NSManagedObjectContext) {
        guard !title.isEmptyOrWhitespace, limit > 0 else {
            errorMessage = "Title or limit is invalid"
            showErrorAlert = true
            return
        }
        
        let fetchRequest = Budget.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let existing = try context.fetch(fetchRequest)
            if !existing.isEmpty {
                errorMessage = "Budget with this title already exists"
                showErrorAlert = true
                return
            }
            
            let newBudget = Budget(context: context)
            newBudget.title = title
            newBudget.limit = limit
            newBudget.emoji = emoji
            newBudget.dateCreated = Date()
            
            try context.save()
        } catch {
            context.rollback()
            errorMessage = "Failed to save budget: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
    
    func deleteBudget(offsets: IndexSet, budgets: [Budget], context: NSManagedObjectContext) {
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
    
    func editBudget(_ budget: Budget, newTitle: String, newLimit: Double, newEmoji: String, context: NSManagedObjectContext) {
            guard !newTitle.isEmptyOrWhitespace, newLimit > 0 else {
                errorMessage = "Invalid input"
                showErrorAlert = true
                return
            }

            let fetchRequest = Budget.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", newTitle)

            do {
                let existing = try context.fetch(fetchRequest)
                let isDuplicate = existing.contains { $0 != budget }
                if isDuplicate {
                    errorMessage = "Budget with this title already exists"
                    showErrorAlert = true
                    return
                }

                budget.title = newTitle
                budget.limit = newLimit
                budget.emoji = newEmoji

                try context.save()
            } catch {
                context.rollback()
                errorMessage = "Failed to update budget: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
}
