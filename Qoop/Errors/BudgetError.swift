//
//  BudgetError.swift
//  Qoop
//
//  Created by Vlad on 26/7/25.
//

import Foundation

import Foundation

enum BudgetError: LocalizedError {
    case invalidInput
    case duplicateTitle
    case failedToSave
    case failedToEdit
    case failedToDelete
    case failedToReorder
    case failedToActivate

    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Invalid input. Please check the form."
        case .duplicateTitle:
            return "A budget with this title already exists."
        case .failedToSave:
            return "Failed to save the budget."
        case .failedToEdit:
            return "Failed to update the budget."
        case .failedToDelete:
            return "Failed to delete the budget."
        case .failedToReorder:
            return "Failed to reorder budgets."
        case .failedToActivate:
            return "Failed to update active status."
        }
    }
}
