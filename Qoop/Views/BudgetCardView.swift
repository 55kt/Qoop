//
//  BudgetCardView.swift
//  Qoop
//
//  Created by Vlad on 13/7/25.
//

import SwiftUI

struct BudgetCardView: View {
    // MARK: - Properties
    let budget: Budget
    @ObservedObject var expenseViewModel: ExpenseViewModel
    private let statusColor: Color
    private let (spent, remaining): (Double, Double)
    
    init(budget: Budget, expenseViewModel: ExpenseViewModel) {
        self.budget = budget
        self.expenseViewModel = expenseViewModel
        let details = expenseViewModel.calculateBudgetDetails(for: budget)
        self.spent = details.spent
        self.remaining = details.remaining
        self.statusColor = Self.remainingStatusColor(limit: budget.limit, remaining: remaining)
    }
    
    // MARK: - Body
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(budget.emoji ?? EmojiDataModel.defaultEmoji)
                .font(.system(size: 80))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(budget.title ?? "")
                    .font(.title)
                
                HStack(spacing: 3) {
                    Text(remaining, format: .currency(code: Locale.currencyCode))
                        .foregroundColor(statusColor)
                    Text(" / \(budget.limit, format: .currency(code: Locale.currencyCode))")
                }
                .font(.subheadline)
                
                if budget.isActive {
                    Capsule()
                        .frame(width: 80, height: 30)
                        .foregroundStyle(.ultraThinMaterial)
                        .overlay {
                            Text("ACTIVE")
                                .foregroundColor(.green)
                                .bold()
                        }
                }
                
                Text("Created: \(budget.dateCreated?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 10))
            }
        }
        .padding(.vertical, 5)
    }
    
    static func remainingStatusColor(limit: Double, remaining: Double) -> Color {
        guard limit > 0, remaining >= 0 else { return .gray }
        let percentage = remaining / limit
        return percentage >= 0.75 ? .green : percentage >= 0.25 ? .yellow : .red
    }
}


