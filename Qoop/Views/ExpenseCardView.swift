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
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                HStack(alignment: .center, spacing: 0) {
                    Text(expense.emoji ?? EmojiDataModel.defaultEmoji)
                        .font(.system(size: 40))
                        .frame(width: 44, height: 44)
                        
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(expense.title ?? "")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Quantity: \(expense.quantity)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }// VStack
                    
                    Spacer()
                    
                    // Price section
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Text("Price per unit:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(expense.amount, format: .currency(code: Locale.currencyCode))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }// HStack
                        
                        HStack(spacing: 4) {
                            Text("Total:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(expense.total, format: .currency(code: Locale.currencyCode))")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }// HStack
                    }// VStack
                }// HStack
                
                HStack {
                    
                    
                    HStack(spacing: 2) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("Created: ")
                        Text(expense.dateCreated?.formatted(date: .abbreviated, time: .omitted) ?? "")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    
                    if let location = expense.location, !location.isEmpty {
                        
                        Spacer()

                        HStack(spacing: 2) {
                            Image(systemName: "location.circle")
                                .font(.system(size: 14))
                                .foregroundColor(.green)

                            Text(location)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(1)
                        }// HStack
                    }// if let location
                }// HStack
            }// VStack
        }// VStack
    }// body
}// View

// MARK: - Preview Container
struct ExpenseCellViewContainer: View {
    
    @FetchRequest(sortDescriptors: []) private var expenses: FetchedResults<Expense>
    
    var body: some View {
        ExpenseCardView(expense: expenses[0])
            .padding()
    }
}

#Preview {
    ExpenseCellViewContainer()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ExpenseCellViewContainer()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .preferredColorScheme(.dark)
}
