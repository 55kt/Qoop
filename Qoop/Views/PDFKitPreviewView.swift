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

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()

        let pdfView = PDFView()
        pdfView.tag = 1
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.translatesAutoresizingMaskIntoConstraints = false

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.tag = 2
        activityIndicator.color = .gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()

        containerView.addSubview(pdfView)
        containerView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            pdfView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])

        DispatchQueue.main.async {
            if let data = pdfData, let document = PDFDocument(data: data) {
                pdfView.document = document
                activityIndicator.stopAnimating()
            }
        }

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let pdfView = uiView.viewWithTag(1) as? PDFView,
              let activityIndicator = uiView.viewWithTag(2) as? UIActivityIndicatorView else { return }

        if let data = pdfData, let document = PDFDocument(data: data) {
            pdfView.document = document
            activityIndicator.stopAnimating()
        } else {
            pdfView.document = nil
            activityIndicator.startAnimating()
        }
    }
}
