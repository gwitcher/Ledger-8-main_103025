//  ProjectValidationViewModel.swift
//  Ledger 8
//
//  Created: October 31, 2025
//  Purpose: Centralized validation state management for ProjectDetailView
//  Risk Level: LOW - Observable state with clean interfaces

import Foundation
import Observation

/// Centralized validation state management that eliminates coupling issues
/// Replaces 13 scattered validation state variables with single source of truth
@Observable
class ProjectValidationViewModel {
    
    // MARK: - Single Source of Truth State
    
    /// Dictionary of current validation errors by field
    /// Replaces: projectNameValidationError, artistValidationError, dateRangeValidationError, clientValidationError
    private(set) var validationErrors: [ProjectField: String] = [:]
    
    /// Set of fields that have been focused (touched by user)
    /// Replaces: projectNameHasBeenFocused, artistHasBeenFocused
    private(set) var focusedFields: Set<ProjectField> = []
    
    /// Set of fields that should show validation triangles (action-triggered)
    /// Replaces: showProjectNameTriangle, showArtistTriangle, showClientTriangle
    private(set) var actionTriggeredFields: Set<ProjectField> = []
    
    /// Whether validation summary banner should be shown
    /// Replaces: showValidationSummary + complex logic
    private(set) var shouldShowValidationSummary: Bool = false
    
    /// Tracks whether form has been submitted (action triggered)
    private(set) var formSubmissionAttempted: Bool = false
    
    // MARK: - Computed Properties (Clean Dependencies)
    
    /// Whether the form has any validation errors
    /// Replaces complex hasValidationErrors computed property
    var hasErrors: Bool {
        !validationErrors.isEmpty
    }
    
    /// Whether form is valid and ready for submission
    var isFormValid: Bool {
        validationErrors.isEmpty
    }
    
    /// Current validation errors formatted for ValidationSummaryBanner
    /// Replaces complex currentValidationErrors array building
    var summaryErrors: [ValidationBannerError] {
        return validationErrors.compactMap { (field, message) in
            switch field {
            case .project:
                return .projectName(message)
            case .artist:
                return .artist(message)
            case .startDate:
                return .dateRange(message) // Start date errors show as date range issues
            case .endDate:
                return .dateRange(message) // End date errors show as date range issues
            case .client:
                return .client(message)
            case .notes:
                return nil // Notes field doesn't have validation errors to display
            }
        }
    }
    
    /// Whether validation summary should be visible based on state
    var shouldShowSummary: Bool {
        return hasErrors && formSubmissionAttempted
    }
    
    // MARK: - Validation Methods (Clean Interface)
    
    /// Validates a single field using pure validation functions
    /// - Parameters:
    ///   - field: The field to validate
    ///   - value: The value to validate (Any type for flexibility)
    /// - Returns: Whether validation passed
    @discardableResult
    func validateField<T>(_ field: ProjectField, value: T) -> Bool {
        let result: ProjectFormValidator.ValidationResult
        
        // Use pure validation functions based on field type
        switch field {
        case .project:
            result = ProjectFormValidator.validateProjectName(value as? String ?? "")
            
        case .artist:
            result = ProjectFormValidator.validateArtist(value as? String ?? "")
            
        case .client:
            // Handle optional client types correctly
            if let clientValue = value as? String {
                // Non-nil string client
                result = ProjectFormValidator.validateClient(clientValue)
            } else if value is String? {
                // Explicitly nil string client
                result = ProjectFormValidator.validateClient(nil as String?)
            } else {
                // Other types - pass through directly
                result = ProjectFormValidator.validateClient(value)
            }
            
        case .startDate:
            // Individual start date validation (currently always valid)
            result = .valid
            
        case .endDate:
            // For end date, expect tuple of (startDate, endDate) for range validation
            if let dates = value as? (Date, Date) {
                result = ProjectFormValidator.validateDateRange(start: dates.0, end: dates.1)
            } else {
                result = .invalid("Invalid date range")
            }
            
        case .notes:
            // Notes field doesn't have validation rules
            result = .valid
        }
        
        // Update state based on validation result
        updateValidationState(for: field, result: result)
        
        return result.isValid
    }
    
    /// Validates all form fields at once
    /// - Parameters:
    ///   - projectName: Project name to validate
    ///   - artist: Artist name to validate
    ///   - startDate: Project start date
    ///   - endDate: Project end date
    ///   - client: Selected client
    /// - Returns: Whether all fields are valid
    @discardableResult
    func validateAllFields<ClientType>(
        projectName: String,
        artist: String,
        startDate: Date,
        endDate: Date,
        client: ClientType?
    ) -> Bool {
        
        // Use pure validation function for comprehensive validation
        let results = ProjectFormValidator.validateAllFields(
            projectName: projectName,
            artist: artist,
            startDate: startDate,
            endDate: endDate,
            client: client
        )
        
        // Update all validation states
        updateAllValidationStates(results: results)
        
        return ProjectFormValidator.isFormValid(results)
    }
    
    // MARK: - Focus Management
    
    // Add a lock for thread safety
    private let focusLock = NSLock()
    
    /// Marks a field as having been focused (touched by user)
    /// - Parameter field: The field that was focused
    func markFieldAsFocused(_ field: ProjectField) {
        focusLock.lock()
        defer { focusLock.unlock() }
        focusedFields.insert(field)
    }
    
    /// Checks if a field has been focused
    /// - Parameter field: The field to check
    /// - Returns: Whether the field has been focused
    func hasBeenFocused(_ field: ProjectField) -> Bool {
        focusLock.lock()
        defer { focusLock.unlock() }
        return focusedFields.contains(field)
    }
    
    // MARK: - Action-Triggered Validation (Form Submission)
    
    /// Triggers form-level validation (when save button is pressed)
    /// This will show validation triangles and summary banner for any errors
    /// - Parameters: Same as validateAllFields
    /// - Returns: Whether form is valid for submission
    @discardableResult
    func triggerFormValidation<ClientType>(
        projectName: String,
        artist: String,
        startDate: Date,
        endDate: Date,
        client: ClientType?
    ) -> Bool {
        
        // Mark that form submission was attempted
        formSubmissionAttempted = true
        
        // Validate all fields
        let isValid = validateAllFields(
            projectName: projectName,
            artist: artist,
            startDate: startDate,
            endDate: endDate,
            client: client
        )
        
        // Show triangles for all invalid fields when form submission attempted
        actionTriggeredFields = Set(validationErrors.keys)
        
        // Update summary visibility
        shouldShowValidationSummary = shouldShowSummary
        
        return isValid
    }
    
    /// Checks if a field should show the validation triangle
    /// - Parameter field: The field to check
    /// - Returns: Whether to show triangle for this field
    func shouldShowTriangle(for field: ProjectField) -> Bool {
        return actionTriggeredFields.contains(field) && validationErrors.keys.contains(field)
    }
    
    // MARK: - State Management (Internal)
    
    /// Updates validation state for a single field
    /// - Parameters:
    ///   - field: The field being updated
    ///   - result: The validation result
    private func updateValidationState(for field: ProjectField, result: ProjectFormValidator.ValidationResult) {
        if result.isValid {
            // Clear error if validation passes
            validationErrors.removeValue(forKey: field)
            actionTriggeredFields.remove(field) // Remove triangle when error resolved
        } else if let errorMessage = result.errorMessage {
            // Set error if validation fails
            validationErrors[field] = errorMessage
        }
        
        // Update summary visibility based on current state
        updateSummaryVisibility()
    }
    
    /// Updates validation states for all fields
    /// - Parameter results: Dictionary of validation results
    private func updateAllValidationStates(results: [ProjectField: ProjectFormValidator.ValidationResult]) {
        // Clear existing errors
        validationErrors.removeAll()
        
        // Extract and store new errors
        validationErrors = ProjectFormValidator.extractErrors(results)
        
        // Update summary visibility
        updateSummaryVisibility()
    }
    
    /// Updates summary visibility based on current state
    private func updateSummaryVisibility() {
        shouldShowValidationSummary = shouldShowSummary
    }
    
    // MARK: - Clear/Reset Methods
    
    /// Clears all validation state (for form reset or successful submission)
    func clearAllValidation() {
        validationErrors.removeAll()
        focusedFields.removeAll()
        actionTriggeredFields.removeAll()
        shouldShowValidationSummary = false
        formSubmissionAttempted = false
    }
    
    /// Clears validation for a specific field
    /// - Parameter field: The field to clear validation for
    func clearValidation(for field: ProjectField) {
        validationErrors.removeValue(forKey: field)
        actionTriggeredFields.remove(field)
        updateSummaryVisibility()
    }
    
    /// Hides the validation summary banner (when user dismisses it)
    func hideValidationSummary() {
        shouldShowValidationSummary = false
    }
}

// MARK: - ValidationBannerError Mapping

extension ProjectValidationViewModel {
    /// Maps current validation errors to ValidationBannerError cases
    /// This maintains compatibility with existing ValidationSummaryBanner
    func getCurrentValidationBannerErrors() -> [ValidationBannerError] {
        return summaryErrors
    }
}