//
//  BudgetCardView.swift
//  Qoop
//
//  Created by Vlad on 13/7/25.
//

import SwiftUI

struct BudgetCardView: View {
    let budget: Budget
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 15) {
                Text(budget.emoji ?? EmojiDataModel.defaultEmoji)
                    .font(.system(size: 50))
                VStack(alignment: .leading, spacing: 5) {
                    Text(budget.title ?? "")
                        .font(.headline)
                    Text(budget.limit, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .font(.subheadline)
                    HStack {
                        Text("Created:")
                            .font(.caption)
                        Text(budget.dateCreated ?? Date(), style: .date)
                            .font(.caption)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    BudgetCardView(budget: Budget(context: PersistenceController.preview.container.viewContext))
}
