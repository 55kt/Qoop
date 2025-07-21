//
//  BudgetListScreen.swift
//  Qoop
//
//  Created by Vlad on 12/7/25.
//

import SwiftUI

struct BudgetListScreen: View {
    // MARK: - Properties
    @FetchRequest(sortDescriptors: [SortDescriptor(\.orderIndex, order: .forward)], animation: .default)
    private var budgets: FetchedResults<Budget>
    @StateObject private var viewModel = BudgetViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isPresented: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            
            let hasActiveBudgets = budgets.contains(where: { $0.isActive })
            let hasOtherBudgets = budgets.contains(where: { !$0.isActive })
            
            List {
                // MARK: - Active Budgets
                if hasActiveBudgets {
                    Section {
                        ForEach(budgets.filter { $0.isActive }) { budget in
                            NavigationLink {
                                BudgetDetailScreen(budget: budget)
                            } label: {
                                BudgetCardView(budget: budget)
                            }
                        }// ForEach
                        .onDelete { indexSet in
                            viewModel.deleteBudget(offsets: indexSet, budgets: budgets.filter { $0.isActive }, context: viewContext)
                        }// onDelete
                        .onMove { indices, newOffset in
                            viewModel.moveBudgets(budgets: budgets.filter { $0.isActive }, fromOffsets: indices, toOffset: newOffset, context: viewContext)
                        }// onMove
                    } header: {
                        HStack(spacing: 2) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.system(size: 18))
                            Text("Active budgets")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }// HStack
                    }// Section
                }// if budget is active

                // MARK: - Other Budgets
                if hasOtherBudgets {
                    Section {
                        ForEach(budgets.filter { !$0.isActive }) { budget in
                            NavigationLink {
                                BudgetDetailScreen(budget: budget)
                            } label: {
                                BudgetCardView(budget: budget)
                            }
                        }// ForEach
                        .onDelete { indexSet in
                            viewModel.deleteBudget(offsets: indexSet, budgets: budgets.filter { !$0.isActive }, context: viewContext)
                        }// onDelete
                        .onMove { indices, newOffset in
                            viewModel.moveBudgets(budgets: budgets.filter { !$0.isActive }, fromOffsets: indices, toOffset: newOffset, context: viewContext)
                        }// onMove
                    } header: {
                        if budgets.contains(where: { $0.isActive }) {
                                Text("Other budgets")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }// hide other budgets header
                    }// Section
                }// if budget is not active
            }// List
            .listStyle(.plain)
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }// Edit button
            }// toolbar
            .sheet(isPresented: $isPresented) {
                AddBudgetScreen(viewModel: viewModel, isPresented: $isPresented)
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .presentationDetents([.fraction(0.50)])
            }// sheet
            .onAppear {
                print("Budgets: \(budgets.map { $0.title ?? "No title" })")
            }// onAppear DELETE THIS LATER IN PRODUCTION
            
            
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
