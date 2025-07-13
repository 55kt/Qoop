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
        VStack {
            Image(systemName: budget.icon ?? "person.circle.fill")
            
            HStack {
                Text(budget.title ?? "")
                Spacer()
                Text(budget.limit, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
            }
            
            HStack {
                Text("Created:")
                Text(budget.dateCreated ?? Date(), style: .date)
                Spacer()
            }
            .padding(.leading)
        }
    }
}

#Preview {
    BudgetCardView(budget: Budget(
        context: PersistenceController.preview.container.viewContext
    ))
}
