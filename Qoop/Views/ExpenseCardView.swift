//
//  ExpenseCardView.swift
//  Qoop
//
//  Created by Vlad on 15/7/25.
//

import SwiftUI

struct ExpenseCardView: View {
    
    // MARK: - Properties
    @ObservedObject var expense: Expense
    
    // MARK: - Body
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
                }// VStack
            }// Hstack
            HStack {
                Text("Created:")
                Text(expense.dateCreated ?? Date(), style: .date)
                Spacer()
            }// HStack
            .font(.caption)
            
            HStack(spacing: 3) {
                Image(systemName: "location.circle")
                Text("Purchase location: \(expense.location ?? "")")
                
                Spacer()
                    
            }// Hstack
            .font(.caption)
            .foregroundColor(.secondary)
        }// VStack
        .contentShape(Rectangle())
    }// body
}// View

// MARK: - Preview Container
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
