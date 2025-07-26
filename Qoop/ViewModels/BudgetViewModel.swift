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
    
    func handle(error: Error) {
        errorMessage = error.localizedDescription
        showErrorAlert = true
    }
    
    func addBudget(title: String, limit: Double, emoji: String, context: NSManagedObjectContext) throws {
        guard !title.isEmptyOrWhitespace, limit > 0 else {
            throw BudgetError.invalidInput
        }
        
        let fetchRequest = Budget.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        let existing = try context.fetch(fetchRequest)
        if !existing.isEmpty {
            throw BudgetError.duplicateTitle
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
            throw BudgetError.failedToSave
        }
    }
    
    func isBudgetFormValid(title: String, limit: Double?, existingBudgets: [Budget], currentBudget: Budget? = nil) -> Bool {
        guard let limit = limit, limit > 0, !title.isEmptyOrWhitespace else {
            return false
        }
        
        let normalizedTitle = title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let hasDuplicate = existingBudgets.contains {
            $0 != currentBudget && ($0.title?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == normalizedTitle)
        }
        
        return !hasDuplicate
    }
    
    func editBudget(_ budget: Budget, newTitle: String, newLimit: Double, newEmoji: String, context: NSManagedObjectContext) throws {
        guard !newTitle.isEmptyOrWhitespace, newLimit > 0 else {
            throw BudgetError.invalidInput
        }
        
        let fetchRequest = Budget.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", newTitle)
        
        let existing = try context.fetch(fetchRequest)
        let isDuplicate = existing.contains { $0 != budget }
        if isDuplicate {
            throw BudgetError.duplicateTitle
        }
        
        budget.title = newTitle
        budget.limit = newLimit
        budget.emoji = newEmoji
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw BudgetError.failedToEdit
        }
    }
    
    func deleteBudget(offsets: IndexSet, budgets: [Budget], context: NSManagedObjectContext) throws {
        offsets.forEach { index in
            context.delete(budgets[index])
        }
        
        do {
            try context.save()
        } catch {
            throw BudgetError.failedToDelete
        }
    }
    
    
    
    func moveBudgets(budgets: [Budget], fromOffsets: IndexSet, toOffset: Int, context: NSManagedObjectContext) throws {
        var reordered = budgets
        reordered.move(fromOffsets: fromOffsets, toOffset: toOffset)
        
        for (index, budget) in reordered.enumerated() {
            budget.orderIndex = Int64(index)
        }
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw BudgetError.failedToReorder
        }
    }
    
    func setActiveBudget(_ budget: Budget, isActive: Bool, context: NSManagedObjectContext) throws {
        budget.isActive = isActive
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw BudgetError.failedToActivate
        }
    }
    
    func searchBudgets(_ searchText: String, in budgets: [Budget]) -> [Budget] {
            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return budgets }

            let lowercasedQuery = trimmed.lowercased()
            return budgets.filter {
                ($0.title?.lowercased().contains(lowercasedQuery) ?? false) ||
                ($0.emoji?.lowercased().contains(lowercasedQuery) ?? false)
            }
        }
}
