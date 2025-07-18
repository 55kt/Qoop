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
            List {
                ForEach(budgets) { budget in
                    NavigationLink {
                        BudgetDetailScreen(budget: budget)
                    } label: {
                        BudgetCardView(budget: budget)
                    }// NavigationLink
                }// ForEach
                .onDelete { indexSet in
                    viewModel.deleteBudgets(offsets: indexSet, budgets: budgets, context: viewContext)
                }
                .listRowBackground(Color.clear)
            }// List
            .listStyle(.plain)
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add budget") {
                        isPresented.toggle()
                    }
                }
            }// toolbar
            .sheet(isPresented: $isPresented) {
                AddBudgetScreen()
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
