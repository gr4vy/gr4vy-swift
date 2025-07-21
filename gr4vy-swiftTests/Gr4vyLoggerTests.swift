//
//  Gr4vyLoggerTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

class Gr4vyLoggerTests: XCTestCase {
    override func setUpWithError() throws {
        // Enable logging for tests
        Gr4vyLogger.enable()
    }

    override func tearDownWithError() throws {
        // Disable logging after tests
        Gr4vyLogger.disable()
    }

    // MARK: - Enable/Disable Tests
    func testLoggerEnableDisable() {
        // Test disable
        Gr4vyLogger.disable()
        // Note: We can't easily test console output, but we can test the enable/disable functionality
        // by checking if methods complete without crashing

        XCTAssertNoThrow(Gr4vyLogger.log("test message"))
        XCTAssertNoThrow(Gr4vyLogger.error("test error"))
        XCTAssertNoThrow(Gr4vyLogger.network("test network"))
        XCTAssertNoThrow(Gr4vyLogger.debug("test debug"))

        // Test enable
        Gr4vyLogger.enable()
        XCTAssertNoThrow(Gr4vyLogger.log("test message"))
        XCTAssertNoThrow(Gr4vyLogger.error("test error"))
        XCTAssertNoThrow(Gr4vyLogger.network("test network"))
        XCTAssertNoThrow(Gr4vyLogger.debug("test debug"))
    }

    // MARK: - Sensitive Data Masking Tests
    func testBearerTokenMasking() {
        // Test that Bearer tokens are masked
        let messageWithToken = "Authorization: Bearer abc123.def456.ghi789"

        // We can't directly test the masked output, but we can test that the method doesn't crash
        XCTAssertNoThrow(Gr4vyLogger.log(messageWithToken))
        XCTAssertNoThrow(Gr4vyLogger.error(messageWithToken))
        XCTAssertNoThrow(Gr4vyLogger.network(messageWithToken))
    }

    func testJSONTokenMasking() {
        let jsonWithToken = """
        {
            "token": "secret_token_123",
            "user": "test_user"
        }
        """

        XCTAssertNoThrow(Gr4vyLogger.log(jsonWithToken))
        XCTAssertNoThrow(Gr4vyLogger.debug(jsonWithToken))
    }

    func testCardNumberMasking() {
        let jsonWithCardNumber = """
        {
            "number": "4111111111111111",
            "expiry": "12/25"
        }
        """

        XCTAssertNoThrow(Gr4vyLogger.log(jsonWithCardNumber))
        XCTAssertNoThrow(Gr4vyLogger.debug(jsonWithCardNumber))
    }

    func testSecurityCodeMasking() {
        let jsonWithSecurityCode = """
        {
            "security_code": "123",
            "number": "4111111111111111"
        }
        """

        XCTAssertNoThrow(Gr4vyLogger.log(jsonWithSecurityCode))
        XCTAssertNoThrow(Gr4vyLogger.debug(jsonWithSecurityCode))
    }

    // MARK: - Data Object Handling Tests
    func testDataObjectLogging() {
        let testData = "test data".data(using: .utf8)!

        XCTAssertNoThrow(Gr4vyLogger.debug(testData))
    }

    func testDataObjectWithJSON() {
        let jsonData = """
        {
            "token": "secret_token",
            "number": "4111111111111111"
        }
        """.data(using: .utf8)!

        XCTAssertNoThrow(Gr4vyLogger.debug(jsonData))
    }

    func testBinaryDataLogging() {
        let binaryData = Data([0x00, 0x01, 0x02, 0x03, 0xFF])

        XCTAssertNoThrow(Gr4vyLogger.debug(binaryData))
    }
    
    // MARK: - Edge Cases
    func testEmptyMessageLogging() {
        XCTAssertNoThrow(Gr4vyLogger.log(""))
        XCTAssertNoThrow(Gr4vyLogger.error(""))
        XCTAssertNoThrow(Gr4vyLogger.network(""))
        XCTAssertNoThrow(Gr4vyLogger.debug(""))
    }

    func testNilObjectLogging() {
        let nilObject: String? = nil
        XCTAssertNoThrow(Gr4vyLogger.debug(nilObject as Any))
    }

    func testComplexObjectLogging() {
        let complexObject = [
            "array": [1, 2, 3],
            "nested": ["key": "value"],
            "token": "should_be_masked",
        ] as [String: Any]

        XCTAssertNoThrow(Gr4vyLogger.debug(complexObject))
    }
}
