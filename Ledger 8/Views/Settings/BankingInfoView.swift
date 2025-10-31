//
//  BankingInfoView.swift
//  Ledger 8
//
//  Created by Gabe Witcher on 5/6/25.
//

import SwiftUI

struct BankingInfoView: View {
    
    @AppStorage("userData") var userData = UserData()
    @State private var validationState = FormValidationState()
    @FocusState private var focusedField: BankingField?
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Real-time Validation States
    @State private var routingValidationError: String?
    @State private var accountValidationError: String?
    @State private var venmoValidationError: String?
    @State private var zelleValidationError: String?
    
    // MARK: - Focus-aware validation tracking
    @State private var routingHasBeenFocused = false
    @State private var accountHasBeenFocused = false
    @State private var venmoHasBeenFocused = false
    @State private var zelleHasBeenFocused = false
    
    // MARK: - Validation Summary State
    @State private var showValidationSummary = false
    
    // MARK: - Computed Properties
    
    /// Checks if there are any real-time validation errors
    private var hasValidationErrors: Bool {
        return routingValidationError != nil || 
               accountValidationError != nil || 
               venmoValidationError != nil || 
               zelleValidationError != nil
    }
    
    /// Current validation errors for display in banner
    private var currentValidationErrors: [ValidationBannerError] {
        var errors: [ValidationBannerError] = []
        
        if let routingError = routingValidationError {
            errors.append(.routingNumber(routingError))
        }
        if let accountError = accountValidationError {
            errors.append(.accountNumber(accountError))
        }
        if let venmoError = venmoValidationError {
            errors.append(.venmo(venmoError))
        }
        if let zelleError = zelleValidationError {
            errors.append(.zelle(zelleError))
        }
        
        return errors
    }
    
    /// Auto-hide validation summary when errors are resolved
    private func checkAndHideValidationSummary() {
        if showValidationSummary && !hasValidationErrors {
            withAnimation(.easeOut(duration: 0.3)) {
                showValidationSummary = false
            }
        }
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                ValidationSummaryBanner(
                    title: "Please check field formatting:",
                    validationErrors: currentValidationErrors,
                    isVisible: $showValidationSummary
                )
                
                Section(header: Text("Banking Information"), 
                       footer: Text("This information will appear on your invoices for client payments.")) {
                    
                    // Bank Name - Optional
                    LabeledContent {
                        TextField("Bank Name", text: $userData.bankingInfo.bank)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .bank)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .accountName
                            }
                        
                    } label: {
                        Text("Bank:").foregroundStyle(.secondary)
                    }
                    
                    // Account Name - Optional
                    LabeledContent {
                        TextField("Account Holder Name", text: $userData.bankingInfo.accountName)
                            .autocorrectionDisabled()
                            .textContentType(.name)
                            .focused($focusedField, equals: .accountName)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .routingNumber
                            }
                        
                    } label: {
                        Text("Name on Account:").foregroundStyle(.secondary)
                    }
                    
                    // Routing Number - Format validation only
                    LabeledContent {
                        HStack {
                            TextField("123456789", text: $userData.bankingInfo.routingNumber)
                                .autocorrectionDisabled()
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .routingNumber)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .accountNumber
                                }
                                .onChange(of: userData.bankingInfo.routingNumber) { _, _ in
                                    formatRoutingNumber()
                                    validateRoutingField(userData.bankingInfo.routingNumber)
                                }
                                .onChange(of: focusedField) { _, newValue in
                                    if newValue == .routingNumber {
                                        routingHasBeenFocused = true
                                    }
                                }
                            
                            // Show validation feedback only if field has been focused and user moved on
                            if routingHasBeenFocused && focusedField != .routingNumber && routingValidationError != nil && !userData.bankingInfo.routingNumber.isEmpty {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                    } label: {
                        Text("Routing Number:").foregroundStyle(.secondary)
                    }
                    
                    // Account Number - Format validation only
                    LabeledContent {
                        HStack {
                            TextField("Account Number", text: $userData.bankingInfo.accountNumber)
                                .autocorrectionDisabled()
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .accountNumber)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .venmo
                                }
                                .onChange(of: userData.bankingInfo.accountNumber) { _, newValue in
                                    validateAccountField(newValue)
                                }
                                .onChange(of: focusedField) { _, newValue in
                                    if newValue == .accountNumber {
                                        accountHasBeenFocused = true
                                    }
                                }
                            
                            // Show validation feedback only if field has been focused and user moved on
                            if accountHasBeenFocused && focusedField != .accountNumber && accountValidationError != nil && !userData.bankingInfo.accountNumber.isEmpty {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                    } label: {
                        Text("Account Number:").foregroundStyle(.secondary)
                    }
                }
                
                Section(header: Text("Payment Apps"), 
                       footer: Text("Add your payment app usernames for alternative payment options.")) {
                    
                    // Venmo - Format validation only
                    LabeledContent {
                        HStack {
                            TextField("@username", text: $userData.bankingInfo.venmo)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .venmo)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .zelle
                                }
                                .onChange(of: userData.bankingInfo.venmo) { _, newValue in
                                    formatVenmoUsername()
                                    validateVenmoField(userData.bankingInfo.venmo)
                                }
                                .onChange(of: focusedField) { _, newValue in
                                    if newValue == .venmo {
                                        venmoHasBeenFocused = true
                                    }
                                }
                            
                            // Show validation feedback only if field has been focused and user moved on
                            if venmoHasBeenFocused && focusedField != .venmo && venmoValidationError != nil && !userData.bankingInfo.venmo.isEmpty {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                    } label: {
                        Text("Venmo:").foregroundStyle(.secondary)
                    }
                    
                    // Zelle - Format validation only (Last field)
                    LabeledContent {
                        HStack {
                            TextField("Phone or Email", text: $userData.bankingInfo.zelle)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .zelle)
                                .submitLabel(.done)
                                .onSubmit {
                                    focusedField = nil // Dismiss keyboard on last field
                                }
                                .onChange(of: userData.bankingInfo.zelle) { _, newValue in
                                    validateZelleField(newValue)
                                }
                                .onChange(of: focusedField) { _, newValue in
                                    if newValue == .zelle {
                                        zelleHasBeenFocused = true
                                    }
                                }
                            
                            // Show validation feedback only if field has been focused and user moved on
                            if zelleHasBeenFocused && focusedField != .zelle && zelleValidationError != nil && !userData.bankingInfo.zelle.isEmpty {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                    } label: {
                        Text("Zelle:").foregroundStyle(.secondary)
                    }
                }
                
                // Help Section
                Section("Information") {
                    Label("Banking information helps clients pay you directly", systemImage: "info.circle")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Label("Payment apps provide alternative payment options", systemImage: "creditcard")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .navigationTitle("Banking & Payments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Run all validations before attempting to close
                        validateAllFields()
                        
                        // If there are validation errors, show the summary banner
                        if hasValidationErrors {
                            withAnimation(.easeIn(duration: 0.3)) {
                                showValidationSummary = true
                            }
                            return
                        }
                        
                        // Close the view if validation passes
                        dismiss()
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .validationErrorAlert($validationState.currentError)
    }
}

#Preview {
    BankingInfoView(userData: UserData())
}

// MARK: - Real-time Validation Methods

extension BankingInfoView {
    /// Validates all fields and updates validation state
    private func validateAllFields() {
        validateRoutingField(userData.bankingInfo.routingNumber)
        validateAccountField(userData.bankingInfo.accountNumber)
        validateVenmoField(userData.bankingInfo.venmo)
        validateZelleField(userData.bankingInfo.zelle)
        checkAndHideValidationSummary()
    }
    
    /// Smoothly transitions focus to the next field to prevent keyboard flickering
    private func moveToNextField(_ nextField: BankingField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            focusedField = nextField
        }
    }
    
    /// Validates routing number format in real-time
    private func validateRoutingField(_ routingNumber: String) {
        // Clear error if field is empty (routing number is optional)
        guard !routingNumber.isEmpty else {
            routingValidationError = nil
            checkAndHideValidationSummary()
            return
        }
        
        // Use ValidationHelper to check routing number format
        if ValidationHelper.isValidRoutingNumber(routingNumber) {
            routingValidationError = nil
        } else {
            routingValidationError = "Must be exactly 9 digits"
        }
        checkAndHideValidationSummary()
    }
    
    /// Validates account number format in real-time
    private func validateAccountField(_ accountNumber: String) {
        // Clear error if field is empty (account number is optional)
        guard !accountNumber.isEmpty else {
            accountValidationError = nil
            checkAndHideValidationSummary()
            return
        }
        
        // Use ValidationHelper to check account number format
        if ValidationHelper.isValidAccountNumber(accountNumber) {
            accountValidationError = nil
        } else {
            accountValidationError = "Must be 4-20 digits"
        }
        checkAndHideValidationSummary()
    }
    
    /// Validates Venmo username format in real-time
    private func validateVenmoField(_ venmoUsername: String) {
        // Clear error if field is empty (Venmo is optional)
        guard !venmoUsername.isEmpty else {
            venmoValidationError = nil
            checkAndHideValidationSummary()
            return
        }
        
        // Use ValidationHelper to check Venmo username format
        if ValidationHelper.isValidVenmoUsername(venmoUsername) {
            venmoValidationError = nil
        } else {
            venmoValidationError = "Must start with @ and contain only letters, numbers, hyphens, and underscores"
        }
        checkAndHideValidationSummary()
    }
    
    /// Validates Zelle info format in real-time
    private func validateZelleField(_ zelleInfo: String) {
        // Clear error if field is empty (Zelle is optional)
        guard !zelleInfo.isEmpty else {
            zelleValidationError = nil
            checkAndHideValidationSummary()
            return
        }
        
        // Use ValidationHelper to check if it's a valid email or phone number
        if ValidationHelper.isValidZelleInfo(zelleInfo) {
            zelleValidationError = nil
        } else {
            zelleValidationError = "Must be a valid email address or phone number"
        }
        checkAndHideValidationSummary()
    }
    
    // MARK: - Input Formatting
    
    private func formatRoutingNumber() {
        // Keep only digits and limit to 9
        let digitsOnly = userData.bankingInfo.routingNumber.filter { $0.isNumber }
        userData.bankingInfo.routingNumber = String(digitsOnly.prefix(9))
    }
    
    private func formatVenmoUsername() {
        // Automatically add @ if user starts typing without it
        if !userData.bankingInfo.venmo.isEmpty && !userData.bankingInfo.venmo.hasPrefix("@") {
            userData.bankingInfo.venmo = "@" + userData.bankingInfo.venmo
        }
    }
}
