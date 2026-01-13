//
//  Gr4vyUtilityTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

class Gr4vyUtilityTests: XCTestCase {
    var sandboxSetup: Gr4vySetup!
    var productionSetup: Gr4vySetup!

    override func setUpWithError() throws {
        sandboxSetup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox,
            timeout: 30
        )

        productionSetup = Gr4vySetup(
            gr4vyId: "prod-id",
            token: "prod-token",
            merchantId: "prod-merchant",
            server: .production,
            timeout: 30
        )
    }

    override func tearDownWithError() throws {
        sandboxSetup = nil
        productionSetup = nil
    }

    // MARK: - Payment Options URL Tests
    func testPaymentOptionsURLSandbox() throws {
        let url = try Gr4vyUtility.paymentOptionsURL(from: sandboxSetup)

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "api.sandbox.test-id.gr4vy.app")
        XCTAssertEqual(url.path, "/payment-options")
    }

    func testPaymentOptionsURLProduction() throws {
        let url = try Gr4vyUtility.paymentOptionsURL(from: productionSetup)

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "api.prod-id.gr4vy.app")
        XCTAssertEqual(url.path, "/payment-options")
    }

    func testPaymentOptionsURLEmptyGr4vyId() throws {
        let invalidSetup = Gr4vySetup(
            gr4vyId: "",
            token: "test-token",
            merchantId: "empty-test-merchant",
            server: .sandbox,
            timeout: 30
        )

        XCTAssertThrowsError(try Gr4vyUtility.paymentOptionsURL(from: invalidSetup)) { error in
            XCTAssertTrue(error is Gr4vyError)
            if case .badURL(let message) = error as? Gr4vyError {
                XCTAssertEqual(message, "Gr4vy ID is empty")
            } else {
                XCTFail("Expected badURL error")
            }
        }
    }

    // MARK: - Card Details URL Tests
    func testCardDetailsURLSandbox() throws {
        let url = try Gr4vyUtility.cardDetailsURL(from: sandboxSetup)

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "api.sandbox.test-id.gr4vy.app")
        XCTAssertEqual(url.path, "/card-details")
    }

    func testCardDetailsURLProduction() throws {
        let url = try Gr4vyUtility.cardDetailsURL(from: productionSetup)

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "api.prod-id.gr4vy.app")
        XCTAssertEqual(url.path, "/card-details")
    }

    func testCardDetailsURLEmptyGr4vyId() throws {
        let invalidSetup = Gr4vySetup(
            gr4vyId: "",
            token: "test-token",
            merchantId: "card-empty-merchant",
            server: .sandbox,
            timeout: 30
        )

        XCTAssertThrowsError(try Gr4vyUtility.cardDetailsURL(from: invalidSetup)) { error in
            XCTAssertTrue(error is Gr4vyError)
            if case .badURL(let message) = error as? Gr4vyError {
                XCTAssertEqual(message, "Gr4vy ID is empty")
            } else {
                XCTFail("Expected badURL error")
            }
        }
    }

    // MARK: - Checkout Session Fields URL Tests
    func testCheckoutSessionFieldsURLSandbox() throws {
        let sessionId = "session-123"
        let url = try Gr4vyUtility.checkoutSessionFieldsURL(from: sandboxSetup, checkoutSessionId: sessionId)

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "api.sandbox.test-id.gr4vy.app")
        XCTAssertEqual(url.path, "/checkout/sessions/\(sessionId)/fields")
    }

    func testCheckoutSessionFieldsURLProduction() throws {
        let sessionId = "session-456"
        let url = try Gr4vyUtility.checkoutSessionFieldsURL(from: productionSetup, checkoutSessionId: sessionId)

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "api.prod-id.gr4vy.app")
        XCTAssertEqual(url.path, "/checkout/sessions/\(sessionId)/fields")
    }

    func testCheckoutSessionFieldsURLEmptyGr4vyId() throws {
        let invalidSetup = Gr4vySetup(
            gr4vyId: "",
            token: "test-token",
            merchantId: "checkout-empty-merchant",
            server: .sandbox,
            timeout: 30
        )

        XCTAssertThrowsError(try Gr4vyUtility.checkoutSessionFieldsURL(from: invalidSetup, checkoutSessionId: "session-123")) { error in
            XCTAssertTrue(error is Gr4vyError)
            if case .badURL(let message) = error as? Gr4vyError {
                XCTAssertEqual(message, "Gr4vy ID is empty")
            } else {
                XCTFail("Expected badURL error")
            }
        }
    }

    func testCheckoutSessionFieldsURLEmptySessionId() throws {
        XCTAssertThrowsError(try Gr4vyUtility.checkoutSessionFieldsURL(from: sandboxSetup, checkoutSessionId: "")) { error in
            XCTAssertTrue(error is Gr4vyError)
            if case .badURL(let message) = error as? Gr4vyError {
                XCTAssertEqual(message, "Checkout session ID is empty")
            } else {
                XCTFail("Expected badURL error")
            }
        }
    }

    // MARK: - Create Transaction URL Tests
    func testCreateTransactionURLSandbox() throws {
        let sessionId = "session-789"
        let url = try Gr4vyUtility.createTransactionURL(from: sandboxSetup, checkoutSessionId: sessionId)

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "api.sandbox.test-id.gr4vy.app")
        XCTAssertEqual(url.path, "/checkout/sessions/\(sessionId)/three-d-secure-authenticate")
    }

    func testCreateTransactionURLProduction() throws {
        let sessionId = "session-101"
        let url = try Gr4vyUtility.createTransactionURL(from: productionSetup, checkoutSessionId: sessionId)

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "api.prod-id.gr4vy.app")
        XCTAssertEqual(url.path, "/checkout/sessions/\(sessionId)/three-d-secure-authenticate")
    }

    func testCreateTransactionURLEmptyGr4vyId() throws {
        let invalidSetup = Gr4vySetup(
            gr4vyId: "",
            token: "test-token",
            merchantId: "transaction-empty-merchant",
            server: .sandbox,
            timeout: 30
        )

        XCTAssertThrowsError(try Gr4vyUtility.createTransactionURL(from: invalidSetup, checkoutSessionId: "session-789")) { error in
            XCTAssertTrue(error is Gr4vyError)
            if case .badURL(let message) = error as? Gr4vyError {
                XCTAssertEqual(message, "Gr4vy ID is empty")
            } else {
                XCTFail("Expected badURL error")
            }
        }
    }

    func testCreateTransactionURLEmptySessionId() throws {
        XCTAssertThrowsError(try Gr4vyUtility.createTransactionURL(from: sandboxSetup, checkoutSessionId: "")) { error in
            XCTAssertTrue(error is Gr4vyError)
            if case .badURL(let message) = error as? Gr4vyError {
                XCTAssertEqual(message, "Checkout session ID is empty")
            } else {
                XCTFail("Expected badURL error")
            }
        }
    }

    // MARK: - Buyers Payment Methods URL Tests
    func testBuyersPaymentMethodsURLSandbox() throws {
        let url = try Gr4vyUtility.buyersPaymentMethodsURL(from: sandboxSetup)

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "api.sandbox.test-id.gr4vy.app")
        XCTAssertEqual(url.path, "/buyers/payment-methods")
    }

    func testBuyersPaymentMethodsURLProduction() throws {
        let url = try Gr4vyUtility.buyersPaymentMethodsURL(from: productionSetup)

        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "api.prod-id.gr4vy.app")
        XCTAssertEqual(url.path, "/buyers/payment-methods")
    }

    func testBuyersPaymentMethodsURLEmptyGr4vyId() throws {
        let invalidSetup = Gr4vySetup(
            gr4vyId: "",
            token: "test-token",
            merchantId: "buyers-empty-merchant",
            server: .sandbox,
            timeout: 30
        )

        XCTAssertThrowsError(try Gr4vyUtility.buyersPaymentMethodsURL(from: invalidSetup)) { error in
            XCTAssertTrue(error is Gr4vyError)
            if case .badURL(let message) = error as? Gr4vyError {
                XCTAssertEqual(message, "Gr4vy ID is empty")
            } else {
                XCTFail("Expected badURL error")
            }
        }
    }

    // MARK: - MerchantId Preservation Tests

    func testSetupMerchantIdPreservationAfterURLGeneration() throws {
        // Verify merchantId is preserved after URL generation calls
        XCTAssertEqual(sandboxSetup.merchantId, "test-merchant")
        XCTAssertEqual(productionSetup.merchantId, "prod-merchant")

        // Generate URLs and verify merchantId is still preserved
        _ = try Gr4vyUtility.paymentOptionsURL(from: sandboxSetup)
        _ = try Gr4vyUtility.cardDetailsURL(from: productionSetup)
        _ = try Gr4vyUtility.buyersPaymentMethodsURL(from: sandboxSetup)
        _ = try Gr4vyUtility.checkoutSessionFieldsURL(from: productionSetup, checkoutSessionId: "test-session")
        _ = try Gr4vyUtility.createTransactionURL(from: sandboxSetup, checkoutSessionId: "test-session-2")

        XCTAssertEqual(sandboxSetup.merchantId, "test-merchant")
        XCTAssertEqual(productionSetup.merchantId, "prod-merchant")
    }

    func testURLGenerationWithNilMerchantId() throws {
        let setupWithNilMerchant = Gr4vySetup(
            gr4vyId: "test-nil-merchant",
            token: "test-token",
            merchantId: nil,
            server: .sandbox,
            timeout: 30
        )

        // URL generation should work fine with nil merchantId
        let paymentOptionsURL = try Gr4vyUtility.paymentOptionsURL(from: setupWithNilMerchant)
        let cardDetailsURL = try Gr4vyUtility.cardDetailsURL(from: setupWithNilMerchant)
        let buyersURL = try Gr4vyUtility.buyersPaymentMethodsURL(from: setupWithNilMerchant)
        let checkoutURL = try Gr4vyUtility.checkoutSessionFieldsURL(from: setupWithNilMerchant, checkoutSessionId: "session-123")
        let transactionURL = try Gr4vyUtility.createTransactionURL(from: setupWithNilMerchant, checkoutSessionId: "session-456")

        // Verify URLs are generated correctly
        XCTAssertEqual(paymentOptionsURL.host, "api.sandbox.test-nil-merchant.gr4vy.app")
        XCTAssertEqual(cardDetailsURL.host, "api.sandbox.test-nil-merchant.gr4vy.app")
        XCTAssertEqual(buyersURL.host, "api.sandbox.test-nil-merchant.gr4vy.app")
        XCTAssertEqual(checkoutURL.host, "api.sandbox.test-nil-merchant.gr4vy.app")
        XCTAssertEqual(transactionURL.host, "api.sandbox.test-nil-merchant.gr4vy.app")

        // Verify merchantId remains nil
        XCTAssertNil(setupWithNilMerchant.merchantId)
    }

    func testURLGenerationWithSpecialCharacterMerchantId() throws {
        let setupWithSpecialMerchant = Gr4vySetup(
            gr4vyId: "special-test",
            token: "test-token",
            merchantId: "merchant-with_special.chars!@#123",
            server: .production,
            timeout: 30
        )

        // URL generation should work fine with special character merchantId
        let paymentOptionsURL = try Gr4vyUtility.paymentOptionsURL(from: setupWithSpecialMerchant)
        let cardDetailsURL = try Gr4vyUtility.cardDetailsURL(from: setupWithSpecialMerchant)
        let buyersURL = try Gr4vyUtility.buyersPaymentMethodsURL(from: setupWithSpecialMerchant)
        let checkoutURL = try Gr4vyUtility.checkoutSessionFieldsURL(from: setupWithSpecialMerchant, checkoutSessionId: "session-456")
        let transactionURL = try Gr4vyUtility.createTransactionURL(from: setupWithSpecialMerchant, checkoutSessionId: "session-789")

        // Verify URLs are generated correctly (merchantId doesn't affect URL generation)
        XCTAssertEqual(paymentOptionsURL.host, "api.special-test.gr4vy.app")
        XCTAssertEqual(cardDetailsURL.host, "api.special-test.gr4vy.app")
        XCTAssertEqual(buyersURL.host, "api.special-test.gr4vy.app")
        XCTAssertEqual(checkoutURL.host, "api.special-test.gr4vy.app")
        XCTAssertEqual(transactionURL.host, "api.special-test.gr4vy.app")

        // Verify merchantId is preserved with special characters
        XCTAssertEqual(setupWithSpecialMerchant.merchantId, "merchant-with_special.chars!@#123")
    }

    func testMultipleSetupObjectsWithDifferentMerchantIds() throws {
        let setup1 = Gr4vySetup(
            gr4vyId: "merchant1-test",
            token: "token1",
            merchantId: "merchant1",
            server: .sandbox,
            timeout: 30
        )

        let setup2 = Gr4vySetup(
            gr4vyId: "merchant2-test",
            token: "token2",
            merchantId: "merchant2",
            server: .production,
            timeout: 45
        )

        let setup3 = Gr4vySetup(
            gr4vyId: "merchant3-test",
            token: "token3",
            merchantId: nil,
            server: .sandbox,
            timeout: 60
        )

        // Generate URLs for all setups
        _ = try Gr4vyUtility.paymentOptionsURL(from: setup1)
        _ = try Gr4vyUtility.cardDetailsURL(from: setup2)
        _ = try Gr4vyUtility.buyersPaymentMethodsURL(from: setup3)

        // Verify each setup maintains its unique merchantId
        XCTAssertEqual(setup1.merchantId, "merchant1")
        XCTAssertEqual(setup2.merchantId, "merchant2")
        XCTAssertNil(setup3.merchantId)

        // Verify other properties are also preserved
        XCTAssertEqual(setup1.gr4vyId, "merchant1-test")
        XCTAssertEqual(setup2.gr4vyId, "merchant2-test")
        XCTAssertEqual(setup3.gr4vyId, "merchant3-test")
    }

    // MARK: - Security Tests

    func testCheckoutSessionURLEncodingSpecialCharacters() throws {
        let testCases = [
            ("session-with-spaces", "session-with-spaces"),
            ("session%20encoded", "session%2520encoded"),
            ("session#fragment", "session%23fragment"),
        ]

        for (input, expectedEncoded) in testCases {
            let url = try Gr4vyUtility.checkoutSessionFieldsURL(from: sandboxSetup, checkoutSessionId: input)
            XCTAssertTrue(url.path.contains(expectedEncoded),
                          "Failed to properly encode '\(input)' - expected '\(expectedEncoded)' in path: \(url.path)")
        }
    }

    func testCreateTransactionURLEncodingSpecialCharacters() throws {
        let testCases = [
            ("session-with-spaces", "session-with-spaces"),
            ("session%20encoded", "session%2520encoded"),
            ("session#fragment", "session%23fragment"),
        ]

        for (input, expectedEncoded) in testCases {
            let url = try Gr4vyUtility.createTransactionURL(from: sandboxSetup, checkoutSessionId: input)
            XCTAssertTrue(url.path.contains(expectedEncoded),
                          "Failed to properly encode '\(input)' - expected '\(expectedEncoded)' in path: \(url.path)")
        }
    }

    func testGr4vyIdValidationRejectsInvalidCharacters() throws {
        let invalidGr4vyIds = [
            "test/id",           // Forward slash
            "test\\id",          // Backslash
            "test id",           // Space
            "test@id",           // At symbol
            "test.id.com",       // Dots (suspicious)
            "test..id",          // Double dots
            "test<script>",      // HTML/JS injection
            "test&param=value",  // Query parameters
            "test#fragment",     // URL fragment
            "test?query",        // Query string
            "test|pipe",         // Pipe character
            "test\"quote",       // Quote character
            "test'quote",        // Single quote
            "test`backtick",     // Backtick
            "test{brace}",       // Braces
            "test[bracket]",     // Brackets
            "test(paren)",       // Parentheses
            "test~tilde",        // Tilde
            "test!exclamation",  // Exclamation
            "test%encoded",      // Percent encoding
            "test+plus",         // Plus sign
            "test=equals",       // Equals sign
            "test:colon",        // Colon
            "test;semicolon",    // Semicolon
            "test,comma",        // Comma
            "test<>brackets",    // Angle brackets
            "-test",             // Starts with hyphen
            "test-",             // Ends with hyphen
            "",                   // Empty string
        ]

        for invalidId in invalidGr4vyIds {
            let invalidSetup = Gr4vySetup(
                gr4vyId: invalidId,
                token: "test-token",
                merchantId: "test-merchant",
                server: .sandbox,
                timeout: 30
            )

            XCTAssertThrowsError(try Gr4vyUtility.paymentOptionsURL(from: invalidSetup)) { error in
                XCTAssertTrue(error is Gr4vyError, "Expected Gr4vyError for invalid gr4vyId: '\(invalidId)'")
                if case let Gr4vyError.badURL(message) = error {
                    XCTAssertTrue(message.contains("empty") || message.contains("invalid") || message.contains("suspicious"),
                                  "Expected security-related error message for '\(invalidId)': \(message)")
                }
            }
        }
    }

    func testGr4vyIdValidationAllowsValidCharacters() throws {
        let validGr4vyIds = [
            "test-id",
            "test_id",
            "testid123",
            "123test",
            "test-123-id",
            "test_123_id",
            "a",
            "1",
            "test-id-with-many-hyphens",
            "test_id_with_many_underscores",
            "UPPERCASE-ID",
            "MiXeD-CaSe-Id",
            "test123456789",
            "very-long-gr4vy-id-that-should-still-be-valid-123456789",
        ]

        for validId in validGr4vyIds {
            let validSetup = Gr4vySetup(
                gr4vyId: validId,
                token: "test-token",
                merchantId: "test-merchant",
                server: .sandbox,
                timeout: 30
            )

            XCTAssertNoThrow(try Gr4vyUtility.paymentOptionsURL(from: validSetup),
                             "Valid gr4vyId should not throw error: '\(validId)'")

            let url = try Gr4vyUtility.paymentOptionsURL(from: validSetup)
            XCTAssertTrue(url.host?.contains(validId) == true,
                          "Valid gr4vyId should be included in hostname: '\(validId)'")
        }
    }

    func testCheckoutSessionEmptyIdRejected() throws {
        XCTAssertThrowsError(try Gr4vyUtility.checkoutSessionFieldsURL(from: sandboxSetup, checkoutSessionId: "")) { error in
            XCTAssertTrue(error is Gr4vyError)
            if case let Gr4vyError.badURL(message) = error {
                XCTAssertTrue(message.contains("empty"), "Expected empty ID error message: \(message)")
            }
        }
    }

    func testURLEncodingHandlesUnicodeCharacters() throws {
        let unicodeIds = [
            "session-测试",
            "session-🚀",
            "session-café",
            "session-naïve",
            "session-résumé",
            "session-москва",
            "session-東京",
            "session-🎯💳",
        ]

        for unicodeId in unicodeIds {
            let url = try Gr4vyUtility.checkoutSessionFieldsURL(from: sandboxSetup, checkoutSessionId: unicodeId)

            // Verify the URL is properly constructed
            XCTAssertNotNil(url.host, "Host should be valid for unicode ID: '\(unicodeId)'")
            XCTAssertTrue(url.path.hasPrefix("/checkout/sessions/"), "Path prefix should be preserved for unicode ID: '\(unicodeId)'")
            XCTAssertTrue(url.path.hasSuffix("/fields"), "Path suffix should be preserved for unicode ID: '\(unicodeId)'")

            // Verify the URL can be reconstructed
            XCTAssertNotNil(URL(string: url.absoluteString), "URL should be valid for unicode ID: '\(unicodeId)'")
        }
    }

    func testSecurityConsistencyAcrossAllMethods() throws {
        // Test that all URL methods use the same validation for gr4vyId
        let invalidSetup = Gr4vySetup(
            gr4vyId: "invalid/id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox,
            timeout: 30
        )

        let methods: [() throws -> URL] = [ { try Gr4vyUtility.paymentOptionsURL(from: invalidSetup) }, { try Gr4vyUtility.cardDetailsURL(from: invalidSetup) }, { try Gr4vyUtility.buyersPaymentMethodsURL(from: invalidSetup) }, { try Gr4vyUtility.checkoutSessionFieldsURL(from: invalidSetup, checkoutSessionId: "valid-session") }, { try Gr4vyUtility.createTransactionURL(from: invalidSetup, checkoutSessionId: "valid-session") }
        ]

        for method in methods {
            XCTAssertThrowsError(try method()) { error in
                XCTAssertTrue(error is Gr4vyError, "All methods should validate gr4vyId consistently")
                if case let Gr4vyError.badURL(message) = error {
                    XCTAssertTrue(message.contains("invalid"), "Expected invalid character error: \(message)")
                }
            }
        }
    }
}
