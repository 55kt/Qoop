//
//  PDFKitPreviewView.swift
//  Qoop
//
//  Created by Vlad on 29/7/25.
//

import SwiftUI
import PDFKit

struct PDFKitPreviewView: UIViewRepresentable {
    let pdfData: Data?
    @State private var isLoading = true

    func makeUIView(context: Context) -> UIView {
        // Create a container view
        let containerView = UIView()

        // Setup PDFView
        let pdfView = PDFView()
        pdfView.tag = 1 // Tag to identify PDFView
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.frame = containerView.bounds
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(pdfView)

        // Setup loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.tag = 2 // Tag to identify activity indicator
        activityIndicator.color = .gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(activityIndicator)

        // Center the activity indicator
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])

        // Start loading animation
        activityIndicator.startAnimating()
        pdfView.isHidden = true

        // Validate PDF data asynchronously
        DispatchQueue.main.async {
            if let data = pdfData, PDFDocument(data: data) != nil {
                pdfView.document = PDFDocument(data: data)
                isLoading = false
                activityIndicator.stopAnimating()
                pdfView.isHidden = false
                print("✅ PDF loaded successfully in PDFKitPreviewView")
            } else {
                isLoading = true // Keep loading until valid data
                print("❌ Waiting for valid PDF data in PDFKitPreviewView")
            }
        }

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update PDFView if pdfData changes
        if let pdfView = uiView.viewWithTag(1) as? PDFView {
            if let data = pdfData, PDFDocument(data: data) != nil {
                pdfView.document = PDFDocument(data: data)
                isLoading = false
                pdfView.isHidden = false
            } else {
                pdfView.document = nil
                isLoading = true
                pdfView.isHidden = true
            }
        }

        // Update loading state
        if let activityIndicator = uiView.viewWithTag(2) as? UIActivityIndicatorView {
            if isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
}
