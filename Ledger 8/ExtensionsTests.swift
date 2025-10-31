//
//  ExtensionsTests.swift
//  Ledger 8 Tests
//
//  Created for Phase 0 - Critical Foundation fixes
//

import Testing
@testable import Ledger_8
import SwiftData

// MARK: - Extensions Tests
@Suite("Extensions Tests - Financial Calculations")
struct ExtensionsTests {
    
    // MARK: - Project Fee Calculation Tests
    
    @Test("Calculate fee total with no items")
    func calculateFeeTotal_withNoItems() async throws {
        let project = Project()
        let emptyItems: [Item] = []
        
        let result = project.calculateFeeTotal(items: emptyItems)
        
        #expect(result == 0.0, "Fee total should be 0.0 when no items")
    }
    
    @Test("Calculate fee total with single item")
    func calculateFeeTotal_withSingleItem() async throws {
        let project = Project()
        let testItem = Item(name: "Test Session", fee: 150.0, itemType: .session, notes: "Test")
        let items = [testItem]
        
        let result = project.calculateFeeTotal(items: items)
        
        #expect(result == 150.0, "Fee total should match single item fee")
    }
    
    @Test("Calculate fee total with multiple items")
    func calculateFeeTotal_withMultipleItems() async throws {
        let project = Project()
        let items = [
            Item(name: "Session 1", fee: 150.0, itemType: .session, notes: ""),
            Item(name: "Session 2", fee: 200.0, itemType: .session, notes: ""),
            Item(name: "Overdub", fee: 75.0, itemType: .overdub, notes: "")
        ]
        
        let result = project.calculateFeeTotal(items: items)
        
        #expect(result == 425.0, "Fee total should be sum of all item fees")
    }
    
    // MARK: - Projects Fee Total Tests
    
    @Test("Calculate projects fee total with no projects")
    func projectsFeeTotal_withNoProjects() async throws {
        let project = Project()
        let emptyProjects: [Project] = []
        
        let result = project.projectsFeeTotal(projects: emptyProjects)
        
        #expect(result == 0.0, "Projects fee total should be 0.0 when no projects")
    }
    
    @Test("Calculate projects fee total with projects that have no items")
    func projectsFeeTotal_withProjectsWithNoItems() async throws {
        let project = Project()
        let projectWithNoItems = Project()
        projectWithNoItems.items = [] // Empty items
        
        let result = project.projectsFeeTotal(projects: [projectWithNoItems])
        
        #expect(result == 0.0, "Projects fee total should be 0.0 when projects have no items")
    }
    
    @Test("Calculate projects fee total with projects containing items")
    func projectsFeeTotal_withProjectsContainingItems() async throws {
        let testProject = Project()
        
        // Create test projects with items
        let project1 = Project()
        project1.items = [
            Item(name: "Session", fee: 150.0, itemType: .session, notes: ""),
            Item(name: "Overdub", fee: 75.0, itemType: .overdub, notes: "")
        ]
        
        let project2 = Project()
        project2.items = [
            Item(name: "Concert", fee: 500.0, itemType: .concert, notes: "")
        ]
        
        let result = testProject.projectsFeeTotal(projects: [project1, project2])
        
        #expect(result == 725.0, "Projects fee total should be sum of all items across projects (150 + 75 + 500)")
    }
    
    // MARK: - Date Extension Tests
    
    @Test("Date adding minutes")
    func dateAddingMinutes() async throws {
        let startDate = Date()
        let result = startDate.adding(minutes: 30)
        
        let timeDifference = result.timeIntervalSince(startDate)
        let expectedDifference = 30.0 * 60.0 // 30 minutes in seconds
        
        #expect(abs(timeDifference - expectedDifference) < 1.0, "Date should be 30 minutes later")
    }
    
    @Test("Date adding hours")
    func dateAddingHours() async throws {
        let startDate = Date()
        let result = startDate.adding(hours: 2)
        
        let timeDifference = result.timeIntervalSince(startDate)
        let expectedDifference = 2.0 * 60.0 * 60.0 // 2 hours in seconds
        
        #expect(abs(timeDifference - expectedDifference) < 1.0, "Date should be 2 hours later")
    }
    
    @Test("Date adding minutes fallback behavior")
    func dateAddingMinutes_withFallback() async throws {
        let originalDate = Date()
        
        // This should not fail due to our safe implementation
        let result = originalDate.adding(minutes: Int.max) // Extreme value
        
        // Result should either be the calculated date or the original date (fallback)
        #expect(result >= originalDate, "Result should be >= original date or fallback to original")
    }
    
    // MARK: - Invoice Number Tests
    
    @Test("Next invoice number with no projects")
    func nextInvoiceNumber_withNoProjects() async throws {
        let project = Project()
        let emptyProjects: [Project] = []
        let defaultNumber = 1000
        
        let result = project.nextInvoiceNumber(projects: emptyProjects, defaultInvoiceNumber: defaultNumber)
        
        #expect(result == defaultNumber, "Should return default when no projects exist")
    }
    
    @Test("Next invoice number with projects without invoices")
    func nextInvoiceNumber_withProjectsWithoutInvoices() async throws {
        let project = Project()
        let projectsWithoutInvoices = [Project(), Project()]
        let defaultNumber = 1000
        
        let result = project.nextInvoiceNumber(projects: projectsWithoutInvoices, defaultInvoiceNumber: defaultNumber)
        
        #expect(result == defaultNumber, "Should return default when no invoices exist")
    }
    
    @Test("Next invoice number with existing invoices")
    func nextInvoiceNumber_withExistingInvoices() async throws {
        let project = Project()
        
        let project1 = Project()
        project1.invoice = Invoice(number: 1001, name: "Invoice 1001")
        
        let project2 = Project()
        project2.invoice = Invoice(number: 1005, name: "Invoice 1005")
        
        let projects = [project1, project2]
        let defaultNumber = 1000
        
        let result = project.nextInvoiceNumber(projects: projects, defaultInvoiceNumber: defaultNumber)
        
        #expect(result == 1005, "Should return highest existing invoice number")
    }
}

// MARK: - Validation Tests
@Suite("Validation Tests")
struct ValidationTests {
    
    @Test("Valid email format")
    func validEmailFormat() async throws {
        #expect(ValidationHelper.isValidEmail("test@example.com") == true)
        #expect(ValidationHelper.isValidEmail("user.name@domain.co.uk") == true)
        #expect(ValidationHelper.isValidEmail("test+tag@example.org") == true)
    }
    
    @Test("Invalid email format")
    func invalidEmailFormat() async throws {
        #expect(ValidationHelper.isValidEmail("invalid") == false)
        #expect(ValidationHelper.isValidEmail("@example.com") == false)
        #expect(ValidationHelper.isValidEmail("test@") == false)
        #expect(ValidationHelper.isValidEmail("") == false)
    }
    
    @Test("Valid phone number format")
    func validPhoneFormat() async throws {
        #expect(ValidationHelper.isValidPhoneNumber("1234567890") == true)
        #expect(ValidationHelper.isValidPhoneNumber("(123) 456-7890") == true)
        #expect(ValidationHelper.isValidPhoneNumber("+1-123-456-7890") == true)
    }
    
    @Test("Invalid phone number format")
    func invalidPhoneFormat() async throws {
        #expect(ValidationHelper.isValidPhoneNumber("123") == false)
        #expect(ValidationHelper.isValidPhoneNumber("abcdefghij") == false)
        #expect(ValidationHelper.isValidPhoneNumber("") == false)
    }
    
    @Test("Non-empty string validation")
    func nonEmptyStringValidation() async throws {
        #expect(ValidationHelper.isNotEmpty("Valid String") == true)
        #expect(ValidationHelper.isNotEmpty("   Trimmed   ") == true)
        #expect(ValidationHelper.isNotEmpty("") == false)
        #expect(ValidationHelper.isNotEmpty("   ") == false)
    }
}

// MARK: - Error Handling Tests  
@Suite("Error Handling Tests")
struct ErrorHandlingTests {
    
    @Test("LedgerError localized descriptions")
    func ledgerErrorLocalizedDescriptions() async throws {
        let dataCorruptionError = LedgerError.dataCorruption
        #expect(dataCorruptionError.localizedDescription.contains("corrupted"))
        
        let validationError = LedgerError.validationFailed("Test message")
        #expect(validationError.localizedDescription.contains("Test message"))
        
        let emptyFieldError = LedgerError.emptyRequiredField("Project Name")
        #expect(emptyFieldError.localizedDescription.contains("Project Name"))
    }
    
    @Test("LedgerError recovery suggestions")
    func ledgerErrorRecoverySuggestions() async throws {
        let dataCorruptionError = LedgerError.dataCorruption
        #expect(dataCorruptionError.recoverySuggestion != nil)
        
        let validationError = LedgerError.validationFailed("Test")
        #expect(validationError.recoverySuggestion != nil)
    }
}