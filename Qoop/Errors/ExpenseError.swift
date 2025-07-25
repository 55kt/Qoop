//
//  ExpenseError.swift
//  Qoop
//
//  Created by Vlad on 25/7/25.
//

import Foundation

enum ExpenseError: LocalizedError {
    case invalidInput
    case failedToSave
    case failedToEdit
    case failedToDelete
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Invalid input. Please check the form."
        case .failedToSave:
            return "Failed to save expense."
        case .failedToEdit:
            return "Failed to edit expense."
        case .failedToDelete:
            return "Failed to delete expense."
        }
    }
}
