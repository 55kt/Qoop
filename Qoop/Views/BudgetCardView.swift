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
    private let statusColor: Color
    
    init(budget: Budget) {
        self.budget = budget
        self.statusColor = Self.remainingStatusColor(limit: budget.limit, remaining: budget.remaining)
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
                    Text("Remaining:")
                    Text(budget.remaining, format: .currency(code: Locale.currencyCode))
                        .foregroundColor(statusColor)
                }// HStack
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
                }// if budget is active
                
                Text("Created: \(budget.dateCreated?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 10))
            }// VStack
        }// HStack
    }// body
    
    // MARK: - Methods
    static func remainingStatusColor(limit: Double, remaining: Double) -> Color {
        guard limit > 0, remaining >= 0 else { return .gray }
        let percentage = remaining / limit
        return percentage >= 0.75 ? .green : percentage >= 0.25 ? .yellow : .red
    }// remainingStatusColor
    
}// View

// MARK: - Preview
#Preview {
    BudgetCardView(budget: Budget(context: PersistenceController.preview.container.viewContext))
}
