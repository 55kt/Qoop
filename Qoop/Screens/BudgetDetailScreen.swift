//
//  BudgetDetailScreen.swift
//  Qoop
//
//  Created by Vlad on 14/7/25.
//

import SwiftUI

struct BudgetDetailScreen: View {
    
    // MARK: - Properties
    let budget: Budget
    @FetchRequest(sortDescriptors: []) private var expenses: FetchedResults<Expense>
    @Environment(\.managedObjectContext) private var viewContext
    @State private var expenseToEdit: Expense?
    @State private var addExpensePresented: Bool = false
    
    // MARK: - Initializer
    init(budget: Budget) {
        self.budget = budget
        _expenses = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "budget == %@", budget))
    }
    
    var body: some View {
        // MARK: - Budget Detail Header
        Form {
            HStack {
                Text(budget.emoji ?? EmojiDataModel.defaultEmoji)
                
                Spacer()
                Text("Limit:")
                Text(budget.limit, format: .currency(code: Locale.currencyCode))
                
                Spacer()
            }// HStack
            
            Button("Add expense") {
                addExpensePresented.toggle()
            }
            .frame(maxWidth: .infinity)
            
            // MARK: - Expenses List
            Section("Expenses") {
                
                // MARK: - Header
                HStack {
                    Text("Spent: \(budget.spent, format: .currency(code: Locale.currencyCode))")
                    
                    Spacer()
                    
                    Text("Remaining: \(budget.remaining, format: .currency(code: Locale.currencyCode))")
                        .foregroundStyle(budget.remaining < 0 ? .red : .green)
                }// HStack
                
                // MARK: - List
                ForEach(expenses) { expense in
                    ExpenseCardView(expense: expense)
                        .swipeActions(edge: .leading) {
                            Button("Edit") {
                                expenseToEdit = expense
                            }
                            .tint(.blue)
                        }
                }// ForEach
                .onDelete(perform: deleteExpense)
            }// Expenses List
        }
        .navigationTitle(budget.title ?? "")
        .sheet(item: $expenseToEdit) { expenseToEdit in
            NavigationStack {
                EditExpenseScreen(expense: expenseToEdit)
            }// NavigationStack
        }// sheet
        .sheet(isPresented: $addExpensePresented) {
            NavigationStack {
                AddExpenseScreen(budget: budget)
            }
        }
    }// body
    
    // MARK: - Methods & Functions
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
    }// delete expense function
}// View

// MARK: - Preview Container
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
