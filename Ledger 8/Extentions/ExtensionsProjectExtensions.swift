//
//  ProjectExtensions.swift
//  Ledger 8
//
//  Created by Gabe Witcher on 10/30/25.
//

import Foundation

@MainActor
extension Project {
    
    /// Calculate the total fees for this project's items
    var totalFees: Double {
        ProjectService.calculateFeeTotal(items: items ?? [])
    }
    
    /// Generate an invoice for this project
    func generateInvoice(invoiceNumber: Int) -> Invoice {
        InvoiceService.renderInvoice(project: self, invoiceNumber: invoiceNumber)
    }
}