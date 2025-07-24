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

    @State private var errorMessage: String = ""

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)

                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)

                    TextField("Quantity (Optional)", value: $quantity, format: .number)
                        .keyboardType(.numberPad)

                    TextField("Location (Optional)", text: $location)
                }
                .padding(10)

                EmojiPickerRow(title: "Select emoji", selection: $emoji)
                    .frame(maxWidth: .infinity)
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
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
                            errorMessage = error.localizedDescription
                        }
                    }
                    .disabled(!viewModel.addExpenseIsFormValid(title: title, amount: amount ?? 0))
                }
            }
            .alert("Error", isPresented: .constant(!errorMessage.isEmpty)) {
                Button("OK", role: .cancel) {
                    errorMessage = ""
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
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
