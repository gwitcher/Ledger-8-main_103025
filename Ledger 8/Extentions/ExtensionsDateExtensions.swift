//
//  ExtensionsDateExtensions.swift
//  Ledger 8
//
//  Created for Phase 0 completion - Date utility methods
//  Date: October 31, 2025
//

import Foundation

// MARK: - Date Extensions
extension Date {
    
    /// Safely adds hours to a date
    func adding(hours: Int) -> Date {
        return ValidationHelper.safeAddTimeInterval(self, interval: TimeInterval(hours * 3600))
    }
    
    /// Safely adds minutes to a date
    func adding(minutes: Int) -> Date {
        return ValidationHelper.safeAddTimeInterval(self, interval: TimeInterval(minutes * 60))
    }
    
    /// Safe date formatter for display
    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Calendar Extensions
extension Calendar {
    
    /// Safe alternative to Calendar.current.date(bySettingHour:minute:second:of:)
    /// Returns original date if operation fails
    func safeDateBySettingTime(hour: Int, minute: Int, second: Int, of date: Date) -> Date {
        guard let newDate = self.date(bySettingHour: hour, minute: minute, second: second, of: date) else {
            return date // Fallback to original date
        }
        return newDate
    }
}