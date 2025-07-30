//
//  PDFReportViewModel.swift
//  Qoop
//
//  Created by Vlad on 29/7/25.
//

import Foundation
import PDFKit
import SwiftUI

final class PDFReportViewModel: ObservableObject {
    @Published var selectedBudget: Budget? = nil
    @Published var showPDFPreview = false
    @Published var generatedPDFData: Data? = nil
    @Published var isGenerating = false
    @Published var activeError: PDFReportError? = nil
    @Published var showSuccessAlert = false

    private class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
        let onSuccess: () -> Void
        let onFailure: () -> Void

        init(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
            self.onSuccess = onSuccess
            self.onFailure = onFailure
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onSuccess()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onFailure()
        }
    }

    func previewPDF(for budget: Budget, completion: @escaping () -> Void) {
            isGenerating = true
            selectedBudget = budget

            DispatchQueue.global(qos: .userInitiated).async {
                guard let pdfData = Self.generatePDF(for: budget),
                      PDFDocument(data: pdfData) != nil else {
                    DispatchQueue.main.async {
                        self.activeError = .invalidPDFData
                        self.isGenerating = false
                        completion()
                    }
                    return
                }

                DispatchQueue.main.async {
                    self.generatedPDFData = pdfData
                    self.showPDFPreview = true
                    self.isGenerating = false
                    completion()
                }
            }
        }

    func exportPDF(for budget: Budget) {
        guard let pdfData = Self.generatePDF(for: budget) else {
            activeError = .generationFailed
            return
        }

        guard let viewController = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first?.rootViewController })
            .first else {
            activeError = .previewFailed
            return
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(budget.title ?? "Report").pdf")

        do {
            try pdfData.write(to: tempURL)
            let picker = UIDocumentPickerViewController(forExporting: [tempURL])
            picker.allowsMultipleSelection = false

            let delegate = DocumentPickerDelegate(
                onSuccess: { self.showSuccessAlert = true },
                onFailure: { self.activeError = nil }
            )

            picker.delegate = delegate
            objc_setAssociatedObject(picker, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            viewController.present(picker, animated: true)
        } catch {
            activeError = .saveFailed(error.localizedDescription)
        }
    }

    static func generatePDF(for budget: Budget) -> Data? {
        let metadata: [CFString: Any] = [
            kCGPDFContextCreator: "Qoop",
            kCGPDFContextAuthor: "Qoop User",
            kCGPDFContextTitle: budget.title ?? "Untitled"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = metadata as [String: Any]

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595.2, height: 841.8), format: format)

        return renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = 24

            func draw(_ text: String, font: UIFont = .systemFont(ofSize: 14), spacing: CGFloat = 8) {
                text.draw(at: CGPoint(x: 24, y: y), withAttributes: [.font: font])
                y += font.lineHeight + spacing
            }

            draw("Budget Report", font: .boldSystemFont(ofSize: 24), spacing: 12)
            draw("Title: \(budget.title ?? "-")", font: .systemFont(ofSize: 16))
            draw("Created: \(DateFormatter.localizedString(from: budget.dateCreated ?? Date(), dateStyle: .medium, timeStyle: .none))", font: .systemFont(ofSize: 16))
            draw("Limit: $\(String(format: "%.2f", budget.limit))", font: .systemFont(ofSize: 16))

            y += 12
            draw("Expenses", font: .boldSystemFont(ofSize: 18), spacing: 12)

            if let expenses = budget.expenses as? Set<Expense>, !expenses.isEmpty {
                for e in expenses.sorted(by: { ($0.dateCreated ?? .distantPast) < ($1.dateCreated ?? .distantPast) }) {
                    if y > 793 {
                        context.beginPage()
                        y = 24
                    }
                    let dateStr = DateFormatter.localizedString(from: e.dateCreated ?? Date(), dateStyle: .short, timeStyle: .none)
                    draw("• \(e.title ?? "-"): $\(e.amount) × \(e.quantity) — \(dateStr)")
                }
            } else {
                draw("No expenses recorded.", font: .italicSystemFont(ofSize: 14))
            }
        }
    }
}
