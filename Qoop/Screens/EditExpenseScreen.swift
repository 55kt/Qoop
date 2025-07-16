//
//  EditExpenseScreen.swift
//  Qoop
//
//  Created by Vlad on 16/7/25.
//

import SwiftUI

struct EditExpenseScreen: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let expense: Expense
    
    @State private var expenseTitle: String = ""
    @State private var expenseAmount: Double?
    @State private var expenseQuantity: Int?
    @State private var expenseLocation: String = ""
    @State private var expenseEmoji: String = "💸"
    
    private func updateExpense() {
        expense.title = expenseTitle
        expense.amount = expenseAmount ?? 0
        expense.quantity = Int16(expenseQuantity ?? 0)
        expense.location = expenseLocation
        expense.emoji = expenseEmoji
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Failed to save expense: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        Form {
            TextField("Title", text: $expenseTitle)
            TextField("Amount", value: $expenseAmount, format: .number)
                .keyboardType(.numberPad)
            TextField("Quantity", value: $expenseQuantity, format: .number)
            TextField("Location", text: $expenseLocation)
            
            EmojiPickerRow(title: "Select emoji", selection: $expenseEmoji)
        }
        .onAppear {
            expenseTitle = expense.title ?? ""
            expenseAmount = expense.amount
            expenseQuantity = Int(expense.quantity)
            expenseLocation = expense.location ?? ""
            expenseEmoji = expense.emoji ?? "💸"
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    updateExpense()
                }
            }
        }
        .navigationTitle(expense.title ?? "")
    }
}

struct EditExpenseContainerView: View {
    
    @FetchRequest(sortDescriptors: []) private var expenses: FetchedResults<Expense>
    
    var body: some View {
        NavigationStack {
            EditExpenseScreen(expense: expenses[0])
        }
    }
}

#Preview {
    EditExpenseContainerView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
