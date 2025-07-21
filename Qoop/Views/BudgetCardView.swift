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
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(budget.emoji ?? EmojiDataModel.defaultEmoji)
                        .font(.system(size: 80))
                }// VStack
                
                
                VStack(alignment: .leading) {
                    Text(budget.title ?? "")
                        .font(.title)
                    HStack(spacing: 3) {
                        Text("Remaining:")
                        
                        Text(budget.remaining, format: .currency(code: Locale.currencyCode))
                            .foregroundColor(remainingStatusColor(limit: budget.limit, remaining: budget.remaining))
                    }// HStack
                    .font(.subheadline)

                    
                    Spacer()
                    
                    if budget.isActive {
                        ZStack {
                            Capsule()
                                .frame(width: 80, height: 30)
                                .foregroundStyle(.ultraThinMaterial)
                            
                            Text("ACTIVE")
                                .foregroundColor(.green)
                                .bold()
                        }// ZStack
                    }// if
                    
                    HStack(spacing: 2) {
                        Text("Created:")
                        Text(budget.dateCreated ?? Date(), style: .date)
                    }// HStack
                    .foregroundStyle(.secondary)
                    .font(.system(size: 10))
                }// VStack
                .frame(height: .zero)
            }// HStack
        }// VStack
        .shadow(radius: 0.5)
    }// View
    
    func remainingStatusColor(limit: Double, remaining: Double) -> Color {
            guard limit > 0, remaining >= 0 else { return .gray }
            
            let percentage = remaining / limit
            
            switch percentage {
            case let x where x >= 0.75:
                return .green
            case 0.25..<0.75:
                return .yellow
            case ..<0.25:
                return .red
            default:
                return .gray
            }
        }
    
}// View

// MARK: - Preview
#Preview {
    BudgetCardView(budget: Budget(context: PersistenceController.preview.container.viewContext))
}
