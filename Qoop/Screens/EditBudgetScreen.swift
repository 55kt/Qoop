//
//  EditBudgetScreen.swift
//  Qoop
//
//  Created by Vlad on 20/7/25.
//

import SwiftUI

struct EditBudgetScreen: View {
    // MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BudgetViewModel()
    
    let budget: Budget
        
    @State private var title: String = ""
    @State private var limit: Double?
    @State private var emoji: String = "💸"
    
    
    private var isFormValid: Bool {
        !title.isEmptyOrWhitespace && limit != nil && Double(limit!) > 0
    }
    
    init(budget: Budget, isPresented: Binding<Bool>) {
        self.budget = budget
        _title = State(initialValue: budget.title ?? "")
        _limit = State(initialValue: budget.limit)
        _emoji = State(initialValue: budget.emoji ?? "💸")
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Limit", value: $limit, format: .number)
                        .keyboardType(.numberPad)
                }// TextFields Section
                .padding(10)
                
                EmojiPickerRow(title: "Edit emoji", selection: $emoji)
                    .frame(maxWidth: .infinity)
                
            }// Form
            .navigationTitle("Edit Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Edit") {
                        do {
                            try viewModel.editBudget(
                                budget,
                                newTitle: title,
                                newLimit: limit ?? 0,
                                newEmoji: emoji,
                                context: viewContext
                            )
                            dismiss()
                        } catch {
                            viewModel.handle(error: error)
                        }
                    }// Edit button
                    .disabled(!isFormValid)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }// toolbar
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }// NavigationStack
    }// body
}// View

// MARK: - Preview
#Preview {
    @Previewable @State var isPresented = true
    
    let preview = PersistenceController.preview
    let context = preview.container.viewContext
    let budget = Budget(context: context)
    budget.title = "Test Budget"
    budget.limit = 100.0
    budget.emoji = "💰"
    return EditBudgetScreen(budget: budget, isPresented: $isPresented)
        .environment(\.managedObjectContext, context)
}
