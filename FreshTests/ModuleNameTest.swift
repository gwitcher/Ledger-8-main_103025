//  ModuleNameTest.swift
//  Ledger 8 Tests
//
//  Test different module name variations

import XCTest

// Try different module name variations
// Uncomment one at a time to test

// Option 1: Underscore version
@testable import Ledger_8

// Option 2: Space version (uncomment to try)
// @testable import Ledger 8

// Option 3: No space version (uncomment to try) 
// @testable import Ledger8

// Option 4: All caps version (uncomment to try)
// @testable import LEDGER_8

class ModuleNameTest: XCTestCase {
    
    func testModuleImport() {
        // If we can access ProjectFormValidator, the import worked
        let result = ProjectFormValidator.validateProjectName("Test")
        XCTAssertNotNil(result, "Should be able to access ProjectFormValidator")
        print("✅ Module import successful!")
    }
}