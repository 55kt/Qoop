//
//  PDFReportViewModel.swift
//  Qoop
//
//  Created by Vlad on 29/7/25.
//

import Foundation
import PDFKit
import UIKit

final class PDFReportViewModel {
    
    static func generatePDF(for budget: Budget) -> Data? {
        let pdfMetaData: [CFString: Any] = [
            kCGPDFContextCreator: "Qoop",
            kCGPDFContextAuthor: "Qoop User",
            kCGPDFContextTitle: budget.title ?? "Untitled"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 24.0

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let data = renderer.pdfData { context in
            context.beginPage()
            var yOffset: CGFloat = margin

            func drawText(_ text: String, font: UIFont = .systemFont(ofSize: 14), spacing: CGFloat = 8) {
                let attributes: [NSAttributedString.Key: Any] = [.font: font]
                text.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: attributes)
                yOffset += font.lineHeight + spacing
            }

            drawText("Budget Report", font: .boldSystemFont(ofSize: 24), spacing: 12)
            drawText("Title: \(budget.title ?? "-")", font: .systemFont(ofSize: 16))
            drawText("Created: \(DateFormatter.localizedString(from: budget.dateCreated ?? Date(), dateStyle: .medium, timeStyle: .none))", font: .systemFont(ofSize: 16))
            drawText("Limit: $\(String(format: "%.2f", budget.limit))", font: .systemFont(ofSize: 16))
            yOffset += 12

            drawText("Expenses", font: .boldSystemFont(ofSize: 18), spacing: 12)
            
            if let expenses = budget.expenses as? Set<Expense>, !expenses.isEmpty {
                for expense in expenses.sorted(by: { ($0.dateCreated ?? Date()) < ($1.dateCreated ?? Date()) }) {
                    if yOffset > pageHeight - margin * 2 {
                        context.beginPage()
                        yOffset = margin
                    }
                    let title = expense.title ?? "-"
                    let amount = expense.amount
                    let quantity = expense.quantity
                    let date = expense.dateCreated ?? Date()
                    let dateString = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
                    
                    drawText("• \(title): $\(amount) × \(quantity) — \(dateString)", font: .systemFont(ofSize: 14))
                }
            } else {
                drawText("No expenses recorded.", font: .italicSystemFont(ofSize: 14))
            }
        }

        return data
    }
    
    static func savePDFToFiles(data: Data, name: String, from viewController: UIViewController?) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do {
            try data.write(to: tempURL)
            let documentPicker = UIDocumentPickerViewController(forExporting: [tempURL])
            documentPicker.allowsMultipleSelection = false
            if let vc = viewController {
                vc.present(documentPicker, animated: true, completion: nil)
            } else {
                print("⚠️ Could not find a valid view controller for UIDocumentPickerViewController")
            }
        } catch {
            print("❌ Failed to save PDF: \(error.localizedDescription)")
        }
    }
}
