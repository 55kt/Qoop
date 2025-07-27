//
//  AddBudgetScreen.swift
//  Qoop
//
//  Created by Vlad on 12/7/25.
//

import SwiftUI

struct AddBudgetScreen: View {
    
    // MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: BudgetViewModel
    
    @State private var title: String = ""
    @State private var limit: Double?
    @State private var emoji: String = "💸"
    
    var existingBudgets: [Budget]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Limit", value: $limit, format: .number)
                        .keyboardType(.decimalPad)
                }// Section
                .padding(10)
                
                EmojiPickerRow(title: "Select emoji", selection: $emoji)
                    .frame(maxWidth: .infinity)
                
            }// Form
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard viewModel.isBudgetFormValid(title: title, limit: limit, existingBudgets: existingBudgets, currentBudget: nil) else {
                            viewModel.handle(error: BudgetError.invalidInput)
                            return
                        }
                        
                        do {
                            try viewModel.addBudget(
                                title: title,
                                limit: limit ?? 0,
                                emoji: emoji,
                                context: viewContext
                            )
                            dismiss()
                        } catch {
                            viewModel.handle(error: error)
                        }
                    }
                    .disabled(!viewModel.isBudgetFormValid(title: title, limit: limit, existingBudgets: existingBudgets, currentBudget: nil))
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }// toolbar
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }// alert
        }// NavigationStack
    }// View
}// body

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleBudgets: [Budget] = {
        let b1 = Budget(context: context)
        b1.title = "Food"
        b1.limit = 200
        let b2 = Budget(context: context)
        b2.title = "Transport"
        b2.limit = 100
        return [b1, b2]
    }()
    
    return AddBudgetScreen(viewModel: BudgetViewModel(), existingBudgets: sampleBudgets)
        .environment(\.managedObjectContext, context)
}
