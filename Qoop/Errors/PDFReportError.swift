//
//  PDFReportError.swift
//  Qoop
//
//  Created by Vlad on 30/7/25.
//

import Foundation

enum PDFReportError: LocalizedError, Identifiable {
    var id: String { localizedDescription }

    case generationFailed
    case invalidPDFData
    case previewFailed
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .generationFailed: return "Failed to generate PDF."
        case .invalidPDFData: return "PDF data is invalid."
        case .previewFailed: return "Failed to preview PDF."
        case .saveFailed(let message): return message
        }
    }
}
