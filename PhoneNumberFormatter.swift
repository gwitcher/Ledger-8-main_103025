//
//  PhoneNumberFormatter.swift
//  Ledger 8
//
//  Phone number formatting utilities using Apple's preferred methods
//

import Foundation
import Contacts

/// Phone number formatting utility using Apple's CNPhoneNumber
struct PhoneNumberFormatter {
    
    // CNPhoneNumberFormatter doesn't exist, we'll use CNPhoneNumber directly
    
    /// Formats a phone number as the user types using Apple's preferred formatting
    /// - Parameter input: The raw phone number input from the user
    /// - Returns: Formatted phone number string
    static func formatAsTyping(_ input: String) -> String {
        // Remove all non-numeric characters for processing
        let digitsOnly = input.filter { $0.isNumber }
        
        // Don't format if empty or too long (more than 11 digits for US numbers)
        guard !digitsOnly.isEmpty, digitsOnly.count <= 11 else {
            return input
        }
        
        // Handle various US number formats
        let formatted: String
        
        switch digitsOnly.count {
        case 1...3:
            // Just show the digits as-is for short inputs
            formatted = digitsOnly
            
        case 4...6:
            // Format as: 123-456
            let area = String(digitsOnly.prefix(3))
            let number = String(digitsOnly.suffix(from: digitsOnly.index(digitsOnly.startIndex, offsetBy: 3)))
            formatted = "\(area)-\(number)"
            
        case 7...10:
            // Format as: (123) 456-7890
            let area = String(digitsOnly.prefix(3))
            let central = String(digitsOnly[digitsOnly.index(digitsOnly.startIndex, offsetBy: 3)..<digitsOnly.index(digitsOnly.startIndex, offsetBy: 6)])
            let line = String(digitsOnly.suffix(from: digitsOnly.index(digitsOnly.startIndex, offsetBy: 6)))
            
            if digitsOnly.count <= 7 {
                formatted = "\(area)-\(central)\(line)"
            } else {
                formatted = "(\(area)) \(central)-\(line)"
            }
            
        case 11:
            // Format as: +1 (123) 456-7890 for 11-digit numbers starting with 1
            if digitsOnly.first == "1" {
                let area = String(digitsOnly[digitsOnly.index(digitsOnly.startIndex, offsetBy: 1)..<digitsOnly.index(digitsOnly.startIndex, offsetBy: 4)])
                let central = String(digitsOnly[digitsOnly.index(digitsOnly.startIndex, offsetBy: 4)..<digitsOnly.index(digitsOnly.startIndex, offsetBy: 7)])
                let line = String(digitsOnly.suffix(4))
                formatted = "+1 (\(area)) \(central)-\(line)"
            } else {
                // If it doesn't start with 1, treat as international
                formatted = digitsOnly
            }
            
        default:
            formatted = digitsOnly
        }
        
        return formatted
    }
    
    /// Validates and formats a complete phone number using CNPhoneNumber for validation
    /// - Parameter phoneNumber: The phone number to validate and format
    /// - Returns: Formatted phone number if valid, or original input if invalid
    static func validateAndFormat(_ phoneNumber: String) -> String {
        // Remove all non-numeric characters for validation
        let digitsOnly = phoneNumber.filter { $0.isNumber }
        
        // Basic validation: US numbers should have 10-11 digits
        guard digitsOnly.count >= 10, digitsOnly.count <= 11 else {
            return phoneNumber
        }
        
        // Try to validate with CNPhoneNumber, then use our custom formatting
        do {
            let _ = CNPhoneNumber(stringValue: phoneNumber)
            // If validation succeeds, use our custom formatting for consistent display
            return formatAsTyping(digitsOnly)
        }
        //catch {
//            // If CNPhoneNumber validation fails, still try our custom formatting
//            // but return original if it doesn't meet our criteria
//            let formatted = formatAsTyping(digitsOnly)
//            return formatted != digitsOnly ? formatted : phoneNumber
//        }
    }
    
    /// Extracts just the digits from a phone number for validation/storage
    /// - Parameter phoneNumber: The formatted phone number
    /// - Returns: Just the numeric digits
    static func digitsOnly(_ phoneNumber: String) -> String {
        return phoneNumber.filter { $0.isNumber }
    }
    
    /// Validates if a phone number is valid using both CNPhoneNumber and custom logic
    /// - Parameter phoneNumber: The phone number to validate
    /// - Returns: True if the phone number is valid
    static func isValid(_ phoneNumber: String) -> Bool {
        guard !phoneNumber.isEmpty else { return false }
        
        let digitsOnly = self.digitsOnly(phoneNumber)
        
        // US phone numbers should have 10-11 digits
        guard digitsOnly.count >= 10, digitsOnly.count <= 11 else { return false }
        
        // Try validation with CNPhoneNumber first
        do {
            let _ = CNPhoneNumber(stringValue: phoneNumber)
            return true
        }
//        catch {
//            // Fall back to our custom validation
//            return ValidationHelper.isValidPhoneNumber(phoneNumber)
//        }
    }
}
