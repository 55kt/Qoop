//
//  AddBudgetScreen.swift
//  Qoop
//
//  Created by Vlad on 12/7/25.
//

import SwiftUI

struct AddBudgetScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var limit: Double?
    @State private var emoji: String = "💸"
    
    @State private var errorMessage: String?
    
    private var isFormValid: Bool {
        !title.isEmptyOrWhitespace && limit != nil && Double(limit!) > 0
    }
    
    var body: some View {
        Form {
            HStack {
                Text("New Budget")
                    .font(.title)
                
                Spacer()
                
                Text(emoji)
                    .font(.largeTitle)
            }
            
            TextField("Title", text: $title)
            TextField("Limit", value: $limit, format: .number)
                .keyboardType(.numberPad)
            
            EmojiPickerRow(title: "Select emoji", selection: $emoji)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            }
            
            Button("Save") {
                do {
                    try BudgetManager.addBudget(title: title, limit: limit ?? 0, emoji: emoji, context: viewContext)
                    print("✅ Budget \(title) with limit \(limit ?? 0) saved successfully")
                    dismiss()
                } catch let error as NSError {
                    errorMessage = "❌ Failed to save budget \(title): \(error.localizedDescription)"
                    print("❌ \(errorMessage!)")
                }
            }
            .frame(maxWidth: .infinity)
            .disabled(!isFormValid)
        }
    }
}

#Preview {
    let preview = PersistenceController.preview
        let context = preview.container.viewContext
        return AddBudgetScreen()
            .environment(\.managedObjectContext, context)
}
