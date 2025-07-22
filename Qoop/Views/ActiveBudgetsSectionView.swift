//
//  ActiveBudgetsSectionView.swift
//  Qoop
//
//  Created by Vlad on 22/7/25.
//

import SwiftUI

struct ActiveBudgetsSectionView: View {
    
    // MARK: - Properties
    let budgets: [Budget]
    let onDelete: (IndexSet) -> Void
    let onMove: (IndexSet, Int) -> Void
    let expenseViewModel: ExpenseViewModel

    // MARK: - Body
    var body: some View {
        if !budgets.isEmpty {
            Section {
                ForEach(budgets) { budget in
                    NavigationLink {
                        BudgetDetailScreen(budget: budget)
                    } label: {
                        BudgetCardView(budget: budget, expenseViewModel: expenseViewModel)
                    }
                }// ForEach
                .onDelete(perform: onDelete)
                .onMove(perform: onMove)
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
        }// if
    }// body
}// View
