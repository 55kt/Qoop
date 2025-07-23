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
        VStack(spacing: 0) {
            // Main content area
            VStack(spacing: 16) {
                // Header with emoji and title
                HStack(alignment: .center, spacing: 16) {
                    // Emoji with larger background
                    Text(budget.emoji ?? EmojiDataModel.defaultEmoji)
                        .font(.system(size: 48))
                        .frame(width: 72, height: 72)
                        .background(
                            Circle()
                                .fill(statusColor.opacity(0.08))
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Title and status badge
                        HStack {
                            Text(budget.title ?? "")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if budget.isActive {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 6, height: 6)
                                    Text("ACTIVE")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.green.opacity(0.1))
                                )
                            }
                        }
                        
                        // Budget amounts
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Remaining:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(remaining, format: .currency(code: Locale.currencyCode))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(statusColor)
                            }
                            
                            HStack {
                                Text("Budget:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(budget.limit, format: .currency(code: Locale.currencyCode))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                // Progress bar
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Spent: \(spent, format: .currency(code: Locale.currencyCode))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        let percentage = budget.limit > 0 ? (spent / budget.limit) * 100 : 0
                        Text("\(Int(percentage))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                            
                            // Progress
                            if budget.limit > 0 {
                                let progress = min(spent / budget.limit, 1.0)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: progress > 0.9 ? [.red, .orange] : progress > 0.7 ? [.orange, .yellow] : [.green, .mint],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * progress, height: 8)
                                    .animation(.easeInOut(duration: 0.3), value: progress)
                            }
                        }
                    }
                    .frame(height: 8)
                }
                
                // Footer with creation date
                HStack {
                    HStack(spacing: 2) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("Created: ")
                        Text(budget.dateCreated?.formatted(date: .abbreviated, time: .omitted) ?? "")
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    
                }
            }
        }
        
    }
    
    static func remainingStatusColor(limit: Double, remaining: Double) -> Color {
        guard limit > 0, remaining >= 0 else { return .gray }
        let percentage = remaining / limit
        return percentage >= 0.75 ? .green : percentage >= 0.25 ? .yellow : .red
    }
}

#Preview {
    struct PreviewContainer: View {
        let context = PersistenceController.preview.container.viewContext
        let viewModel = ExpenseViewModel()
        
        var body: some View {
            VStack(spacing: 16) {
                // Активный бюджет с хорошим остатком
                let budget1 = Budget(context: context)
                budget1.title = "Groceries"
                budget1.limit = 500
                budget1.emoji = "🛒"
                budget1.dateCreated = Date()
                budget1.isActive = true
                
                // Бюджет с низким остатком
                let budget2 = Budget(context: context)
                budget2.title = "Entertainment"
                budget2.limit = 200
                budget2.emoji = "🎬"
                budget2.dateCreated = Calendar.current.date(byAdding: .day, value: -5, to: Date())
                budget2.isActive = false

                return VStack(spacing: 16) {
                    BudgetCardView(budget: budget1, expenseViewModel: viewModel)
                    BudgetCardView(budget: budget2, expenseViewModel: viewModel)
                }
                .padding()
            }
        }
    }

    return PreviewContainer()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

#Preview("Dark Mode") {
    struct PreviewContainer: View {
        let context = PersistenceController.preview.container.viewContext
        let viewModel = ExpenseViewModel()
        
        var body: some View {
            let budget = Budget(context: context)
            budget.title = "Shopping"
            budget.limit = 300
            budget.emoji = "🛍️"
            budget.dateCreated = Date()
            budget.isActive = true

            return BudgetCardView(budget: budget, expenseViewModel: viewModel)
                .padding()
        }
    }

    return PreviewContainer()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .preferredColorScheme(.dark)
}
