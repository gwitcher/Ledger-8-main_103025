//
//  ContactEditView.swift
//  Ledger 8
//
//  Created by Gabe Witcher on 4/22/25.
//

import SwiftUI
import SwiftData

struct ClientEditView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var client: Client
    
    // MARK: - Validation State
    @State private var validationState = FormValidationState()
    
    // MARK: - Real-time Validation States
    @State private var emailValidationError: String?
    @State private var phoneValidationError: String?
    @State private var nameValidationError: String?
    
    // MARK: - Focus-aware validation tracking
    @State private var emailHasBeenFocused = false
    @State private var phoneHasBeenFocused = false
    
    // MARK: - Validation Summary State
    @State private var showValidationSummary = false
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var attention = ""
    @State private var address = ""
    @State private var address2 = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zip = ""
    @State private var notes = ""
    @State private var company = ""
    
    @FocusState private var focusField: clientField?
    
    // MARK: - Scroll proxy for auto-scroll to banner
    @State private var scrollProxy: ScrollViewProxy?
    
    // MARK: - Computed Properties
    
    /// Checks if there are any real-time validation errors
    private var hasValidationErrors: Bool {
        return emailValidationError != nil || phoneValidationError != nil || nameValidationError != nil
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
        if let nameError = nameValidationError {
            errors.append(ValidationBannerError(fieldName: "Name or Company", message: nameError, icon: "person.fill"))
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
    
    /// Smoothly transitions focus to the next field to prevent keyboard flickering
    private func moveToNextField(_ nextField: clientField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            focusField = nextField
        }
    }
    
    /// Scrolls to the validation banner to ensure it's visible
    private func scrollToValidationBanner() {
        guard let scrollProxy = scrollProxy else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            scrollProxy.scrollTo("validationBanner", anchor: .top)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                Form {
                    ValidationSummaryBanner(
                        title: "Please check field formatting:",
                        validationErrors: currentValidationErrors,
                        isVisible: $showValidationSummary
                    )
                    .id("validationBanner")
                
                Section("Client Info") {
                    LabeledContent {
                        TextField("", text: $firstName)
                            .autocorrectionDisabled()
                            .textContentType(.name)
                            .focused($focusField, equals: .firstName)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.lastName)
                            }
                            .onChange(of: firstName) { _, _ in
                                validateNameFields()
                            }
                        
                    }   label: {
                        Text("First Name").foregroundStyle(.secondary)
                            
                    }
                    LabeledContent {
                        TextField("", text: $lastName)
                            .autocorrectionDisabled()
                            .textContentType(.name)
                            .focused($focusField, equals: .lastName)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.email)
                            }
                            .onChange(of: lastName) { _, _ in
                                validateNameFields()
                            }
                        
                    }   label: {
                        Text("Last Name").foregroundStyle(.secondary)
                            
                    }
                    
                    LabeledContent {
                        HStack {
                            TextField("", text: $email)
                                .autocorrectionDisabled()
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .focused($focusField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    moveToNextField(.phone)
                                }
                                .onChange(of: email) { _, newValue in
                                    validateEmailField(newValue)
                                }
                                .onChange(of: focusField) { _, newValue in
                                    // Track when email field has been focused
                                    if newValue == .email {
                                        emailHasBeenFocused = true
                                    }
                                }
                            
                            // Show validation feedback only if field has been focused and user moved on
                            if emailHasBeenFocused && focusField != .email && emailValidationError != nil && !email.isEmpty {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                    }   label: {
                        Text("Email").foregroundStyle(.secondary)
                            
                    }
                    
                    LabeledContent {
                        HStack {
                            TextField("", text: $phone)
                                .autocorrectionDisabled()
                                .textContentType(.telephoneNumber)
                                .focused($focusField, equals: .phone)
                                .submitLabel(.next)
                                .onSubmit {
                                    moveToNextField(.company)
                                }
                                .onChange(of: phone) { _, newValue in
                                    validatePhoneField(newValue)
                                }
                                .onChange(of: focusField) { _, newValue in
                                    // Track when phone field has been focused
                                    if newValue == .phone {
                                        phoneHasBeenFocused = true
                                    }
                                }
                            
                            // Show validation feedback only if field has been focused and user moved on
                            if phoneHasBeenFocused && focusField != .phone && phoneValidationError != nil && !phone.isEmpty {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }   label: {
                        Text("Phone").foregroundStyle(.secondary)
                            
                    }
                }
                
                Section("Company"){
                    LabeledContent {
                        TextField("", text: $company)
                            .autocorrectionDisabled()
                            .textContentType(.organizationName)
                            .focused($focusField, equals: .company)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.attn)
                            }
                            .onChange(of: company) { _, _ in
                                validateNameFields()
                            }
                    }   label: {
                        Text("Company").foregroundStyle(.secondary)
                            
                    }
                }
                
                
                Section("Billing Info") {
                    LabeledContent {
                        TextField("", text: $attention)
                            .autocorrectionDisabled()
                            .textContentType(.name)
                            .focused($focusField, equals: .attn)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.address)
                            }
                        
                    }   label: {
                        Text("Attn:").foregroundStyle(.secondary)
                            
                    }
                    LabeledContent {
                        TextField("", text: $address)
                            .autocorrectionDisabled()
                            .textContentType(.streetAddressLine1)
                            .focused($focusField, equals: .address)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.address2)
                            }
                        
                    }   label: {
                        Text("Address").foregroundStyle(.secondary)
                            
                    }
                    LabeledContent {
                        TextField("", text: $address2)
                            .autocorrectionDisabled()
                            .textContentType(.streetAddressLine2)
                            .focused($focusField, equals: .address2)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.city)
                            }
                        
                    }   label: {
                        Text("Address 2").foregroundStyle(.secondary)
                            
                    }
                    LabeledContent {
                        TextField("", text: $city)
                            .autocorrectionDisabled()
                            .textContentType(.addressCity)
                            .focused($focusField, equals: .city)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.state)
                            }
                        
                    }   label: {
                        Text("City").foregroundStyle(.secondary)
                            
                    }
                    LabeledContent {
                        TextField("", text: $state)
                            .autocorrectionDisabled()
                            .textContentType(.addressState)
                            .focused($focusField, equals: .state)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.zip)
                            }
                    }   label: {
                        Text("State").foregroundStyle(.secondary)
                            
                    }
                    LabeledContent {
                        TextField("", text: $zip)
                            .autocorrectionDisabled()
                            .textContentType(.postalCode)
                            .focused($focusField, equals: .zip)
                            .submitLabel(.next)
                            .onSubmit {
                                moveToNextField(.notes)
                            }
                        
                    }   label: {
                        Text("Zip").foregroundStyle(.secondary)
                            
                    }
                }
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                }
            }
            .onAppear {
                scrollProxy = proxy
                firstName = client.firstName
                lastName = client.lastName
                email = client.email
                phone = client.phone
                attention = client.attention
                address = client.address
                address2 = client.address2
                city = client.city
                state = client.state
                zip = client.zip
                notes = client.notes
                company = client.company
                
                // Run initial validation to set up error states
                validateEmailField(email)
                validatePhoneField(phone)
                validateNameFields()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", systemImage: "checkmark.circle.fill") {
                        // Run final validation
                        validateNameFields()
                        validateEmailField(email)
                        validatePhoneField(phone)
                        
                        // If there are validation errors, show the summary banner
                        if hasValidationErrors {
                            withAnimation(.easeIn(duration: 0.3)) {
                                showValidationSummary = true
                            }
                            // Auto-scroll to banner after animation completes and view has time to layout
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                scrollToValidationBanner()
                            }
                            return
                        }

                        if saveClient() {
                            dismiss()
                        }
                        // If saveClient() returns false, we stay on the form
                        // The validation alert will be shown via the .validationErrorAlert modifier
                    }
                    .disabled(hasValidationErrors)
                    .foregroundColor(hasValidationErrors ? .gray : .blue)
                }
            }
            .validationErrorAlert($validationState.currentError)
            }
        }
    }
    
    // MARK: - Real-time Validation Methods
    
    /// Validates email field in real-time using ValidationHelper
    private func validateEmailField(_ email: String) {
        // Clear error if field is empty (email is optional)
        guard !email.isEmpty else {
            emailValidationError = nil
            checkAndHideValidationSummary()
            return
        }
        
        // Use ValidationHelper to check email format
        if ValidationHelper.isValidEmail(email) {
            emailValidationError = nil
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
            checkAndHideValidationSummary()
            return
        }
        
        // Use ValidationHelper to check phone format
        if ValidationHelper.isValidPhoneNumber(phone) {
            phoneValidationError = nil
        } else {
            phoneValidationError = "Invalid phone number format"
        }
        checkAndHideValidationSummary()
    }
    
    /// Validates that at least name or company is provided
    private func validateNameFields() {
        let hasName = ValidationHelper.isNotEmpty(firstName) || ValidationHelper.isNotEmpty(lastName)
        let hasCompany = ValidationHelper.isNotEmpty(company)
        
        if !hasName && !hasCompany {
            nameValidationError = "Name or Company is required"
        } else {
            nameValidationError = nil
        }
        checkAndHideValidationSummary()
    }
    
    private func saveClient() -> Bool {
        // Create temporary client for validation
        let tempClient = Client(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            attention: attention,
            address: address,
            address2: address2,
            city: city,
            state: state,
            zip: zip,
            notes: notes,
            company: company
        )
        
        // Validate before saving
        validationState.validate(tempClient)
        
        if !validationState.isValid {
            ErrorHandler.handle(validationState.currentError ?? LedgerError.validationFailed("Unknown validation error"), context: "Client Edit")
            return false
        }
        
        // Update the existing client
        client.firstName = firstName
        client.lastName = lastName
        client.email = email
        client.phone = phone
        client.attention = attention
        client.address = address
        client.address2 = address2
        client.city = city
        client.state = state
        client.zip = zip
        client.notes = notes
        client.company = company
        
        do {
            try modelContext.save()
            ErrorHandler.logInfo("Client updated successfully", context: "Client Edit")
            return true
        } catch {
            ErrorHandler.handle(error, context: "Client Edit - SwiftData")
            validationState.currentError = LedgerError.dataCorruption
            return false
        }
    }
}

#Preview {
    ClientEditView(client: Client())
}
