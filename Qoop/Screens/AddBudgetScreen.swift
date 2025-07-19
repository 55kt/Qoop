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
    @Binding var isPresented: Bool
    
    @State private var title: String = ""
    @State private var limit: Double?
    @State private var emoji: String = "💸"
    
    @State private var errorMessage: String?
    
    private var isFormValid: Bool {
        !title.isEmptyOrWhitespace && limit != nil && Double(limit!) > 0
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                
                
                Section {
                    TextField("Title", text: $title)
                    TextField("Limit", value: $limit, format: .number)
                        .keyboardType(.numberPad)
                }
                .padding(10)
                
                EmojiPickerRow(title: "Select emoji", selection: $emoji)
                    .frame(maxWidth: .infinity)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }// if let error
            }// Form
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let unwrappedLimit = limit else { return }
                        
                        viewModel.addBudget(
                            title: title,
                            limit: unwrappedLimit,
                            emoji: emoji,
                            context: viewContext
                        )
                        
                        if !viewModel.showErrorAlert {
                            isPresented = false
                        }
                    }// save button
                    .disabled(!isFormValid)
                }
            }

        }// NavigationStack
    }// View
}// body

// MARK: - Preview
#Preview {
    let preview = PersistenceController.preview
    let context = preview.container.viewContext
    let viewModel = BudgetViewModel()
    @State var isPresented = true
    return AddBudgetScreen(viewModel: viewModel, isPresented: $isPresented)
        .environment(\.managedObjectContext, context)
}
