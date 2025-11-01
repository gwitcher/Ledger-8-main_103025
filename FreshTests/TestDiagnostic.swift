//  TestDiagnostic.swift
//  Ledger 8 Tests
//
//  Diagnostic tests to identify issues

import Testing
import Foundation
@testable import Ledger_8

@Test("Diagnostic: ProjectFormValidator exists")
func testProjectFormValidatorExists() async throws {
    // Test that the class exists and basic method works
    let result = ProjectFormValidator.validateProjectName("Test")
    print("✅ ProjectFormValidator.validateProjectName returned: \(result)")
    #expect(result.isValid == true)
}

@Test("Diagnostic: ValidationHelper exists") 
func testValidationHelperExists() async throws {
    let result = ValidationHelper.isNotEmpty("Test")
    print("✅ ValidationHelper.isNotEmpty returned: \(result)")
    #expect(result == true)
}

@Test("Diagnostic: ProjectField enum exists")
func testProjectFieldExists() async throws {
    let field = ProjectField.project
    print("✅ ProjectField.project exists: \(field)")
    #expect(field != nil)
}

@Test("Diagnostic: ValidationResult works")
func testValidationResultWorks() async throws {
    let validResult = ProjectFormValidator.ValidationResult.valid
    let invalidResult = ProjectFormValidator.ValidationResult.invalid("Test error")
    
    print("✅ ValidationResult.valid: isValid=\(validResult.isValid), error=\(validResult.errorMessage ?? "nil")")
    print("✅ ValidationResult.invalid: isValid=\(invalidResult.isValid), error=\(invalidResult.errorMessage ?? "nil")")
    
    #expect(validResult.isValid == true)
    #expect(invalidResult.isValid == false)
}