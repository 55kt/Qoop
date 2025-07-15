//
//  ExpenseCardView.swift
//  Qoop
//
//  Created by Vlad on 15/7/25.
//

import SwiftUI

struct ExpenseCardView: View {
    
    let expense: Expense
    
    @State private var title: String = ""
    @State private var amount: Double?
    @State private var emoji: String = "💸"
    
    var body: some View {
        VStack {
            HStack {
                Text(expense.emoji ?? EmojiDataModel.defaultEmoji)
                Text(expense.title ?? "")
                Text("\(expense.quantity)")
                
                Spacer()
                VStack(alignment: .trailing) {
                    Text("One item price \(expense.amount, format: .currency(code: Locale.currencyCode))")
                    Text("Total price \(expense.total, format: .currency(code: Locale.currencyCode))")
                }
            }
            HStack {
                Text("Created:")
                Text(expense.dateCreated ?? Date(), style: .date)
                Spacer()
            }
            .font(.caption)
        }
    }
}


struct ExpenseCellViewContainer: View {
    
    @FetchRequest(sortDescriptors: []) private var expenses: FetchedResults<Expense>
    
    var body: some View {
        ExpenseCardView(expense: expenses[0])
    }
}

#Preview {
    ExpenseCellViewContainer()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
