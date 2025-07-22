//
//  OtherBudgetsSectionView.swift
//  Qoop
//
//  Created by Vlad on 22/7/25.
//

import SwiftUI

struct OtherBudgetsSectionView: View {
    // MARK: - Properties
    let budgets: [Budget]
    let showHeader: Bool
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
                if showHeader {
                    HStack(spacing: 2) {
                        Image(systemName: "doc.on.clipboard.fill")
                            .font(.system(size: 18))
                        Text("Other budgets")
                    }// HStack
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                }// if
            }// Section
        }// if
    }// body
}// View
