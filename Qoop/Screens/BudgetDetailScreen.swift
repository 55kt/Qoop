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
    @State private var editBudgetIsPresented: Bool = false
    @State private var expenseToEdit: Expense?
    @State private var addExpensePresented: Bool = false
    
    @StateObject private var budgetViewModel = BudgetViewModel()
    @StateObject private var expenseViewModel = ExpenseViewModel()
    
    
    
    // MARK: - Initializer
    init(budget: Budget) {
        self.budget = budget
        _expenses = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "budget == %@", budget))
    }
    
    var body: some View {
        // MARK: - Budget Detail Header
        Form {
            
            Section("Budget Details") {
                Toggle(isOn: Binding(
                    get: { budget.isActive },
                    set: { newValue in
                        budgetViewModel.setActiveBudget(budget, isActive: newValue, context: viewContext)
                    }
                )) {
                    Label("Active budget", systemImage: "checkmark.circle.fill")
                        .foregroundColor(budget.isActive ? .green : .secondary)
                }// Activate budget toggle
                
                HStack {
                    Text("💸 Budget")
                    Spacer()
                    Text(budget.limit, format: .currency(code: Locale.currencyCode))
                    
                }// Total Limit
                let details = expenseViewModel.calculateBudgetDetails(for: budget)

                HStack {
                    Text("📦 Remaining")
                    Spacer()
                    Text(details.remaining, format: .currency(code: Locale.currencyCode))
                        .foregroundColor(BudgetCardView.remainingStatusColor(limit: budget.limit, remaining: details.remaining))
                }// Remaining
                
                HStack {
                    Text("🧾 Spent")
                    Spacer()
                    Text(details.spent, format: .currency(code: Locale.currencyCode))
                        .foregroundColor(.red)
                }// Spent
                
                Button("Edit Budget") {
                    editBudgetIsPresented.toggle()
                }// Edit Button
            }// Budget Details Section
            
            
            // MARK: - Expenses List
            Section("Expenses") {
                
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
            }// Expenses List
        }// Form
        .navigationTitle("\(budget.title ?? "Budget") \(budget.emoji ?? "")")
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
        .sheet(isPresented: $editBudgetIsPresented) {
            EditBudgetScreen(budget: budget, isPresented: $editBudgetIsPresented)
        }
        .toolbar {
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    addExpensePresented.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            
        }// toolbar
    }// body
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
