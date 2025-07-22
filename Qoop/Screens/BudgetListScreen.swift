//
//  BudgetListScreen.swift
//  Qoop
//
//  Created by Vlad on 12/7/25.
//

import SwiftUI

import SwiftUI

struct BudgetListScreen: View {
    // MARK: - Properties
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.orderIndex, order: .forward)],
        predicate: nil,
        animation: .default
    ) private var budgets: FetchedResults<Budget>
    
    @StateObject private var viewModel = BudgetViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isPresented: Bool = false
    @State private var searchText: String = ""
    
    private var dynamicPredicate: NSPredicate? {
        searchText.isEmpty ? nil : NSPredicate(format: "title CONTAINS[cd] %@", searchText)
    }
    
    private var filteredBudgets: [Budget] {
        dynamicPredicate.map { predicate in
            budgets.filter { predicate.evaluate(with: $0) }
        } ?? Array(budgets)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Active Budgets
                ActiveBudgetsSectionView(
                    budgets: filteredBudgets.filter { $0.isActive },
                    onDelete: { indexSet in
                        let active = filteredBudgets.filter { $0.isActive }
                        viewModel.deleteBudget(offsets: indexSet, budgets: active, context: viewContext)
                    },
                    onMove: { indices, newOffset in
                        let active = filteredBudgets.filter { $0.isActive }
                        viewModel.moveBudgets(budgets: active, fromOffsets: indices, toOffset: newOffset, context: viewContext)
                    }
                )// Active Budgets
                
                // MARK: - Other Budgets
                OtherBudgetsSectionView(
                    budgets: filteredBudgets.filter { !$0.isActive },
                    showHeader: filteredBudgets.contains { $0.isActive },
                    onDelete: { indexSet in
                        let other = filteredBudgets.filter { !$0.isActive }
                        viewModel.deleteBudget(offsets: indexSet, budgets: other, context: viewContext)
                    },
                    onMove: { indices, newOffset in
                        let other = filteredBudgets.filter { !$0.isActive }
                        viewModel.moveBudgets(budgets: other, fromOffsets: indices, toOffset: newOffset, context: viewContext)
                    }
                )// Other Budgets
            }// List
            .listStyle(.plain)
            .navigationTitle("Budgets")
            .searchable(text: $searchText)
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
                }
                
            }// toolbar
            .sheet(isPresented: $isPresented) {
                AddBudgetScreen(viewModel: viewModel, isPresented: $isPresented)
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .presentationDetents([.fraction(0.60)])
            }// Add budget sheet
        }// NavigationStack
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }// alert
    }// body
}// View

// MARK: - Preview
#Preview {
    let preview = PersistenceController.preview
    let context = preview.container.viewContext
    return BudgetListScreen()
        .environment(\.managedObjectContext, context)
}
