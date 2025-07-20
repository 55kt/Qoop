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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: -5) {
                    Text(budget.emoji ?? EmojiDataModel.defaultEmoji)
                        .font(.system(size: 80))
                    
                    HStack(spacing: 2) {
                        Text("Created:")
                        Text(budget.dateCreated ?? Date(), style: .date)
                    }// HStack
                    .foregroundStyle(.secondary)
                    .font(.system(size: 10))
                }// VStack
                
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.title ?? "")
                        .font(.title)
                    HStack(spacing: 3) {
                        Text("Remaining:")
                        
                        Text(budget.limit, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
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
                }// VStack
                .frame(height: .zero)
            }// HStack
        }// VStack
        .shadow(radius: 0.5)
    }// View
}// View

// MARK: - Preview
#Preview {
    BudgetCardView(budget: Budget(context: PersistenceController.preview.container.viewContext))
}
