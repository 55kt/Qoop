//
//  BudgetListScreen.swift
//  Qoop
//
//  Created by Vlad on 12/7/25.
//

import SwiftUI

struct BudgetListScreen: View {
    // MARK: - Properties
    @FetchRequest(sortDescriptors: [SortDescriptor(\Budget.dateCreated, order: .reverse)], animation: .default)
    private var budgets: FetchedResults<Budget>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isPresented: Bool = false
    
    @StateObject private var viewModel = BudgetViewModel()
    
    
    @State private var budgetToEdit: Budget? = nil
    @State private var showDeleteAlert: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            
            let activeBudgets = budgets.filter { $0.isActive }
            let otherBudgets = budgets.filter { !$0.isActive }
            
            List {
                // MARK: - Active Budgets
                if !activeBudgets.isEmpty {
                    Section {
                        ForEach(activeBudgets) { budget in
                            NavigationLink {
                                BudgetDetailScreen(budget: budget)
                            } label: {
                                BudgetCardView(budget: budget)
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteBudget(offsets: indexSet, budgets: activeBudgets, context: viewContext)
                        }
                    } header: {
                        HStack(spacing: 2) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.system(size: 18))
                            Text("Active budgets")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                }

                // MARK: - Other Budgets
                if !otherBudgets.isEmpty {
                    Section {
                        ForEach(otherBudgets) { budget in
                            NavigationLink {
                                BudgetDetailScreen(budget: budget)
                            } label: {
                                BudgetCardView(budget: budget)
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteBudget(offsets: indexSet, budgets: otherBudgets, context: viewContext)
                        }
                    } header: {
                        Text("Other budgets")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            }// List
            .listStyle(.plain)
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .bold()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Edit") {
                        
                    }
                    .bold()
                }
            }// toolbar
            .sheet(isPresented: $isPresented) {
                AddBudgetScreen(viewModel: viewModel, isPresented: $isPresented)
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .presentationDetents([.fraction(0.50)])
            }// sheet
            .onAppear {
                print("Budgets: \(budgets.map { $0.title ?? "No title" })")
            }// onAppear
            
            
        }// NavigationStack
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }// Body
}// View

// MARK: - Preview
#Preview {
    let preview = PersistenceController.preview
    let context = preview.container.viewContext
    return BudgetListScreen()
        .environment(\.managedObjectContext, context)
}
