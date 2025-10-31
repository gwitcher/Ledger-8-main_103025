//
//  CompanyInfoView.swift
//  Ledger 8
//
//  Created by Gabe Witcher on 5/10/25.
//

import SwiftUI

struct CompanyInfoView: View {
    
    @AppStorage("userData") var userData = UserData()
    @State private var validationState = FormValidationState()
    @FocusState private var focusedField: CompanyField?
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Real-time Validation States
    @State private var emailValidationError: String?
    @State private var phoneValidationError: String?
    
    // MARK: - Focus-aware validation tracking
    @State private var emailHasBeenFocused = false
    @State private var phoneHasBeenFocused = false
    
    // MARK: - Action-triggered validation indicators
    @State private var showEmailTriangle = false
    @State private var showPhoneTriangle = false
    
    // MARK: - Validation Summary State
    @State private var showValidationSummary = false
    
    // MARK: - Computed Properties
    
    /// Checks if there are any real-time validation errors
    private var hasValidationErrors: Bool {
        return emailValidationError != nil || phoneValidationError != nil
    }
    
    /// Current validation errors for display in banner
    private var currentValidationErrors: [ValidationBannerError] {
        var errors: [ValidationBannerError] = []
        
        if let emailError = emailValidationError {
            errors.append(.email(emailError))
        }
        if let phoneError = phoneValidationError {
            errors.append(.phone(phoneError))
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
                
                Section("Company Info"){
                    // Company Name - Optional
                    LabeledContent {
                        TextField("Company Name", text: $userData.company.name)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .companyName)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.contact)
                            }
                        
                    } label: {
                        Text("Company:").foregroundStyle(.secondary)
                    }
                    
                    // Contact Person - Optional
                    LabeledContent {
                        TextField("Contact Person", text: $userData.company.contact)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .contact)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.email)
                            }
                        
                    } label: {
                        Text("Contact:").foregroundStyle(.secondary)
                    }
                    
                    // Email - Format validation only
                    LabeledContent {
                        HStack {
                            TextField("company@example.com", text: $userData.company.email)
                                .autocorrectionDisabled()
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    moveToNextField(.phone)
                                }
                                .onChange(of: userData.company.email) { _, newValue in
                                    validateEmailField(newValue)
                                }
                                .onChange(of: focusedField) { _, newValue in
                                    if newValue == .email {
                                        emailHasBeenFocused = true
                                    }
                                }
                            
                            // Show validation triangle if triggered by action button or if field was focused and has error
                            if showEmailTriangle || (emailHasBeenFocused && focusedField != .email && emailValidationError != nil && !userData.company.email.isEmpty) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                    } label: {
                        Text("Email:").foregroundStyle(.secondary)
                    }
                    
                    // Phone - Format validation only
                    LabeledContent {
                        HStack {
                            TextField("(555) 123-4567", text: $userData.company.phone)
                                .autocorrectionDisabled()
                                .keyboardType(.numbersAndPunctuation)
                                .textContentType(.telephoneNumber)
                                .focused($focusedField, equals: .phone)
                                .submitLabel(.next)
                                .onSubmit {
                                    moveToNextField(.address)
                                }
                                .onChange(of: userData.company.phone) { _, newValue in
                                    validatePhoneField(newValue)
                                }
                                .onChange(of: focusedField) { _, newValue in
                                    if newValue == .phone {
                                        phoneHasBeenFocused = true
                                    }
                                }
                            
                            // Show validation triangle if triggered by action button or if field was focused and has error
                            if showPhoneTriangle || (phoneHasBeenFocused && focusedField != .phone && phoneValidationError != nil && !userData.company.phone.isEmpty) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                    } label: {
                        Text("Phone:").foregroundStyle(.secondary)
                    }
                }
                
                Section("Address") {
                    // Street Address - Optional
                    LabeledContent {
                        TextField("123 Main Street", text: $userData.company.address)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .address)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.address2)
                            }
                        
                    } label: {
                        Text("Address:").foregroundStyle(.secondary)
                    }
                    
                    // Address Line 2 - Optional
                    LabeledContent {
                        TextField("Apt, Suite, etc. (optional)", text: $userData.company.address2)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .address2)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.city)
                            }
                        
                    } label: {
                        Text("Address 2:").foregroundStyle(.secondary)
                    }
                    
                    // City - Optional
                    LabeledContent {
                        TextField("City", text: $userData.company.city)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .city)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.state)
                            }
                        
                    } label: {
                        Text("City:").foregroundStyle(.secondary)
                    }
                    
                    // State - Optional
                    LabeledContent {
                        TextField("State", text: $userData.company.state)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .state)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.zip)
                            }
                        
                    } label: {
                        Text("State:").foregroundStyle(.secondary)
                    }
                    
                    // ZIP Code - Optional (Last field)
                    LabeledContent {
                        TextField("ZIP Code", text: $userData.company.zip)
                            .autocorrectionDisabled()
                            .keyboardType(.numbersAndPunctuation)
                            .focused($focusedField, equals: .zip)
                            .submitLabel(.done)
                            .onSubmit {
                                focusedField = nil // Dismiss keyboard on last field
                            }
                        
                    } label: {
                        Text("ZIP:").foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Company Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Run all validations before attempting to close
                        validateAllFields()
                        
                        // If there are validation errors, show the summary banner and triangles
                        if hasValidationErrors {
                            // Show triangles for fields with errors
                            if emailValidationError != nil {
                                showEmailTriangle = true
                            }
                            if phoneValidationError != nil {
                                showPhoneTriangle = true
                            }
                            
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
    CompanyInfoView(userData: UserData())
}

// MARK: - Real-time Validation Methods

extension CompanyInfoView {
    /// Validates all fields and updates validation state
    private func validateAllFields() {
        validateEmailField(userData.company.email)
        validatePhoneField(userData.company.phone)
        checkAndHideValidationSummary()
    }
    
    /// Smoothly transitions focus to the next field to prevent keyboard flickering
    private func moveToNextField(_ nextField: CompanyField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            focusedField = nextField
        }
    }
    
    /// Validates email field in real-time using ValidationHelper
    private func validateEmailField(_ email: String) {
        // Clear error if field is empty (email is optional)
        guard !email.isEmpty else {
            emailValidationError = nil
            showEmailTriangle = false
            checkAndHideValidationSummary()
            return
        }
        
        // Use ValidationHelper to check email format
        if ValidationHelper.isValidEmail(email) {
            emailValidationError = nil
            showEmailTriangle = false
        } else {
            emailValidationError = "Invalid email format"
        }
        checkAndHideValidationSummary()
    }
    
    /// Validates phone field in real-time using ValidationHelper
    private func validatePhoneField(_ phone: String) {
        // Clear error if field is empty (phone is optional)
        guard !phone.isEmpty else {
            phoneValidationError = nil
            showPhoneTriangle = false
            checkAndHideValidationSummary()
            return
        }
        
        // Use ValidationHelper to check phone format
        if ValidationHelper.isValidPhoneNumber(phone) {
            phoneValidationError = nil
            showPhoneTriangle = false
        } else {
            phoneValidationError = "Invalid phone number format"
        }
        checkAndHideValidationSummary()
    }
}
