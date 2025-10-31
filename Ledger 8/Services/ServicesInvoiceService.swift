//
//  InvoiceService.swift
//  Ledger 8
//
//  Created by Gabe Witcher on 10/30/25.
//

import Foundation
import SwiftUI

@MainActor
class InvoiceService {
    
    /// Generate a PDF invoice for a project
    static func renderInvoice(project: Project, invoiceNumber: Int) -> Invoice {
        let invoiceDate = Date.now
        let nextInvoiceNumber = invoiceNumber + 1
        let invoiceName = generateInvoiceName(
            invoiceNumber: nextInvoiceNumber,
            clientName: project.client?.fullName ?? "Unknown",
            date: invoiceDate
        )
        
        let newInvoice = Invoice(number: nextInvoiceNumber, name: invoiceName)
        project.invoice = newInvoice
        
        let url = renderInvoicePDF(project: project, invoiceName: invoiceName)
        newInvoice.url = url
        
        print("Invoice Name: \(invoiceName)")
        return newInvoice
    }
    
    private static func generateInvoiceName(invoiceNumber: Int, clientName: String, date: Date) -> String {
        let formattedDate = date.formatted(.iso8601.year().month().day().dateSeparator(.dash))
        return "Invoice_\(invoiceNumber)_\(clientName)_\(formattedDate).pdf"
    }
    
    private static func renderInvoicePDF(project: Project, invoiceName: String) -> URL {
        let renderer = ImageRenderer(content: InvoiceTemplateView(project: project))
        let url = URL.documentsDirectory.appending(path: invoiceName)
        
        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }
            
            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }
        
        return url
    }
}