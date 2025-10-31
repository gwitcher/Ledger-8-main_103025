//
//  LedgerError.swift
//  Ledger 8
//
//  Created for Phase 0 - Critical Foundation fixes
//

import Foundation

// MARK: - Validation Protocol
protocol Validatable {
    func validate() throws
}

// MARK: - Centralized Error Handling
enum LedgerError: LocalizedError {
    case dataCorruption
    case invalidDateConfiguration
    case fileNotFound
    case invalidProjectData
    case calculationError
    case validationFailed(String)
    case unexpectedNilValue(String)
    case invalidDateRange
    case emptyRequiredField(String)
    case invalidEmailFormat
    case invalidPhoneFormat
    
    var errorDescription: String? {
        switch self {
        case .dataCorruption:
            return "Data appears to be corrupted. Please try again or contact support."
        case .invalidDateConfiguration:
            return "Unable to configure dates properly. Using current time instead."
        case .fileNotFound:
            return "The requested file could not be found."
        case .invalidProjectData:
            return "Project data is incomplete or invalid."
        case .calculationError:
            return "An error occurred during calculation."
        case .validationFailed(let message):
            return "Validation failed: \(message)"
        case .unexpectedNilValue(let context):
            return "Unexpected missing data in \(context)."
        case .invalidDateRange:
            return "End date must be after start date."
        case .emptyRequiredField(let field):
            return "\(field) is required and cannot be empty."
        case .invalidEmailFormat:
            return "Please enter a valid email address."
        case .invalidPhoneFormat:
            return "Please enter a valid phone number."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .dataCorruption:
            return "Try refreshing the data or restarting the app."
        case .invalidDateConfiguration:
            return "Check your system date settings and try again."
        case .fileNotFound:
            return "Verify the file exists and try again."
        case .invalidProjectData:
            return "Check all required project fields are filled in."
        case .calculationError:
            return "Verify all numerical values are valid."
        case .validationFailed:
            return "Please correct the highlighted fields and try again."
        case .unexpectedNilValue:
            return "Please ensure all required data is provided."
        case .invalidDateRange:
            return "Please adjust the dates so the end date is after the start date."
        case .emptyRequiredField:
            return "Please fill in the required field."
        case .invalidEmailFormat, .invalidPhoneFormat:
            return "Please check the format and try again."
        }
    }
}

// MARK: - Validation Utilities
struct ValidationHelper {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func isValidPhoneNumber(_ phone: String) -> Bool {
        // Simple phone validation - at least 10 digits
        let cleanPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return cleanPhone.count >= 10
    }
    
    static func isNotEmpty(_ value: String) -> Bool {
        return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Error Handling Utilities
struct ErrorHandler {
    static func handle(_ error: Error, context: String = "") {
        print("⚠️ Error in \(context): \(error.localizedDescription)")
    }
    
    static func logWarning(_ message: String, context: String = "") {
        print("⚠️ Warning in \(context): \(message)")
    }
    
    static func logInfo(_ message: String, context: String = "") {
        print("ℹ️ Info in \(context): \(message)")
    }
}

// MARK: - Safe Value Providers
extension Calendar {
    /// Safe date creation that falls back to current date if the configuration fails
    static func safeDateBySettingTime(hour: Int, minute: Int, second: Int = 0, of date: Date = Date()) -> Date {
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: date) ?? date
    }
}

extension Optional where Wrapped == [Any] {
    /// Safe count for optional arrays
    var safeCount: Int {
        return self?.count ?? 0
    }
}