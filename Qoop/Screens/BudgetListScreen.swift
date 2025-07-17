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
    
    @State private var isPresented: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            List(budgets) { budget in
                NavigationLink {
                    BudgetDetailScreen(budget: budget)
                } label: {
                    BudgetCardView(budget: budget)
                }// NavigationLink
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
    }// Body
}// View

// MARK: - Preview
#Preview {
    let preview = PersistenceController.preview
    let context = preview.container.viewContext
    return BudgetListScreen()
        .environment(\.managedObjectContext, context)
}
