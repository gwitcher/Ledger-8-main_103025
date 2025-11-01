//  ProjectFormValidatorTests.swift
//  Ledger 8 Tests
//
//  Created: October 31, 2025
//  Purpose: Comprehensive test coverage for ProjectFormValidator
//  Target Coverage: 95%+ for all validation logic

import Testing
@testable import Ledger_8

/// Test suite for ProjectFormValidator pure validation functions
/// These tests ensure business rules are correctly implemented and maintained
@Suite("Project Form Validation Tests")
struct ProjectFormValidatorTests {
    
    // MARK: - Project Name Validation Tests
    
    @Suite("Project Name Validation")
    struct ProjectNameValidationTests {
        
        @Test("Valid project names should pass validation")
        func testValidProjectNames() async throws {
            let validNames = [
                "My Great Project",
                "Album Recording Session",
                "Wedding Ceremony Music",
                "Studio Session #1",
                "Concert at Madison Square Garden"
            ]
            
            for name in validNames {
                let result = ProjectFormValidator.validateProjectName(name)
                #expect(result.isValid, "'\(name)' should be valid")
                #expect(result.errorMessage == nil, "Valid names should have no error message")
            }
        }
        
        @Test("Empty project name should fail validation")
        func testEmptyProjectName() async throws {
            let result = ProjectFormValidator.validateProjectName("")
            
            #expect(!result.isValid, "Empty project name should be invalid")
            #expect(result.errorMessage == "Project name is required", "Should have correct error message")
        }
        
        @Test("Whitespace-only project name should fail validation")
        func testWhitespaceOnlyProjectName() async throws {
            let whitespaceNames = ["   ", "\t", "\n", " \t \n "]
            
            for name in whitespaceNames {
                let result = ProjectFormValidator.validateProjectName(name)
                #expect(!result.isValid, "Whitespace-only name '\(name)' should be invalid")
                #expect(result.errorMessage == "Project name cannot be just whitespace")
            }
        }
        
        @Test("Excessively long project name should fail validation")
        func testExcessivelyLongProjectName() async throws {
            let longName = String(repeating: "a", count: 101) // 101 characters
            let result = ProjectFormValidator.validateProjectName(longName)
            
            #expect(!result.isValid, "Excessively long name should be invalid")
            #expect(result.errorMessage == "Project name cannot exceed 100 characters")
        }
        
        @Test("Boundary length project names should be handled correctly")
        func testBoundaryLengthProjectNames() async throws {
            // Test exactly 100 characters (should pass)
            let exactlyHundred = String(repeating: "a", count: 100)
            let result100 = ProjectFormValidator.validateProjectName(exactlyHundred)
            #expect(result100.isValid, "100-character name should be valid")
            
            // Test 101 characters (should fail)
            let oneHundredOne = String(repeating: "a", count: 101)
            let result101 = ProjectFormValidator.validateProjectName(oneHundredOne)
            #expect(!result101.isValid, "101-character name should be invalid")
        }
    }
    
    // MARK: - Artist Field Validation Tests
    
    @Suite("Artist Field Validation")
    struct ArtistFieldValidationTests {
        
        @Test("Empty artist field should be valid (optional field)")
        func testEmptyArtistField() async throws {
            let result = ProjectFormValidator.validateArtist("")
            
            #expect(result.isValid, "Empty artist field should be valid (optional)")
            #expect(result.errorMessage == nil, "Valid artist should have no error message")
        }
        
        @Test("Valid artist names should pass validation")
        func testValidArtistNames() async throws {
            let validArtists = [
                "John Doe",
                "Mary Johnson-Smith",
                "The Beatles",
                "DJ Cool-Name",
                "Artist with Numbers 123"
            ]
            
            for artist in validArtists {
                let result = ProjectFormValidator.validateArtist(artist)
                #expect(result.isValid, "'\(artist)' should be valid")
                #expect(result.errorMessage == nil, "Valid artist should have no error message")
            }
        }
        
        @Test("Whitespace-only artist field should fail validation")
        func testWhitespaceOnlyArtistField() async throws {
            let whitespaceArtists = ["   ", "\t", "\n", " \t \n "]
            
            for artist in whitespaceArtists {
                let result = ProjectFormValidator.validateArtist(artist)
                #expect(!result.isValid, "Whitespace-only artist '\(artist)' should be invalid")
                #expect(result.errorMessage == "Artist name cannot be just whitespace")
            }
        }
        
        @Test("Excessively long artist name should fail validation")
        func testExcessivelyLongArtistName() async throws {
            let longArtist = String(repeating: "a", count: 101)
            let result = ProjectFormValidator.validateArtist(longArtist)
            
            #expect(!result.isValid, "Excessively long artist name should be invalid")
            #expect(result.errorMessage == "Artist name cannot exceed 100 characters")
        }
    }
    
    // MARK: - Date Range Validation Tests
    
    @Suite("Date Range Validation")
    struct DateRangeValidationTests {
        
        @Test("Valid date range should pass validation")
        func testValidDateRange() async throws {
            let startDate = Date()
            let endDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate)!
            
            let result = ProjectFormValidator.validateDateRange(start: startDate, end: endDate)
            
            #expect(result.isValid, "Valid date range should pass")
            #expect(result.errorMessage == nil, "Valid date range should have no error")
        }
        
        @Test("End date before start date should fail validation")
        func testInvalidDateRange() async throws {
            let startDate = Date()
            let endDate = Calendar.current.date(byAdding: .hour, value: -1, to: startDate)! // 1 hour before start
            
            let result = ProjectFormValidator.validateDateRange(start: startDate, end: endDate)
            
            #expect(!result.isValid, "Invalid date range should fail")
            #expect(result.errorMessage == "End date must be after start date")
        }
        
        @Test("Same start and end date should fail validation")
        func testSameDateRange() async throws {
            let date = Date()
            
            let result = ProjectFormValidator.validateDateRange(start: date, end: date)
            
            #expect(!result.isValid, "Same start and end date should fail")
            #expect(result.errorMessage == "End date must be after start date")
        }
        
        @Test("Excessively long date range should fail validation")
        func testExcessivelyLongDateRange() async throws {
            let startDate = Date()
            let endDate = Calendar.current.date(byAdding: .year, value: 3, to: startDate)! // 3 years later
            
            let result = ProjectFormValidator.validateDateRange(start: startDate, end: endDate)
            
            #expect(!result.isValid, "Excessively long date range should fail")
            #expect(result.errorMessage == "Project duration cannot exceed 2 years")
        }
        
        @Test("Boundary date range (exactly 2 years) should pass validation")
        func testBoundaryDateRange() async throws {
            let startDate = Date()
            // Exactly 2 years minus 1 day should pass
            let endDate = Calendar.current.date(byAdding: .day, value: 729, to: startDate)! // ~2 years - 1 day
            
            let result = ProjectFormValidator.validateDateRange(start: startDate, end: endDate)
            
            #expect(result.isValid, "2-year boundary date range should pass")
        }
    }
    
    // MARK: - Client Selection Validation Tests
    
    @Suite("Client Selection Validation")
    struct ClientSelectionValidationTests {
        
        @Test("Valid client should pass validation")
        func testValidClient() async throws {
            let mockClient = "Valid Client" // Using String as mock client
            
            let result = ProjectFormValidator.validateClient(mockClient)
            
            #expect(result.isValid, "Valid client should pass validation")
            #expect(result.errorMessage == nil, "Valid client should have no error")
        }
        
        @Test("Nil client should fail validation")
        func testNilClient() async throws {
            let nilClient: String? = nil
            
            let result = ProjectFormValidator.validateClient(nilClient)
            
            #expect(!result.isValid, "Nil client should fail validation")
            #expect(result.errorMessage == "Client selection is required")
        }
        
        @Test("Client validation works with different types")
        func testClientValidationWithDifferentTypes() async throws {
            // Test with various types to ensure generic validation works
            let stringClient: String? = "Client"
            let intClient: Int? = 42
            let optionalStringClient: String? = nil
            
            #expect(ProjectFormValidator.validateClient(stringClient).isValid, "String client should be valid")
            #expect(ProjectFormValidator.validateClient(intClient).isValid, "Int client should be valid")
            #expect(!ProjectFormValidator.validateClient(optionalStringClient).isValid, "Nil client should be invalid")
        }
    }
    
    // MARK: - Form-Level Validation Tests
    
    @Suite("Form-Level Validation")
    struct FormLevelValidationTests {
        
        @Test("Valid form data should pass all validations")
        func testValidFormData() async throws {
            let projectName = "Valid Project"
            let artist = "Valid Artist"
            let startDate = Date()
            let endDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate)!
            let client = "Valid Client"
            
            let results = ProjectFormValidator.validateAllFields(
                projectName: projectName,
                artist: artist,
                startDate: startDate,
                endDate: endDate,
                client: client
            )
            
            let isFormValid = ProjectFormValidator.isFormValid(results)
            #expect(isFormValid, "Valid form data should pass all validations")
            
            let errors = ProjectFormValidator.extractErrors(results)
            #expect(errors.isEmpty, "Valid form should have no errors")
        }
        
        @Test("Invalid form data should fail appropriate validations")
        func testInvalidFormData() async throws {
            let projectName = "" // Invalid: empty
            let artist = "   " // Invalid: whitespace only
            let startDate = Date()
            let endDate = Calendar.current.date(byAdding: .hour, value: -1, to: startDate)! // Invalid: before start
            let client: String? = nil // Invalid: nil
            
            let results = ProjectFormValidator.validateAllFields(
                projectName: projectName,
                artist: artist,
                startDate: startDate,
                endDate: endDate,
                client: client
            )
            
            let isFormValid = ProjectFormValidator.isFormValid(results)
            #expect(!isFormValid, "Invalid form data should fail validation")
            
            let errors = ProjectFormValidator.extractErrors(results)
            #expect(errors.count == 4, "Should have 4 validation errors")
            
            // Check specific errors
            #expect(errors[.project] == "Project name is required")
            #expect(errors[.artist] == "Artist name cannot be just whitespace")
            #expect(errors[.dateRange] == "End date must be after start date")
            #expect(errors[.client] == "Client selection is required")
        }
        
        @Test("Mixed valid/invalid form data should have partial errors")
        func testMixedFormData() async throws {
            let projectName = "Valid Project" // Valid
            let artist = "" // Valid (optional)
            let startDate = Date()
            let endDate = startDate // Invalid: same date
            let client = "Valid Client" // Valid
            
            let results = ProjectFormValidator.validateAllFields(
                projectName: projectName,
                artist: artist,
                startDate: startDate,
                endDate: endDate,
                client: client
            )
            
            let isFormValid = ProjectFormValidator.isFormValid(results)
            #expect(!isFormValid, "Form with date range error should be invalid")
            
            let errors = ProjectFormValidator.extractErrors(results)
            #expect(errors.count == 1, "Should have only 1 validation error")
            #expect(errors[.dateRange] == "End date must be after start date")
        }
    }
    
    // MARK: - Convenience Methods Tests
    
    @Suite("Convenience Methods")
    struct ConvenienceMethodsTests {
        
        @Test("Error summary should extract messages correctly")
        func testErrorSummary() async throws {
            let results: [ProjectField: ProjectFormValidator.ValidationResult] = [
                .project: .invalid("Project error"),
                .artist: .valid,
                .dateRange: .invalid("Date error"),
                .client: .valid
            ]
            
            let summary = ProjectFormValidator.getErrorSummary(results)
            
            #expect(summary.count == 2, "Should have 2 error messages")
            #expect(summary.contains("Project error"), "Should contain project error")
            #expect(summary.contains("Date error"), "Should contain date error")
        }
        
        @Test("Form validity check should work correctly")
        func testFormValidityCheck() async throws {
            let validResults: [ProjectField: ProjectFormValidator.ValidationResult] = [
                .project: .valid,
                .artist: .valid,
                .dateRange: .valid,
                .client: .valid
            ]
            
            let invalidResults: [ProjectField: ProjectFormValidator.ValidationResult] = [
                .project: .invalid("Error"),
                .artist: .valid,
                .dateRange: .valid,
                .client: .valid
            ]
            
            #expect(ProjectFormValidator.isFormValid(validResults), "All valid results should be form valid")
            #expect(!ProjectFormValidator.isFormValid(invalidResults), "Any invalid result should make form invalid")
        }
    }
    
    // MARK: - Edge Cases and Performance Tests
    
    @Suite("Edge Cases and Performance")
    struct EdgeCasesAndPerformanceTests {
        
        @Test("Unicode and special characters in project names")
        func testUnicodeProjectNames() async throws {
            let unicodeNames = [
                "Café Recording Session", // Accented characters
                "音楽プロジェクト", // Japanese characters
                "Müller's Concert", // German umlauts
                "🎵 Music Project 🎵" // Emojis
            ]
            
            for name in unicodeNames {
                let result = ProjectFormValidator.validateProjectName(name)
                #expect(result.isValid, "Unicode name '\(name)' should be valid")
            }
        }
        
        @Test("Validation performance with large inputs")
        func testValidationPerformance() async throws {
            let largeValidName = String(repeating: "Valid Project Name ", count: 5) // 100 chars
            
            // Measure validation performance
            let startTime = Date()
            
            for _ in 0..<1000 {
                let _ = ProjectFormValidator.validateProjectName(largeValidName)
            }
            
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            
            // Should complete 1000 validations in under 100ms
            #expect(duration < 0.1, "1000 validations should complete in under 100ms, took \(duration)s")
        }
        
        @Test("Concurrent validation safety")
        func testConcurrentValidation() async throws {
            await withTaskGroup(of: Bool.self) { group in
                // Start 10 concurrent validation tasks
                for i in 0..<10 {
                    group.addTask {
                        let result = ProjectFormValidator.validateProjectName("Project \(i)")
                        return result.isValid
                    }
                }
                
                // All should succeed
                for await isValid in group {
                    #expect(isValid, "Concurrent validation should succeed")
                }
            }
        }
    }
}

// MARK: - ValidationResult Tests

@Suite("ValidationResult Type Tests")
struct ValidationResultTests {
    
    @Test("Valid result creation")
    func testValidResult() async throws {
        let result = ProjectFormValidator.ValidationResult.valid
        
        #expect(result.isValid, "Valid result should have isValid = true")
        #expect(result.errorMessage == nil, "Valid result should have nil error message")
    }
    
    @Test("Invalid result creation")
    func testInvalidResult() async throws {
        let errorMessage = "Test error message"
        let result = ProjectFormValidator.ValidationResult.invalid(errorMessage)
        
        #expect(!result.isValid, "Invalid result should have isValid = false")
        #expect(result.errorMessage == errorMessage, "Invalid result should preserve error message")
    }
}