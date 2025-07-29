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
    
    @State private var selectedBudget: Budget? = nil
    @State private var showPDFPreview = false
    @State private var generatedPDFData: Data? = nil

    var body: some View {
        NavigationStack {
            List {
                ForEach(budgets) { budget in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(budget.emoji ?? "📄")
                                .font(.system(size: 24))
                            VStack(alignment: .leading) {
                                Text(budget.title ?? "Untitled")
                                    .font(.headline)
                                if let date = budget.dateCreated {
                                    Text("Created: \(date.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                        }

                        HStack(spacing: 16) {
                            Button("Preview") {
                                selectedBudget = budget
                                if let pdfData = PDFReportViewModel.generatePDF(for: budget) {
                                    generatedPDFData = pdfData
                                    // Проверка валидности PDF
                                    if PDFDocument(data: pdfData) != nil {
                                        print("✅ PDF data is valid")
                                        showPDFPreview = true
                                    } else {
                                        print("❌ PDF data is invalid")
                                    }
                                } else {
                                    print("❌ Failed to generate PDF")
                                }
                            }
                            .buttonStyle(.bordered)

                            Button("Create PDF") {
                                if let pdfData = PDFReportViewModel.generatePDF(for: budget) {
                                    let rootVC = UIApplication.shared.connectedScenes
                                        .compactMap { ($0 as? UIWindowScene)?.windows.first?.rootViewController }
                                        .first
                                    PDFReportViewModel.savePDFToFiles(data: pdfData, name: "\(budget.title ?? "Report").pdf", from: rootVC)
                                } else {
                                    print("❌ Failed to generate PDF for saving")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("PDF Reports")
            .sheet(isPresented: $showPDFPreview) {
                if let data = generatedPDFData {
                    PDFKitPreviewView(pdfData: data)
                } else {
                    Text("Failed to load PDF")
                }
            }
        }
    }
}

#Preview {
    PDFReportScreen()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
