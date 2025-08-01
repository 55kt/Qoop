//
//  BudgetDetailScreen.swift
//  Qoop
//
//  Created by Vlad on 14/7/25.
//

import SwiftUI

struct BudgetDetailScreen: View {
    
    // MARK: - Properties
    @ObservedObject var budget: Budget
    
    @FetchRequest private var expenses: FetchedResults<Expense>
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var editBudgetIsPresented: Bool = false
    @State private var addExpensePresented: Bool = false
    @State private var expenseToEdit: Expense?
    
    @StateObject private var expenseViewModel = ExpenseViewModel()
    @StateObject private var budgetViewModel = BudgetViewModel()
    
    // MARK: - Initializer
    init(budget: Budget) {
        self.budget = budget
        _expenses = FetchRequest(
            sortDescriptors: [SortDescriptor(\.dateCreated, order: .reverse)],
            predicate: NSPredicate(format: "budget == %@", budget),
            animation: .default
        )
    }
    
    var body: some View {
        // MARK: - Budget Detail Header
        Form {
            Section("Budget Details") {
                Toggle(isOn: Binding(
                    get: { budget.isActive },
                    set: { newValue in
                        do {
                            try budgetViewModel.setActiveBudget(budget, isActive: newValue, context: viewContext)
                        } catch {
                            budgetViewModel.handle(error: error)
                        }
                    }
                )) {
                    Label("Active budget", systemImage: "checkmark.circle.fill")
                        .foregroundColor(budget.isActive ? .green : .secondary)
                }// Activate budget toggle
                
                let details = expenseViewModel.calculateBudgetDetails(for: budget)
                
                HStack {
                    Text("💸 Budget")
                    Spacer()
                    Text(budget.limit, format: .currency(code: Locale.currencyCode))
                }// Total Limit
                
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
                        }// edit swipe
                        .swipeActions(edge: .trailing) {
                            Button(("Delete"), role: .destructive) {
                                do {
                                    try expenseViewModel.deleteExpense(expense, context: viewContext)
                                } catch {
                                    expenseViewModel.handle(error: error)
                                }
                            }
                        }// delete swipe
                }// ForEach
            }// Expenses List
        }// Form
        .navigationTitle("\(budget.title ?? "Budget") \(budget.emoji ?? "")")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    addExpensePresented.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }// toolbar
        .sheet(item: $expenseToEdit) { expenseToEdit in
            NavigationStack {
                EditExpenseScreen(expense: expenseToEdit)
                    .presentationDetents([.fraction(0.60)])
            }
        }// Edit Expense sheet
        .sheet(isPresented: $addExpensePresented) {
            NavigationStack {
                AddExpenseScreen(budget: budget, viewModel: expenseViewModel)
                    .presentationDetents([.fraction(0.60)])
            }
        }// Add Expense sheet
        .sheet(isPresented: $editBudgetIsPresented) {
            EditBudgetScreen(budget: budget, isPresented: $editBudgetIsPresented)
                .presentationDetents([.fraction(0.60)])
        }// Edit Budget sheet
        .alert("Error", isPresented: $expenseViewModel.showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(expenseViewModel.errorMessage ?? "")
        }// alert
    }// body
}// View

// MARK: - Preview
#Preview {
    let preview = PersistenceController.preview
    let context = preview.container.viewContext
    BudgetDetailScreen(budget: Budget(context: context))
        .environment(\.managedObjectContext, context)
}
