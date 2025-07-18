//
//  AddExpenseScreen.swift
//  Qoop
//
//  Created by Vlad on 17/7/25.
//

import SwiftUI

struct AddExpenseScreen: View {
    // MARK: - Properties
    let budget: Budget
    @Environment(\.managedObjectContext) private var viewContext
    @State private var title: String = ""
    @State private var amount: Double?
    @State private var quantity: Int?
    @State private var location: String = ""
    @State private var emoji: String = "💸"
    
    @State private var errorMessage: String = ""
    
    private var isFormValid: Bool {
        !title.isEmptyOrWhitespace && amount != nil && Double(amount!) > 0 && quantity != nil && Int(quantity!) > 0
    }
    
    // MARK: - Body
    var body: some View {
        Form {
            Section(header: Text("New Expense")) {
                TextField("Title", text: $title)
                TextField("Amount", value: $amount, format: .number)
                    .keyboardType(.numberPad)
                TextField("Quantity", value: $quantity, format: .number)
                TextField("Location", text: $location)
                
                EmojiPickerRow(title: "Select emoji", selection: $emoji)
                
                Button {
                    if !Expense.exists(context: viewContext, title: title, budget: budget) {
                        guard let unwrappedAmount = amount, let unwrappedQuantity = quantity else {
                            errorMessage = "❌ Amount or quantity is missing"
                            return
                        }
                        do {
                            try ExpenseManager.addExpense(title: title, amount: unwrappedAmount, quantity: unwrappedQuantity, emoji: emoji, location: location, budget: budget, context: viewContext)
                            title = ""
                            amount = nil
                            quantity = nil
                            location = ""
                            emoji = "💸"
                            errorMessage = ""
                        } catch {
                            print("❌ Failed to save expense: \(error.localizedDescription)")
                            errorMessage = "❌ Failed to save expense: \(error.localizedDescription)"
                        }
                    } else {
                        print("❌ Expense with title \(title) already exists")
                        errorMessage = "❌ Expense with title \(title) already exists"
                    }
                } label: {
                    Text("Save")
                }// Save button
                .frame(maxWidth: .infinity)
                .disabled(!isFormValid)
                
                Text(errorMessage)
            }// Section
        }// Form
    }// View
}// View

// MARK: - Preview
#Preview {
    NavigationStack {
        AddExpenseScreen(budget: Budget())
    }
}
