//  ProjectValidationViewModelTests.swift
//  Ledger 8 Tests
//
//  Created: October 31, 2025
//  Purpose: Comprehensive tests for ProjectValidationViewModel state management
//  Target Coverage: 90%+ for observable state logic

import Testing
@testable import Ledger_8

/// Test suite for ProjectValidationViewModel observable state management
/// These tests ensure state coupling issues are eliminated and clean interfaces work correctly
@Suite("Project Validation ViewModel Tests")
struct ProjectValidationViewModelTests {
    
    // MARK: - Basic State Management Tests
    
    @Suite("Basic State Management")
    struct BasicStateManagementTests {
        
        @Test("Initial state should be clean")
        func testInitialState() async throws {
            let viewModel = ProjectValidationViewModel()
            
            #expect(viewModel.validationErrors.isEmpty, "Should start with no errors")
            #expect(viewModel.focusedFields.isEmpty, "Should start with no focused fields")
            #expect(viewModel.actionTriggeredFields.isEmpty, "Should start with no triggered fields")
            #expect(!viewModel.shouldShowValidationSummary, "Should not show summary initially")
            #expect(!viewModel.formSubmissionAttempted, "Should not have form submission attempted")
            #expect(!viewModel.hasErrors, "Should have no errors initially")
            #expect(viewModel.isFormValid, "Should be form valid initially")
            #expect(viewModel.summaryErrors.isEmpty, "Should have no summary errors")
        }
        
        @Test("Single field validation updates state correctly")
        func testSingleFieldValidation() async throws {
            let viewModel = ProjectValidationViewModel()
            
            // Test valid field
            let validResult = viewModel.validateField(.project, value: "Valid Project")
            #expect(validResult, "Valid project name should return true")
            #expect(!viewModel.hasErrors, "Should have no errors for valid field")
            #expect(viewModel.isFormValid, "Should be form valid for valid field")
            
            // Test invalid field
            let invalidResult = viewModel.validateField(.project, value: "")
            #expect(!invalidResult, "Invalid project name should return false")
            #expect(viewModel.hasErrors, "Should have errors for invalid field")
            #expect(!viewModel.isFormValid, "Should not be form valid for invalid field")
            #expect(viewModel.validationErrors[.project] == "Project name is required")
        }
        
        @Test("Multiple field validation accumulates errors correctly")
        func testMultipleFieldValidation() async throws {
            let viewModel = ProjectValidationViewModel()
            
            // Add multiple errors
            viewModel.validateField(.project, value: "")
            viewModel.validateField(.artist, value: "   ")
            viewModel.validateField(.client, value: nil as String?)
            
            #expect(viewModel.validationErrors.count == 3, "Should have 3 validation errors")
            #expect(viewModel.hasErrors, "Should have errors")
            #expect(!viewModel.isFormValid, "Should not be form valid")
            
            // Fix one error
            viewModel.validateField(.project, value: "Valid Project")
            
            #expect(viewModel.validationErrors.count == 2, "Should have 2 validation errors after fix")
            #expect(viewModel.validationErrors[.project] == nil, "Project error should be cleared")
        }
    }
    
    // MARK: - Focus Management Tests
    
    @Suite("Focus Management")
    struct FocusManagementTests {
        
        @Test("Focus tracking works correctly")
        func testFocusTracking() async throws {
            let viewModel = ProjectValidationViewModel()
            
            #expect(!viewModel.hasBeenFocused(.project), "Field should not be focused initially")
            
            viewModel.markFieldAsFocused(.project)
            
            #expect(viewModel.hasBeenFocused(.project), "Field should be focused after marking")
            #expect(!viewModel.hasBeenFocused(.artist), "Other fields should not be affected")
        }
        
        @Test("Multiple field focus tracking")
        func testMultipleFieldFocus() async throws {
            let viewModel = ProjectValidationViewModel()
            
            viewModel.markFieldAsFocused(.project)
            viewModel.markFieldAsFocused(.artist)
            viewModel.markFieldAsFocused(.client)
            
            #expect(viewModel.hasBeenFocused(.project), "Project should be focused")
            #expect(viewModel.hasBeenFocused(.artist), "Artist should be focused")
            #expect(viewModel.hasBeenFocused(.client), "Client should be focused")
            #expect(!viewModel.hasBeenFocused(.dateRange), "Date range should not be focused")
            
            #expect(viewModel.focusedFields.count == 3, "Should have 3 focused fields")
        }
    }
    
    // MARK: - Form Submission and Action-Triggered Validation Tests
    
    @Suite("Form Submission and Action-Triggered Validation")
    struct FormSubmissionTests {
        
        @Test("Form submission with valid data")
        func testValidFormSubmission() async throws {
            let viewModel = ProjectValidationViewModel()
            
            let startDate = Date()
            let endDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate)!
            
            let isValid = viewModel.triggerFormValidation(
                projectName: "Valid Project",
                artist: "Valid Artist",
                startDate: startDate,
                endDate: endDate,
                client: "Valid Client"
            )
            
            #expect(isValid, "Valid form should pass validation")
            #expect(viewModel.formSubmissionAttempted, "Should mark form submission as attempted")
            #expect(!viewModel.shouldShowValidationSummary, "Should not show summary for valid form")
            #expect(viewModel.actionTriggeredFields.isEmpty, "Should have no triggered fields for valid form")
        }
        
        @Test("Form submission with invalid data triggers appropriate UI state")
        func testInvalidFormSubmission() async throws {
            let viewModel = ProjectValidationViewModel()
            
            let startDate = Date()
            let endDate = startDate // Invalid: same date
            
            let isValid = viewModel.triggerFormValidation(
                projectName: "", // Invalid
                artist: "Valid Artist",
                startDate: startDate,
                endDate: endDate,
                client: nil as String? // Invalid
            )
            
            #expect(!isValid, "Invalid form should fail validation")
            #expect(viewModel.formSubmissionAttempted, "Should mark form submission as attempted")
            #expect(viewModel.shouldShowValidationSummary, "Should show summary for invalid form")
            #expect(viewModel.hasErrors, "Should have validation errors")
            
            // Check that triangles should show for error fields
            #expect(viewModel.shouldShowTriangle(for: .project), "Should show triangle for project field")
            #expect(viewModel.shouldShowTriangle(for: .client), "Should show triangle for client field")
            #expect(viewModel.shouldShowTriangle(for: .dateRange), "Should show triangle for date range field")
            #expect(!viewModel.shouldShowTriangle(for: .artist), "Should not show triangle for valid artist field")
        }
        
        @Test("Validation summary visibility logic")
        func testValidationSummaryVisibility() async throws {
            let viewModel = ProjectValidationViewModel()
            
            // Add error but no form submission - should not show summary
            viewModel.validateField(.project, value: "")
            #expect(!viewModel.shouldShowValidationSummary, "Should not show summary without form submission")
            
            // Trigger form submission - should show summary
            viewModel.triggerFormValidation(
                projectName: "",
                artist: "",
                startDate: Date(),
                endDate: Date(),
                client: nil as String?
            )
            #expect(viewModel.shouldShowValidationSummary, "Should show summary after form submission with errors")
            
            // Hide summary manually
            viewModel.hideValidationSummary()
            #expect(!viewModel.shouldShowValidationSummary, "Should hide summary when manually dismissed")
            
            // Fix errors - should still be hidden
            viewModel.validateField(.project, value: "Valid Project")
            viewModel.validateField(.client, value: "Valid Client")
            #expect(!viewModel.hasErrors, "Should have no errors after fixing")
            #expect(!viewModel.shouldShowValidationSummary, "Should remain hidden after errors fixed")
        }
    }
    
    // MARK: - Date Range Validation Tests
    
    @Suite("Date Range Validation")
    struct DateRangeValidationTests {
        
        @Test("Date range validation with tuple input")
        func testDateRangeValidation() async throws {
            let viewModel = ProjectValidationViewModel()
            
            let startDate = Date()
            let validEndDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate)!
            let invalidEndDate = Calendar.current.date(byAdding: .hour, value: -1, to: startDate)!
            
            // Test valid date range
            let validResult = viewModel.validateField(.dateRange, value: (startDate, validEndDate))
            #expect(validResult, "Valid date range should pass")
            #expect(!viewModel.hasErrors, "Should have no errors for valid date range")
            
            // Test invalid date range
            let invalidResult = viewModel.validateField(.dateRange, value: (startDate, invalidEndDate))
            #expect(!invalidResult, "Invalid date range should fail")
            #expect(viewModel.hasErrors, "Should have errors for invalid date range")
            #expect(viewModel.validationErrors[.dateRange] == "End date must be after start date")
        }
        
        @Test("Date range validation with invalid input type")
        func testDateRangeValidationWithInvalidInput() async throws {
            let viewModel = ProjectValidationViewModel()
            
            // Pass invalid input type (not a tuple of dates)
            let result = viewModel.validateField(.dateRange, value: "Not a date tuple")
            
            #expect(!result, "Invalid input type should fail validation")
            #expect(viewModel.validationErrors[.dateRange] == "Invalid date range")
        }
    }
    
    // MARK: - State Clearing and Reset Tests
    
    @Suite("State Clearing and Reset")
    struct StateClearingTests {
        
        @Test("Clear all validation resets state completely")
        func testClearAllValidation() async throws {
            let viewModel = ProjectValidationViewModel()
            
            // Set up some state
            viewModel.validateField(.project, value: "")
            viewModel.markFieldAsFocused(.project)
            viewModel.triggerFormValidation(
                projectName: "",
                artist: "",
                startDate: Date(),
                endDate: Date(),
                client: nil as String?
            )
            
            // Verify state is set
            #expect(viewModel.hasErrors, "Should have errors before clearing")
            #expect(viewModel.formSubmissionAttempted, "Should have form submission attempted")
            
            // Clear all validation
            viewModel.clearAllValidation()
            
            // Verify state is reset
            #expect(!viewModel.hasErrors, "Should have no errors after clearing")
            #expect(viewModel.focusedFields.isEmpty, "Should have no focused fields after clearing")
            #expect(viewModel.actionTriggeredFields.isEmpty, "Should have no triggered fields after clearing")
            #expect(!viewModel.shouldShowValidationSummary, "Should not show summary after clearing")
            #expect(!viewModel.formSubmissionAttempted, "Should reset form submission attempted")
        }
        
        @Test("Clear specific field validation")
        func testClearSpecificFieldValidation() async throws {
            let viewModel = ProjectValidationViewModel()
            
            // Add multiple errors
            viewModel.validateField(.project, value: "")
            viewModel.validateField(.artist, value: "   ")
            
            #expect(viewModel.validationErrors.count == 2, "Should have 2 errors initially")
            
            // Clear specific field
            viewModel.clearValidation(for: .project)
            
            #expect(viewModel.validationErrors.count == 1, "Should have 1 error after clearing specific field")
            #expect(viewModel.validationErrors[.project] == nil, "Project error should be cleared")
            #expect(viewModel.validationErrors[.artist] != nil, "Artist error should remain")
        }
    }
    
    // MARK: - ValidationBannerError Mapping Tests
    
    @Suite("ValidationBannerError Mapping")
    struct ValidationBannerErrorMappingTests {
        
        @Test("Summary errors map correctly to ValidationBannerError cases")
        func testSummaryErrorMapping() async throws {
            let viewModel = ProjectValidationViewModel()
            
            // Add various types of errors
            viewModel.validateField(.project, value: "")
            viewModel.validateField(.artist, value: "   ")
            let startDate = Date()
            viewModel.validateField(.dateRange, value: (startDate, startDate))
            viewModel.validateField(.client, value: nil as String?)
            
            let summaryErrors = viewModel.summaryErrors
            
            #expect(summaryErrors.count == 4, "Should have 4 summary errors")
            
            // Verify correct mapping
            let errorTypes = summaryErrors.map { error in
                switch error {
                case .projectName: return "project"
                case .artist: return "artist"
                case .dateRange: return "dateRange"
                case .client: return "client"
                }
            }.sorted()
            
            #expect(errorTypes == ["artist", "client", "dateRange", "project"], "Should map all error types correctly")
        }
        
        @Test("getCurrentValidationBannerErrors returns correct errors")
        func testGetCurrentValidationBannerErrors() async throws {
            let viewModel = ProjectValidationViewModel()
            
            viewModel.validateField(.project, value: "")
            
            let bannerErrors = viewModel.getCurrentValidationBannerErrors()
            
            #expect(bannerErrors.count == 1, "Should have 1 banner error")
            
            if case .projectName(let message) = bannerErrors.first {
                #expect(message == "Project name is required", "Should have correct error message")
            } else {
                Issue.record("Expected projectName error case")
            }
        }
    }
    
    // MARK: - Comprehensive Form Validation Tests
    
    @Suite("Comprehensive Form Validation")
    struct ComprehensiveFormValidationTests {
        
        @Test("Full form validation with all field types")
        func testFullFormValidation() async throws {
            let viewModel = ProjectValidationViewModel()
            
            let startDate = Date()
            let endDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate)!
            
            let isValid = viewModel.validateAllFields(
                projectName: "Valid Project",
                artist: "", // Valid (optional)
                startDate: startDate,
                endDate: endDate,
                client: "Valid Client"
            )
            
            #expect(isValid, "Valid form data should pass validation")
            #expect(!viewModel.hasErrors, "Valid form should have no errors")
            #expect(viewModel.isFormValid, "Valid form should be form valid")
        }
        
        @Test("Form validation with mixed valid/invalid data")
        func testMixedFormValidation() async throws {
            let viewModel = ProjectValidationViewModel()
            
            let startDate = Date()
            
            let isValid = viewModel.validateAllFields(
                projectName: "Valid Project", // Valid
                artist: "   ", // Invalid: whitespace only
                startDate: startDate,
                endDate: startDate, // Invalid: same as start
                client: nil as String? // Invalid: nil
            )
            
            #expect(!isValid, "Mixed form data should fail validation")
            #expect(viewModel.hasErrors, "Should have errors")
            #expect(viewModel.validationErrors.count == 3, "Should have 3 errors")
            
            // Verify specific errors
            #expect(viewModel.validationErrors[.project] == nil, "Project should be valid")
            #expect(viewModel.validationErrors[.artist] == "Artist name cannot be just whitespace")
            #expect(viewModel.validationErrors[.dateRange] == "End date must be after start date")
            #expect(viewModel.validationErrors[.client] == "Client selection is required")
        }
    }
    
    // MARK: - Performance and Concurrency Tests
    
    @Suite("Performance and Concurrency")
    struct PerformanceTests {
        
        @Test("Validation performance with rapid field updates")
        func testRapidValidationPerformance() async throws {
            let viewModel = ProjectValidationViewModel()
            
            let startTime = Date()
            
            // Simulate rapid field updates (like user typing)
            for i in 0..<100 {
                viewModel.validateField(.project, value: "Project \(i)")
                viewModel.validateField(.artist, value: "Artist \(i)")
            }
            
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            
            // Should complete 200 validations in under 50ms
            #expect(duration < 0.05, "200 rapid validations should complete in under 50ms, took \(duration)s")
        }
        
        @Test("State consistency under concurrent access")
        func testConcurrentStateAccess() async throws {
            let viewModel = ProjectValidationViewModel()
            
            await withTaskGroup(of: Void.self) { group in
                // Multiple concurrent validation tasks
                for i in 0..<10 {
                    group.addTask {
                        viewModel.validateField(.project, value: "Project \(i)")
                        viewModel.markFieldAsFocused(.project)
                    }
                }
                
                // Wait for all to complete
                await group.waitForAll()
            }
            
            // State should be consistent (last validation wins)
            #expect(viewModel.hasBeenFocused(.project), "Field should be marked as focused")
            #expect(!viewModel.hasErrors, "Should have no validation errors")
        }
    }
}