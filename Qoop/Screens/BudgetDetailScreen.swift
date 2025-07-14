//
//  BudgetDetailScreen.swift
//  Qoop
//
//  Created by Vlad on 14/7/25.
//

import SwiftUI

struct BudgetDetailScreen: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    let budget: Budget
    
    @State private var title: String = ""
    @State private var amount: Double?
    @State private var emoji: String = "💸"
    
    private var isFormValid: Bool {
        !title.isEmptyOrWhitespace && amount != nil && Double(amount!) > 0
    }
    
    var body: some View {
        Form {
            Section(header: Text("New Expense")) {
                TextField("Title", text: $title)
                TextField("Amount", value: $amount, format: .number)
                    .keyboardType(.numberPad)
                
                EmojiPickerRow(title: "Select emoji", selection: $emoji)
                
                Button {
                    guard let unwrappedAmount = amount, unwrappedAmount > 0 else { return }
                    do {
                        try ExpenseManager.addExpense(title: title, amount: unwrappedAmount, emoji: emoji, budget: budget, context: viewContext)
                        title = ""
                        amount = 0
                        emoji = "💸"
                    } catch {
                        print("❌ Failed to save expense: \(error.localizedDescription)")
                    }
                } label: {
                    Text("Save")
                }
                .frame(maxWidth: .infinity)
                .disabled(!isFormValid)
            }
            
        }
        .navigationTitle(budget.title ?? "")
    }
}

struct BudgetDetailScreenContainer: View {
    @FetchRequest(sortDescriptors: []) private var budgets: FetchedResults<Budget>
    
    var body: some View {
        BudgetDetailScreen(budget: budgets[3])
    }
}

#Preview {
    NavigationStack {
        BudgetDetailScreenContainer()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
