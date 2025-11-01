//  ProjectFormValidator.swift
//  Ledger 8
//
//  Created: October 31, 2025
//  Purpose: Pure validation functions for ProjectDetailView refactoring
//  Risk Level: ZERO - Pure functions with no side effects

import Foundation

/// Pure validation functions for project form fields
/// These functions have no side effects and are easily testable
struct ProjectFormValidator {
    
    // MARK: - Validation Result Type
    
    /// Result of a validation operation with optional error message
    struct ValidationResult {
        let isValid: Bool
        let errorMessage: String?
        
        static let valid = ValidationResult(isValid: true, errorMessage: nil)
        
        static func invalid(_ message: String) -> ValidationResult {
            return ValidationResult(isValid: false, errorMessage: message)
        }
    }
    
    // MARK: - Project Name Validation
    
    /// Validates project name with business rules for musician gig tracking
    /// - Parameter name: The project name to validate
    /// - Returns: ValidationResult indicating success or failure with message
    static func validateProjectName(_ name: String) -> ValidationResult {
        // Project name is required for musicians' gig tracking
        guard ValidationHelper.isNotEmpty(name) else {
            return .invalid("Project name is required")
        }
        
        // Additional business rules can be added here
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 1 else {
            return .invalid("Project name cannot be just whitespace")
        }
        
        // Optional: Check for reasonable length
        guard trimmed.count <= 100 else {
            return .invalid("Project name cannot exceed 100 characters")
        }
        
        return .valid
    }
    
    // MARK: - Artist Field Validation
    
    /// Validates artist field - completely optional but must not be only whitespace if provided
    /// - Parameter artist: The artist name to validate
    /// - Returns: ValidationResult indicating success or failure with message
    static func validateArtist(_ artist: String) -> ValidationResult {
        // Artist field is completely optional - empty is fine
        if artist.isEmpty {
            return .valid
        }
        
        // If provided, ensure it's not just whitespace
        let trimmed = artist.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .invalid("Artist name cannot be just whitespace")
        }
        
        // Optional: Check for reasonable length
        guard trimmed.count <= 100 else {
            return .invalid("Artist name cannot exceed 100 characters")
        }
        
        return .valid
    }
    
    // MARK: - Date Range Validation
    
    /// Validates that end date is after start date
    /// - Parameters:
    ///   - startDate: The project start date
    ///   - endDate: The project end date
    /// - Returns: ValidationResult indicating success or failure with message
    static func validateDateRange(start startDate: Date, end endDate: Date) -> ValidationResult {
        guard ValidationHelper.isValidDateRange(start: startDate, end: endDate) else {
            return .invalid("End date must be after start date")
        }
        
        // Optional: Check for reasonable date range (not too long)
        guard ValidationHelper.isReasonableDateRange(start: startDate, end: endDate) else {
            return .invalid("Project duration cannot exceed 2 years")
        }
        
        return .valid
    }
    
    // MARK: - Client Selection Validation
    
    /// Validates that a client is selected for professional gig tracking
    /// - Parameter client: The selected client (can be nil)
    /// - Returns: ValidationResult indicating success or failure with message
    static func validateClient<T>(_ client: T?) -> ValidationResult {
        // Client is required for professional gig tracking and invoicing
        guard client != nil else {
            return .invalid("Client selection is required")
        }
        
        return .valid
    }
    
    // MARK: - Form-Level Validation
    
    /// Validates all form fields at once and returns all validation results
    /// - Parameters:
    ///   - projectName: Project name to validate
    ///   - artist: Artist name to validate
    ///   - startDate: Project start date
    ///   - endDate: Project end date
    ///   - client: Selected client
    /// - Returns: Dictionary of field validation results
    static func validateAllFields<ClientType>(
        projectName: String,
        artist: String,
        startDate: Date,
        endDate: Date,
        client: ClientType?
    ) -> [ProjectField: ValidationResult] {
        
        return [
            .project: validateProjectName(projectName),
            .artist: validateArtist(artist),
            .startDate: .valid, // Individual date validation can be added if needed
            .endDate: validateDateRange(start: startDate, end: endDate), // Date range validation on endDate
            .client: validateClient(client)
        ]
    }
    
    // MARK: - Convenience Methods
    
    /// Checks if all validation results are valid
    /// - Parameter results: Dictionary of validation results
    /// - Returns: True if all fields are valid, false otherwise
    static func isFormValid(_ results: [ProjectField: ValidationResult]) -> Bool {
        return results.values.allSatisfy { $0.isValid }
    }
    
    /// Extracts error messages from validation results
    /// - Parameter results: Dictionary of validation results
    /// - Returns: Dictionary of field error messages (only for invalid fields)
    static func extractErrors(_ results: [ProjectField: ValidationResult]) -> [ProjectField: String] {
        return results.compactMapValues { result in
            result.isValid ? nil : result.errorMessage
        }
    }
    
    /// Gets a summary of validation errors for display purposes
    /// - Parameter results: Dictionary of validation results
    /// - Returns: Array of error messages for invalid fields
    static func getErrorSummary(_ results: [ProjectField: ValidationResult]) -> [String] {
        return results.compactMap { (field, result) in
            guard !result.isValid, let message = result.errorMessage else { return nil }
            return message
        }
    }
}

// MARK: - ProjectField Extension for Validation

extension ProjectField {
    /// Human-readable field name for error messages
    var displayName: String {
        switch self {
        case .project: return "Project Name"
        case .artist: return "Artist"
        case .startDate: return "Start Date"
        case .endDate: return "End Date" 
        case .client: return "Client"
        case .notes: return "Notes"
        }
    }
}