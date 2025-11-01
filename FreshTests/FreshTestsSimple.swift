//
//  FreshTestsSimple.swift
//  FreshTests
//
//  Simple test for the fresh test target
//

import XCTest

class FreshTestsSimple: XCTestCase {

    func testSimpleMath() {
        // Absolutely basic test
        XCTAssertEqual(1 + 1, 2, "Math should work")
        print("🎯 FreshTests simple test ran!")
    }
    
    override func setUp() {
        super.setUp()
        print("🚀 FreshTests setUp called")
    }
    
    override func tearDown() {
        super.tearDown()
        print("🏁 FreshTests tearDown called")
    }

}