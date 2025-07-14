//
//  BudgetListScreen.swift
//  Qoop
//
//  Created by Vlad on 12/7/25.
//

import SwiftUI

struct BudgetListScreen: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\Budget.dateCreated, order: .reverse)], animation: .default)
    private var budgets: FetchedResults<Budget>
    
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            List(budgets) { budget in
                NavigationLink {
                    BudgetDetailScreen(budget: budget)
                } label: {
                    BudgetCardView(budget: budget)
                }
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add budget") {
                        isPresented.toggle()
                    }
                }
            }
            .sheet(isPresented: $isPresented) {
                AddBudgetScreen()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .presentationDetents([.fraction(0.35)])
            }
            .onAppear {
                print("Budgets: \(budgets.map { $0.title ?? "No title" })")
            }
        }
        
    }
}

#Preview {
    let preview = PersistenceController.preview
    let context = preview.container.viewContext
    return BudgetListScreen()
        .environment(\.managedObjectContext, context)
}
