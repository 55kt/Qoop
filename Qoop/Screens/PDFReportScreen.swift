//
//  PDFReportScreen.swift
//  Qoop
//
//  Created by Vlad on 29/7/25.
//

import SwiftUI
import CoreData
import PDFKit

struct PDFReportScreen: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Budget.dateCreated, ascending: false)],
        animation: .default
    ) private var budgets: FetchedResults<Budget>
    
    @StateObject private var viewModel = PDFReportViewModel()
    @State private var generatingBudgets: [Budget: Bool] = [:]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(budgets) { budget in
                    budgetCard(for: budget)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .listStyle(.plain)
            .navigationTitle("PDF Reports")
            .sheet(isPresented: $viewModel.showPDFPreview) {
                if let data = viewModel.generatedPDFData {
                    PDFKitPreviewView(pdfData: data)
                } else {
                    Text("Preview unavailable")
                }
            }
            .alert(item: $viewModel.activeError) { (error: PDFReportError) in
                Alert(title: Text("Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK")))
            }
            .alert("PDF saved successfully", isPresented: $viewModel.showSuccessAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    private func budgetCard(for budget: Budget) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 16) {
                Text(budget.emoji ?? "📄")
                    .font(.system(size: 55))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.title ?? "Untitled")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if let date = budget.dateCreated {
                        Text("Created \(date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            actionButtons(for: budget)
        }
    }
    
    private func actionButtons(for budget: Budget) -> some View {
        HStack(spacing: 12) {
            Button {
                generatingBudgets[budget] = true
                viewModel.previewPDF(for: budget) {
                    generatingBudgets[budget] = false
                }
            } label: {
                HStack {
                    if generatingBudgets[budget] ?? false {
                        ProgressView().scaleEffect(0.8)
                    } else {
                        Image(systemName: "eye")
                        Text("Preview")
                    }
                }
                .font(.callout)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(generatingBudgets[budget] ?? false)
            
            Button {
                viewModel.exportPDF(for: budget)
            } label: {
                HStack {
                    Image(systemName: "doc.text")
                    Text("Create PDF")
                }
                .font(.callout)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    PDFReportScreen()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
