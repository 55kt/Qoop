//
//  PDFReportScreen.swift
//  Qoop
//
//  Created by Vlad on 29/7/25.
//

import SwiftUI
import CoreData
import PDFKit

enum PDFReportError: LocalizedError, Identifiable {
    var id: String { localizedDescription }

    case generationFailed
    case invalidPDFData
    case previewFailed

    var errorDescription: String? {
        switch self {
        case .generationFailed: return "Failed to generate PDF."
        case .invalidPDFData: return "PDF data is invalid."
        case .previewFailed: return "Failed to preview PDF."
        }
    }
}

struct PDFReportScreen: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Budget.dateCreated, ascending: false)],
        animation: .default
    ) private var budgets: FetchedResults<Budget>

    @State private var selectedBudget: Budget? = nil
    @State private var showPDFPreview = false
    @State private var generatedPDFData: Data? = nil
    @State private var isGenerating = false
    @State private var activeError: PDFReportError? = nil

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
                            Button(action: {
                                Task {
                                    isGenerating = true
                                    selectedBudget = budget
                                    guard let pdfData = PDFReportViewModel.generatePDF(for: budget),
                                          PDFDocument(data: pdfData) != nil else {
                                        activeError = .invalidPDFData
                                        isGenerating = false
                                        return
                                    }
                                    generatedPDFData = pdfData
                                    showPDFPreview = true
                                    isGenerating = false
                                }
                            }) {
                                if isGenerating && selectedBudget == budget {
                                    ProgressView()
                                } else {
                                    Text("Preview")
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
                                    activeError = .generationFailed
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
                    Text("Preview unavailable")
                }
            }
            .alert(item: $activeError) { error in
                Alert(title: Text("Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    PDFReportScreen()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
