//
//  EditBudgetScreen.swift
//  Qoop
//
//  Created by Vlad on 20/7/25.
//

import SwiftUI

struct EditBudgetScreen: View {
    // MARK: - Properties
    let budget: Budget
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel = BudgetViewModel()
    @Binding var isPresented: Bool
    
    @State private var title: String
    @State private var limit: Double?
    @State private var emoji: String
    
    @State private var errorMessage: String?
    
    private var isFormValid: Bool {
        !title.isEmptyOrWhitespace && limit != nil && Double(limit!) > 0
    }
    
    init(budget: Budget, isPresented: Binding<Bool>) {
        self.budget = budget
        self._isPresented = isPresented
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Edit") {
                        guard let unwrappedLimit = limit else { return }
                        
                        do {
                            try viewModel.editBudget(budget, newTitle: title, newLimit: unwrappedLimit, newEmoji: emoji, context: viewContext)
                            if !viewModel.showErrorAlert {
                                isPresented = false
                                errorMessage = nil
                            }
                        } catch {
                            errorMessage = "Failed to save: \(error.localizedDescription)"
                        }
                    }// Edit button
                    .disabled(!isFormValid)
                }
            }// toolbar
        }// NavigationStack
    }// body
}// View

// MARK: - Preview
#Preview {
    let preview = PersistenceController.preview
    let context = preview.container.viewContext
    let budget = Budget(context: context)
    budget.title = "Test Budget"
    budget.limit = 100.0
    budget.emoji = "💰"
    @State var isPresented = true
    return EditBudgetScreen(budget: budget, isPresented: $isPresented)
        .environment(\.managedObjectContext, context)
}
