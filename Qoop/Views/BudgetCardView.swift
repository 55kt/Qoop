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
            HStack(spacing: 15) {
                Text(budget.emoji ?? EmojiDataModel.defaultEmoji)
                    .font(.system(size: 80))
                VStack(alignment: .leading, spacing: 5) {
                    Text(budget.title ?? "")
                        .font(.title)
                    Text(budget.limit, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .font(.subheadline)
                    HStack {
                        Text("Created:")
                            .font(.caption)
                        Text(budget.dateCreated ?? Date(), style: .date)
                            .font(.caption)
                        Spacer()
                    }// HStack
                }// VStack
            }// HStack
        }// VStack
        .shadow(radius: 1)
    }// View
}// View

// MARK: - Preview
#Preview {
    BudgetCardView(budget: Budget(context: PersistenceController.preview.container.viewContext))
}
