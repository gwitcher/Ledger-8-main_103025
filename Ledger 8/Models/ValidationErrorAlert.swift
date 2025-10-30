//
//  ValidationErrorAlert.swift
//  Ledger 8
//
//  Created for Phase 0 - Critical Foundation fixes
//

import SwiftUI

// MARK: - Validation Error Alert View
struct ValidationErrorAlert: ViewModifier {
    @Binding var error: LedgerError?
    
    func body(content: Content) -> some View {
        content
            .alert("Validation Error", 
                   isPresented: Binding<Bool>(
                    get: { error != nil },
                    set: { if !$0 { error = nil } }
                   )) {
                Button("OK") {
                    error = nil
                }
            } message: {
                if let error = error {
                    VStack(alignment: .leading) {
                        Text(error.localizedDescription)
                        if let suggestion = error.recoverySuggestion {
                            Text(suggestion)
                                .font(.caption)
                        }
                    }
                }
            }
    }
}

// MARK: - View Extension
extension View {
    func validationErrorAlert(_ error: Binding<LedgerError?>) -> some View {
        modifier(ValidationErrorAlert(error: error))
    }
}

// MARK: - Form Validation State
@Observable
class FormValidationState {
    var isValid = true
    var errors: [String] = []
    var currentError: LedgerError?
    
    func validate(_ validatable: Validatable) {
        do {
            try validatable.validate()
            isValid = true
            errors.removeAll()
            currentError = nil
        } catch let error as LedgerError {
            isValid = false
            currentError = error
            ErrorHandler.handle(error, context: "Form Validation")
        } catch {
            isValid = false
            currentError = LedgerError.validationFailed(error.localizedDescription)
            ErrorHandler.handle(error, context: "Form Validation")
        }
    }
    
    func clearErrors() {
        isValid = true
        errors.removeAll()
        currentError = nil
    }
}