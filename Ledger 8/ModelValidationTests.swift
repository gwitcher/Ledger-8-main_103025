//
//  ModelValidationTests.swift
//  Ledger 8 Tests
//
//  Created for Phase 0 - Critical Foundation fixes
//

import Testing
@testable import Ledger_8
import SwiftData

// MARK: - Project Model Validation Tests
@Suite("Project Model Validation Tests")
struct ProjectValidationTests {
    
    @Test("Valid project passes validation")
    func validProject() async throws {
        let project = Project(
            projectName: "Film Score",
            artist: "John Composer",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600) // 1 hour later
        )
        
        // Should not throw
        try project.validate()
    }
    
    @Test("Empty project name fails validation")
    func emptyProjectName() async throws {
        let project = Project(
            projectName: "",
            artist: "John Composer",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600)
        )
        
        #expect(throws: LedgerError.self) {
            try project.validate()
        }
    }
    
    @Test("Whitespace-only project name fails validation")
    func whitespaceProjectName() async throws {
        let project = Project(
            projectName: "   ",
            artist: "John Composer",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600)
        )
        
        #expect(throws: LedgerError.self) {
            try project.validate()
        }
    }
    
    @Test("Empty artist name fails validation")
    func emptyArtistName() async throws {
        let project = Project(
            projectName: "Film Score",
            artist: "",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600)
        )
        
        #expect(throws: LedgerError.self) {
            try project.validate()
        }
    }
    
    @Test("End date before start date fails validation")
    func endDateBeforeStartDate() async throws {
        let now = Date()
        let project = Project(
            projectName: "Film Score",
            artist: "John Composer",
            startDate: now,
            endDate: now.addingTimeInterval(-3600) // 1 hour before
        )
        
        #expect(throws: LedgerError.self) {
            try project.validate()
        }
    }
    
    @Test("End date equal to start date fails validation")
    func endDateEqualToStartDate() async throws {
        let now = Date()
        let project = Project(
            projectName: "Film Score",
            artist: "John Composer",
            startDate: now,
            endDate: now // Same time
        )
        
        #expect(throws: LedgerError.self) {
            try project.validate()
        }
    }
}

// MARK: - Client Model Validation Tests
@Suite("Client Model Validation Tests")
struct ClientValidationTests {
    
    @Test("Valid client with name passes validation")
    func validClientWithName() async throws {
        let client = Client(
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "1234567890"
        )
        
        // Should not throw
        try client.validate()
    }
    
    @Test("Valid client with company passes validation")
    func validClientWithCompany() async throws {
        let client = Client(
            firstName: "",
            lastName: "",
            email: "info@company.com",
            phone: "1234567890",
            company: "ABC Studios"
        )
        
        // Should not throw
        try client.validate()
    }
    
    @Test("Client with no name or company fails validation")
    func clientWithNoNameOrCompany() async throws {
        let client = Client(
            firstName: "",
            lastName: "",
            email: "test@example.com",
            company: ""
        )
        
        #expect(throws: LedgerError.self) {
            try client.validate()
        }
    }
    
    @Test("Client with whitespace-only names fails validation")
    func clientWithWhitespaceNames() async throws {
        let client = Client(
            firstName: "   ",
            lastName: "   ",
            email: "test@example.com",
            company: "   "
        )
        
        #expect(throws: LedgerError.self) {
            try client.validate()
        }
    }
    
    @Test("Client with invalid email format fails validation")
    func clientWithInvalidEmail() async throws {
        let client = Client(
            firstName: "John",
            lastName: "Doe",
            email: "invalid-email",
            phone: "1234567890"
        )
        
        #expect(throws: LedgerError.self) {
            try client.validate()
        }
    }
    
    @Test("Client with empty email passes validation")
    func clientWithEmptyEmail() async throws {
        let client = Client(
            firstName: "John",
            lastName: "Doe",
            email: "",
            phone: "1234567890"
        )
        
        // Should not throw - empty email is allowed
        try client.validate()
    }
    
    @Test("Client with invalid phone format fails validation")
    func clientWithInvalidPhone() async throws {
        let client = Client(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            phone: "123" // Too short
        )
        
        #expect(throws: LedgerError.self) {
            try client.validate()
        }
    }
    
    @Test("Client with empty phone passes validation")
    func clientWithEmptyPhone() async throws {
        let client = Client(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            phone: ""
        )
        
        // Should not throw - empty phone is allowed
        try client.validate()
    }
    
    @Test("Client with only first name passes validation")
    func clientWithOnlyFirstName() async throws {
        let client = Client(
            firstName: "Madonna",
            lastName: "",
            email: "madonna@example.com"
        )
        
        // Should not throw
        try client.validate()
    }
    
    @Test("Client with only last name passes validation")
    func clientWithOnlyLastName() async throws {
        let client = Client(
            firstName: "",
            lastName: "Cher",
            email: "cher@example.com"
        )
        
        // Should not throw
        try client.validate()
    }
}

// MARK: - Calendar Safe Date Tests
@Suite("Calendar Safe Date Tests")
struct CalendarSafeDateTests {
    
    @Test("Safe date creation with valid time")
    func safeDateCreationValid() async throws {
        let result = Calendar.safeDateBySettingTime(hour: 9, minute: 30)
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: result)
        #expect(components.hour == 9, "Hour should be set correctly")
        #expect(components.minute == 30, "Minute should be set correctly")
    }
    
    @Test("Safe date creation with invalid time falls back")
    func safeDateCreationInvalidFallback() async throws {
        let baseDate = Date()
        
        // Try to set an invalid time (e.g., hour 25)
        let result = Calendar.safeDateBySettingTime(hour: 25, minute: 0, of: baseDate)
        
        // Should fallback to the original date
        #expect(abs(result.timeIntervalSince(baseDate)) < 1.0, "Should fallback to base date when invalid")
    }
    
    @Test("Safe date creation with extreme values")
    func safeDateCreationExtremeValues() async throws {
        let baseDate = Date()
        
        // Test with negative values
        let result1 = Calendar.safeDateBySettingTime(hour: -1, minute: 0, of: baseDate)
        #expect(result1 != nil, "Should handle negative hour gracefully")
        
        // Test with large values
        let result2 = Calendar.safeDateBySettingTime(hour: 100, minute: 100, of: baseDate)
        #expect(result2 != nil, "Should handle large values gracefully")
    }
}