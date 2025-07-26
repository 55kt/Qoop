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
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: ExpenseViewModel
    
    @State private var title: String = ""
    @State private var amount: Double?
    @State private var quantity: Int?
    @State private var location: String = ""
    @State private var emoji: String = "💸"
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    
                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                    
                    TextField("Quantity", value: $quantity, format: .number)
                        .keyboardType(.numberPad)
                    
                    TextField("Location (Optional)", text: $location)
                }// Fields section
                .padding(10)
                
                EmojiPickerRow(title: "Select emoji", selection: $emoji)
                    .frame(maxWidth: .infinity)
            }// Form
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard viewModel.isExpenseFormValid(title: title, amount: amount, quantity: quantity) else {
                            viewModel.handle(error: ExpenseError.invalidInput)
                            return
                        }
                        do {
                            try viewModel.addExpense(
                                title: title,
                                amount: amount ?? 0,
                                quantity: quantity,
                                emoji: emoji,
                                location: location,
                                budget: budget,
                                context: viewContext
                            )
                            dismiss()
                        } catch {
                            viewModel.handle(error: error)
                        }
                    }
                    .disabled(!viewModel.isExpenseFormValid(title: title, amount: amount ?? 0, quantity: quantity))
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }// toolbar
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }// alert
        }// NavigationStack
    }// body
}// View

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleBudget = Budget(context: context)
    sampleBudget.title = "Groceries"
    sampleBudget.limit = 500
    
    return NavigationStack {
        AddExpenseScreen(budget: sampleBudget, viewModel: ExpenseViewModel())
            .environment(\.managedObjectContext, context)
    }
}
