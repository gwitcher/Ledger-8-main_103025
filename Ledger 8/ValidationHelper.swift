////
////  ValidationHelper.swift
////  Ledger 8
////
////  Created for P0 Critical Issue Resolution - Safe validation utilities
////
//
//import Foundation
//import SwiftData
//
///// Safe validation utilities to prevent crashes and ensure data integrity
//struct ValidationHelper {
//    
//    // MARK: - Email Validation
//    
//    /// Safely validates email format using NSPredicate
//    static func isValidEmail(_ email: String) -> Bool {
//        guard !email.isEmpty else { return false }
//        
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailPredicate.evaluate(with: email)
//    }
//    
//    // MARK: - Phone Number Validation
//    
//    /// Safely validates phone number format
//    static func isValidPhoneNumber(_ phone: String) -> Bool {
//        guard !phone.isEmpty else { return false }
//        
//        // Remove all non-digits for length check
//        let digitsOnly = phone.filter { $0.isNumber }
//        
//        // US phone numbers should have 10 digits
//        guard digitsOnly.count >= 10 else { return false }
//        
//        // Allow common formats: (123) 456-7890, 123-456-7890, 123.456.7890, 1234567890
//        let phoneRegEx = "^[\\+]?[1-9][\\d]{0,3}[\\s\\-\\(\\)]*[\\d\\s\\-\\(\\)]{7,15}$"
//        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
//        return phonePredicate.evaluate(with: phone)
//    }
//    
//    // MARK: - String Validation
//    
//    /// Safely checks if string is not empty after trimming whitespace
//    static func isNotEmpty(_ string: String) -> Bool {
//        return !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//    }
//    
//    /// Safely checks if at least one of the strings is not empty
//    static func atLeastOneNotEmpty(_ strings: String...) -> Bool {
//        return strings.contains { isNotEmpty($0) }
//    }
//    
//    // MARK: - Date Validation
//    
//    /// Safely validates date range
//    static func isValidDateRange(start: Date, end: Date) -> Bool {
//        return end > start
//    }
//    
//    /// Safely creates a date by adding time interval, with fallback
//    static func safeAddTimeInterval(_ date: Date, interval: TimeInterval) -> Date {
//        guard let newDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: date) else {
//            return date // Fallback to original date
//        }
//        return newDate
//    }
//    
//    // MARK: - Numeric Validation
//    
//    /// Safely validates that a fee is non-negative
//    static func isValidFee(_ fee: Double) -> Bool {
//        return fee >= 0.0 && fee.isFinite
//    }
//    
//    /// Safely validates invoice number is positive
//    static func isValidInvoiceNumber(_ number: Int) -> Bool {
//        return number > 0
//    }
//    
//    // MARK: - Array Safety
//    
//    /// Safely gets array count, returning 0 for nil arrays
//    static func safeCount<T>(_ array: [T]?) -> Int {
//        return array?.count ?? 0
//    }
//    
//    /// Safely computes sum of fees from optional array of objects with fee property
//    static func safeFeeSum<T>(_ items: [T]?, keyPath: KeyPath<T, Double>) -> Double {
//        return items?.reduce(0.0) { $0 + $1[keyPath: keyPath] } ?? 0.0
//    }
//    
//    /// Safely gets maximum value from optional array
//    static func safeMaxValue<T: Comparable>(_ array: [T]?) -> T? {
//        return array?.max()
//    }
//}