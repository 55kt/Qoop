//
//  EditExpenseScreen.swift
//  Qoop
//
//  Created by Vlad on 16/7/25.
//

import SwiftUI

struct EditExpenseScreen: View {
    
    // MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ExpenseViewModel()
    
    let expense: Expense
    
    @State private var title: String = ""
    @State private var amount: Double?
    @State private var quantity: Int?
    @State private var location: String = ""
    @State private var emoji: String = "💸"
    
    init(expense: Expense) {
        self.expense = expense
        _title = State(initialValue: expense.title ?? "")
        _amount = State(initialValue: expense.amount)
        _quantity = State(initialValue: Int(expense.quantity))
        _location = State(initialValue: expense.location ?? "")
        _emoji = State(initialValue: expense.emoji ?? "💸")
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $title)
                TextField("Amount", value: $amount, format: .number)
                    .keyboardType(.numberPad)
                TextField("Quantity", value: $quantity, format: .number)
                TextField("Location", text: $location)
            }
            .padding(10)
            
            EmojiPickerRow(title: "Select emoji", selection: $emoji)
                .frame(maxWidth: .infinity)
        }// Form
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    do {
                        try viewModel.editExpense(
                            expense,
                            newTitle: title,
                            newAmount: amount ?? 0,
                            newQuantity: quantity,
                            newLocation: location,
                            newEmoji: emoji,
                            context: viewContext
                        )
                        dismiss()
                    } catch {
                        viewModel.handle(error: error)
                    }
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }// toolbar
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .navigationTitle("Edit Expense")
        .navigationBarTitleDisplayMode(.inline)
    }// body
}// View

// MARK: - Preview
#Preview {
    let preview = PersistenceController.preview
    let context = preview.container.viewContext
    let expense = Expense(context: context)
    expense.title = "Test Expense"
    expense.amount = 100.0
    expense.quantity = 1
    expense.emoji = "💸"
    return NavigationStack {
        EditExpenseScreen(expense: expense)
            .environment(\.managedObjectContext, context)
    }
}
