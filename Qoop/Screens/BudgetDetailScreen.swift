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
    @State private var quantity: Int?
    @State private var location: String = ""
    @State private var emoji: String = "💸"
    
    @State private var errorMessage: String = ""
    
    @State private var expenseToEdit: Expense?
    
    @FetchRequest(sortDescriptors: []) private var expenses: FetchedResults<Expense>
    
    init(budget: Budget) {
        
        self.budget = budget
        _expenses = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "budget == %@", budget))
    }
    
    private var isFormValid: Bool {
        !title.isEmptyOrWhitespace && amount != nil && Double(amount!) > 0 && quantity != nil && Int(quantity!) > 0
    }
    
    
    
    private func addExpense() {
        let expense = Expense(context: viewContext)
        expense.title = title
        expense.amount = amount ?? 0
        expense.quantity = Int16(quantity ?? 0)
        expense.location = location
        expense.emoji = emoji
        expense.dateCreated = Date()
        
        budget.addToExpenses(expense)
        
        do {
            try viewContext.save()
            title = ""
            amount = nil
            quantity = nil
            location = ""
            emoji = ""
            errorMessage = ""
        } catch {
            viewContext.rollback()
            print("❌ Failed to save expense: \(error.localizedDescription)")
        }
    }
    
    private func deleteExpense(_ indexSet: IndexSet) {
        indexSet.forEach { index in
            let expense = expenses[index]
            viewContext.delete(expense)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("❌ Failed to delete expense: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        Form {
            Text(budget.limit, format: .currency(code: Locale.currencyCode))
            
            Section(header: Text("New Expense")) {
                TextField("Title", text: $title)
                TextField("Amount", value: $amount, format: .number)
                    .keyboardType(.numberPad)
                TextField("Quantity", value: $quantity, format: .number)
                TextField("Location", text: $location)
                
                EmojiPickerRow(title: "Select emoji", selection: $emoji)
                
                Button {
                    if !Expense.exists(context: viewContext, title: title, budget: budget) {
                        addExpense()
                    } else {
                        print("❌ Expense with title \(title) already exists")
                        errorMessage = "❌ Expense with title \(title) already exists"
                    }
                } label: {
                    Text("Save")
                }
                .frame(maxWidth: .infinity)
                .disabled(!isFormValid)
                
                Text(errorMessage)
            }
            
            Section("Expenses") {
                HStack {
                    Text("Spent: \(budget.spent, format: .currency(code: Locale.currencyCode))")
                    
                    Spacer()
                    
                    Text("Remaining: \(budget.remaining, format: .currency(code: Locale.currencyCode))")
                        .foregroundStyle(budget.remaining < 0 ? .red : .green)
                }
                
                ForEach(expenses) { expense in
                    ExpenseCardView(expense: expense)
                        .onLongPressGesture {
                            expenseToEdit = expense
                        }
                }
                .onDelete(perform: deleteExpense)
            }
        }
        .navigationTitle(budget.title ?? "")
        .sheet(item: $expenseToEdit) { expenseToEdit in
            NavigationStack {
                EditExpenseScreen(expense: expenseToEdit)
            }
        }
    }
}

struct BudgetDetailScreenContainer: View {
    @FetchRequest(sortDescriptors: []) private var budgets: FetchedResults<Budget>
    
    var body: some View {
        BudgetDetailScreen(budget: budgets.first ?? Budget())
    }
}

#Preview {
    NavigationStack {
        BudgetDetailScreenContainer()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
