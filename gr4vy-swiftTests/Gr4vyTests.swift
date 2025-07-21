//
//  Gr4vyTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Enum Tests

    func testGr4vyServerEnum() {
        // Test raw values
        XCTAssertEqual(Gr4vyServer.sandbox.rawValue, "sandbox")
        XCTAssertEqual(Gr4vyServer.production.rawValue, "production")

        // Test initialization from raw values
        XCTAssertEqual(Gr4vyServer(rawValue: "sandbox"), .sandbox)
        XCTAssertEqual(Gr4vyServer(rawValue: "production"), .production)
        XCTAssertNil(Gr4vyServer(rawValue: "invalid"))
    }

    func testGr4vyServerEnumCodable() throws {
        // Test encoding
        let encoder = JSONEncoder()
        let sandboxData = try encoder.encode(Gr4vyServer.sandbox)
        let productionData = try encoder.encode(Gr4vyServer.production)

        XCTAssertEqual(String(data: sandboxData, encoding: .utf8), "\"sandbox\"")
        XCTAssertEqual(String(data: productionData, encoding: .utf8), "\"production\"")

        // Test decoding
        let decoder = JSONDecoder()
        let decodedSandbox = try decoder.decode(Gr4vyServer.self, from: sandboxData)
        let decodedProduction = try decoder.decode(Gr4vyServer.self, from: productionData)

        XCTAssertEqual(decodedSandbox, .sandbox)
        XCTAssertEqual(decodedProduction, .production)
    }

    // MARK: - Gr4vyError Tests

    func testGr4vyErrorDescriptions() {
        // Test all error descriptions
        XCTAssertEqual(Gr4vyError.invalidGr4vyId.errorDescription, "The provided Gr4vy ID is invalid or empty. Please check your configuration.")

        let badURLError = Gr4vyError.badURL("https://invalid.url")
        XCTAssertEqual(badURLError.errorDescription, "Invalid URL configuration: https://invalid.url")

        let httpError = Gr4vyError.httpError(statusCode: 404, responseData: nil, message: "Not Found")
        XCTAssertEqual(httpError.errorDescription, "API request failed with status 404: Not Found")

        let httpErrorNoMessage = Gr4vyError.httpError(statusCode: 500, responseData: nil, message: nil)
        XCTAssertEqual(httpErrorNoMessage.errorDescription, "API request failed with status 500: Unknown error occurred")

        let networkError = Gr4vyError.networkError(URLError(.notConnectedToInternet))
        XCTAssertTrue(networkError.errorDescription?.contains("Network connectivity error") == true)

        let decodingError = Gr4vyError.decodingError("Invalid JSON format")
        XCTAssertEqual(decodingError.errorDescription, "Failed to process server response: Invalid JSON format")
    }

    func testGr4vyErrorEquality() {
        // Test badURL errors
        let badURL1 = Gr4vyError.badURL("test.com")
        let badURL2 = Gr4vyError.badURL("test.com")
        let badURL3 = Gr4vyError.badURL("different.com")

        // Note: These will only be equal if the associated values are the same
        XCTAssertEqual(badURL1.localizedDescription, badURL2.localizedDescription)
        XCTAssertNotEqual(badURL1.localizedDescription, badURL3.localizedDescription)
    }

    // MARK: - Initialization Tests

    func testGr4vyInitializationWithValidParameters() throws {
        // Given
        let gr4vyId = "test_merchant_123"
        let token = "test_token_456"
        let merchantId = "test_merchant_id"
        let server = Gr4vyServer.sandbox
        let timeout: TimeInterval = 45.0
        let debugMode = true

        // When
        let gr4vy = try Gr4vy(
            gr4vyId: gr4vyId,
            token: token,
            merchantId: merchantId,
            server: server,
            timeout: timeout,
            debugMode: debugMode
        )

        // Then
        XCTAssertNotNil(gr4vy.setup)
        XCTAssertEqual(gr4vy.setup?.gr4vyId, gr4vyId)
        XCTAssertEqual(gr4vy.setup?.token, token)
        XCTAssertEqual(gr4vy.setup?.merchantId, merchantId)
        XCTAssertEqual(gr4vy.setup?.server, server)
        XCTAssertEqual(gr4vy.setup?.timeout, timeout)
        XCTAssertEqual(gr4vy.debugMode, debugMode)

        // Verify services are initialized
        XCTAssertNotNil(gr4vy.paymentOptions)
        XCTAssertNotNil(gr4vy.cardDetails)
        XCTAssertNotNil(gr4vy.paymentMethods)
    }

    func testGr4vyInitializationWithNilMerchantId() throws {
        // Given
        let gr4vyId = "test_merchant_123"
        let token = "test_token_456"
        let server = Gr4vyServer.sandbox
        let timeout: TimeInterval = 45.0
        let debugMode = true

        // When
        let gr4vy = try Gr4vy(
            gr4vyId: gr4vyId,
            token: token,
            merchantId: nil,
            server: server,
            timeout: timeout,
            debugMode: debugMode
        )

        // Then
        XCTAssertNotNil(gr4vy.setup)
        XCTAssertEqual(gr4vy.setup?.gr4vyId, gr4vyId)
        XCTAssertEqual(gr4vy.setup?.token, token)
        XCTAssertNil(gr4vy.setup?.merchantId)
        XCTAssertEqual(gr4vy.setup?.server, server)
        XCTAssertEqual(gr4vy.setup?.timeout, timeout)
        XCTAssertEqual(gr4vy.debugMode, debugMode)

        // Verify services are initialized
        XCTAssertNotNil(gr4vy.paymentOptions)
        XCTAssertNotNil(gr4vy.cardDetails)
        XCTAssertNotNil(gr4vy.paymentMethods)
    }

    func testGr4vyInitializationWithDefaultParameters() throws {
        // Given
        let gr4vyId = "test_merchant"
        let token = "test_token"
        let merchantId = "default_merchant"
        let server = Gr4vyServer.production

        // When
        let gr4vy = try Gr4vy(
            gr4vyId: gr4vyId,
            token: token,
            merchantId: merchantId,
            server: server
        )

        // Then
        XCTAssertNotNil(gr4vy.setup)
        XCTAssertEqual(gr4vy.setup?.merchantId, merchantId)
        XCTAssertEqual(gr4vy.setup?.timeout, 30.0) // Default timeout
        XCTAssertFalse(gr4vy.debugMode) // Default debug mode

        // Verify services are initialized
        XCTAssertNotNil(gr4vy.paymentOptions)
        XCTAssertNotNil(gr4vy.cardDetails)
        XCTAssertNotNil(gr4vy.paymentMethods)
    }

    func testGr4vyInitializationWithEmptyGr4vyId() {
        // Given
        let emptyGr4vyId = ""
        let token = "valid_token"
        let merchantId = "valid_merchant"
        let server = Gr4vyServer.sandbox

        // When/Then
        XCTAssertThrowsError(try Gr4vy(gr4vyId: emptyGr4vyId, token: token, merchantId: merchantId, server: server)) { error in
            XCTAssertEqual(error as? Gr4vyError, Gr4vyError.invalidGr4vyId)
        }
    }

    func testGr4vyInitializationWithBothEmptyValues() {
        // Given
        let emptyGr4vyId = ""
        let emptyToken = ""
        let merchantId = "valid_merchant"
        let server = Gr4vyServer.sandbox

        // When/Then - Should throw invalidGr4vyId first (order matters)
        XCTAssertThrowsError(try Gr4vy(gr4vyId: emptyGr4vyId, token: emptyToken, merchantId: merchantId, server: server)) { error in
            XCTAssertEqual(error as? Gr4vyError, Gr4vyError.invalidGr4vyId)
        }
    }

    func testGr4vyInitializationWithDifferentServers() throws {
        let gr4vyId = "test_merchant"
        let token = "test_token"
        let merchantId = "test_merchant_id"

        // Test sandbox
        let sandboxGr4vy = try Gr4vy(gr4vyId: gr4vyId, token: token, merchantId: merchantId, server: .sandbox)
        XCTAssertEqual(sandboxGr4vy.setup?.server, .sandbox)
        XCTAssertEqual(sandboxGr4vy.setup?.merchantId, merchantId)

        // Test production
        let productionGr4vy = try Gr4vy(gr4vyId: gr4vyId, token: token, merchantId: merchantId, server: .production)
        XCTAssertEqual(productionGr4vy.setup?.server, .production)
        XCTAssertEqual(productionGr4vy.setup?.merchantId, merchantId)
    }

    // MARK: - Token Update Tests

    func testUpdateTokenWithValidToken() throws {
        // Given
        let gr4vy = try Gr4vy(gr4vyId: "test", token: "initial_token", merchantId: "test_merchant", server: .sandbox)
        let newToken = "updated_token_123"
        let originalTimeout = gr4vy.setup?.timeout
        let originalMerchantId = gr4vy.setup?.merchantId

        // When
        gr4vy.updateToken(newToken)

        // Then
        XCTAssertEqual(gr4vy.setup?.token, newToken)
        XCTAssertEqual(gr4vy.setup?.gr4vyId, "test") // Should remain unchanged
        XCTAssertEqual(gr4vy.setup?.merchantId, originalMerchantId) // Should remain unchanged
        XCTAssertEqual(gr4vy.setup?.server, .sandbox) // Should remain unchanged
        XCTAssertEqual(gr4vy.setup?.timeout, originalTimeout) // Should remain unchanged
    }

    func testUpdateTokenWithEmptyToken() throws {
        // Given
        let gr4vy = try Gr4vy(gr4vyId: "test", token: "initial_token", merchantId: "test_merchant", server: .production)
        let emptyToken = ""
        let originalMerchantId = gr4vy.setup?.merchantId

        // When
        gr4vy.updateToken(emptyToken)

        // Then - Should still update (no validation in updateToken)
        XCTAssertEqual(gr4vy.setup?.token, emptyToken)
        XCTAssertEqual(gr4vy.setup?.merchantId, originalMerchantId) // Should remain unchanged
    }

    func testUpdateTokenMultipleTimes() throws {
        // Given
        let gr4vy = try Gr4vy(gr4vyId: "test", token: "initial", merchantId: "test_merchant", server: .sandbox)
        let originalMerchantId = gr4vy.setup?.merchantId

        // When
        gr4vy.updateToken("first_update")
        XCTAssertEqual(gr4vy.setup?.token, "first_update")
        XCTAssertEqual(gr4vy.setup?.merchantId, originalMerchantId)

        gr4vy.updateToken("second_update")
        XCTAssertEqual(gr4vy.setup?.token, "second_update")
        XCTAssertEqual(gr4vy.setup?.merchantId, originalMerchantId)

        gr4vy.updateToken("third_update")
        XCTAssertEqual(gr4vy.setup?.token, "third_update")
        XCTAssertEqual(gr4vy.setup?.merchantId, originalMerchantId)
    }

    // MARK: - MerchantId Update Tests

    func testUpdateMerchantIdWithValidMerchantId() throws {
        // Given
        let gr4vy = try Gr4vy(gr4vyId: "test", token: "test_token", merchantId: "initial_merchant", server: .sandbox)
        let newMerchantId = "updated_merchant_123"
        let originalToken = gr4vy.setup?.token
        let originalTimeout = gr4vy.setup?.timeout

        // When
        gr4vy.updateMerchantId(newMerchantId)

        // Then
        XCTAssertEqual(gr4vy.setup?.merchantId, newMerchantId)
        XCTAssertEqual(gr4vy.setup?.gr4vyId, "test") // Should remain unchanged
        XCTAssertEqual(gr4vy.setup?.token, originalToken) // Should remain unchanged
        XCTAssertEqual(gr4vy.setup?.server, .sandbox) // Should remain unchanged
        XCTAssertEqual(gr4vy.setup?.timeout, originalTimeout) // Should remain unchanged
    }

    func testUpdateMerchantIdWithNil() throws {
        // Given
        let gr4vy = try Gr4vy(gr4vyId: "test", token: "test_token", merchantId: "initial_merchant", server: .production)
        let originalToken = gr4vy.setup?.token

        // When
        gr4vy.updateMerchantId(nil)

        // Then
        XCTAssertNil(gr4vy.setup?.merchantId)
        XCTAssertEqual(gr4vy.setup?.token, originalToken) // Should remain unchanged
        XCTAssertEqual(gr4vy.setup?.gr4vyId, "test") // Should remain unchanged
    }

    func testUpdateMerchantIdFromNil() throws {
        // Given
        let gr4vy = try Gr4vy(gr4vyId: "test", token: "test_token", merchantId: nil, server: .sandbox)
        let newMerchantId = "new_merchant_from_nil"
        let originalToken = gr4vy.setup?.token

        // When
        gr4vy.updateMerchantId(newMerchantId)

        // Then
        XCTAssertEqual(gr4vy.setup?.merchantId, newMerchantId)
        XCTAssertEqual(gr4vy.setup?.token, originalToken) // Should remain unchanged
        XCTAssertEqual(gr4vy.setup?.gr4vyId, "test") // Should remain unchanged
    }

    func testUpdateMerchantIdMultipleTimes() throws {
        // Given
        let gr4vy = try Gr4vy(gr4vyId: "test", token: "token", merchantId: "initial", server: .production)
        let originalToken = gr4vy.setup?.token

        // When
        gr4vy.updateMerchantId("first_update")
        XCTAssertEqual(gr4vy.setup?.merchantId, "first_update")
        XCTAssertEqual(gr4vy.setup?.token, originalToken)

        gr4vy.updateMerchantId("second_update")
        XCTAssertEqual(gr4vy.setup?.merchantId, "second_update")
        XCTAssertEqual(gr4vy.setup?.token, originalToken)

        gr4vy.updateMerchantId(nil)
        XCTAssertNil(gr4vy.setup?.merchantId)
        XCTAssertEqual(gr4vy.setup?.token, originalToken)

        gr4vy.updateMerchantId("final_update")
        XCTAssertEqual(gr4vy.setup?.merchantId, "final_update")
        XCTAssertEqual(gr4vy.setup?.token, originalToken)
    }

    func testUpdateTokenAndMerchantIdTogether() throws {
        // Given
        let gr4vy = try Gr4vy(gr4vyId: "test", token: "initial_token", merchantId: "initial_merchant", server: .sandbox)

        // When
        gr4vy.updateToken("new_token")
        gr4vy.updateMerchantId("new_merchant")

        // Then
        XCTAssertEqual(gr4vy.setup?.token, "new_token")
        XCTAssertEqual(gr4vy.setup?.merchantId, "new_merchant")
        XCTAssertEqual(gr4vy.setup?.gr4vyId, "test") // Should remain unchanged

        // When - Update in reverse order
        gr4vy.updateMerchantId("newer_merchant")
        gr4vy.updateToken("newer_token")

        // Then
        XCTAssertEqual(gr4vy.setup?.token, "newer_token")
        XCTAssertEqual(gr4vy.setup?.merchantId, "newer_merchant")
        XCTAssertEqual(gr4vy.setup?.gr4vyId, "test") // Should remain unchanged
    }

    // MARK: - Service Access Tests

    func testServiceInitialization() throws {
        // Given
        let gr4vy = try Gr4vy(
            gr4vyId: "service_test",
            token: "service_token",
            merchantId: "service_merchant",
            server: .sandbox,
            debugMode: true
        )

        // Then - Verify all services are properly initialized
        XCTAssertNotNil(gr4vy.paymentOptions)
        XCTAssertNotNil(gr4vy.cardDetails)
        XCTAssertNotNil(gr4vy.paymentMethods)

        // Services should be accessible
        _ = gr4vy.paymentOptions
        _ = gr4vy.cardDetails
        _ = gr4vy.paymentMethods
    }

    func testDebugModeProperty() throws {
        // Test debug mode false
        let gr4vyFalse = try Gr4vy(gr4vyId: "test", token: "token", merchantId: "merchant", server: .sandbox, debugMode: false)
        XCTAssertFalse(gr4vyFalse.debugMode)

        // Test debug mode true
        let gr4vyTrue = try Gr4vy(gr4vyId: "test", token: "token", merchantId: "merchant", server: .production, debugMode: true)
        XCTAssertTrue(gr4vyTrue.debugMode)

        // Test debug mode mutation
        gr4vyFalse.debugMode = true
        XCTAssertTrue(gr4vyFalse.debugMode)

        gr4vyTrue.debugMode = false
        XCTAssertFalse(gr4vyTrue.debugMode)
    }

    // MARK: - Tokenization Tests

    func testTokenizeAsyncMethod() async throws {
        // Given
        let gr4vy = try Gr4vy(gr4vyId: "test", token: "token", merchantId: "tokenize_merchant", server: .sandbox)
        let checkoutSessionId = "session_123"
        let cardData = Gr4vyCardData(paymentMethod: .card(.init(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))

        // Note: This will likely fail in actual execution because we don't have a real backend
        // But we're testing that the method exists and can be called
        do {
            try await gr4vy.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
            // If we get here, the method executed without throwing immediately
        } catch {
            // Expected to fail in tests due to no real backend
            // We're just testing the method signature and that it forwards to the service
        }
    }

    func testTokenizeCompletionMethod() throws {
        // Given
        let gr4vy = try Gr4vy(gr4vyId: "test", token: "token", merchantId: "completion_merchant", server: .production)
        let checkoutSessionId = "session_456"
        let cardData = Gr4vyCardData(paymentMethod: .card(.init(
            number: "5555555555554444",
            expirationDate: "06/26",
            securityCode: "456"
        )))

        let expectation = XCTestExpectation(description: "Tokenize completion called")

        // When
        gr4vy.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData) { _ in
            // Expected to fail in tests, but completion should be called
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Edge Cases Tests

    func testGr4vyWithSpecialCharacters() throws {
        // Given
        let specialGr4vyId = "merchant-123_test!@#$%"
        let specialToken = "token_with-special.chars123!@#"
        let specialMerchantId = "merchant_with-special.chars!@#456"

        // When
        let gr4vy = try Gr4vy(
            gr4vyId: specialGr4vyId,
            token: specialToken,
            merchantId: specialMerchantId,
            server: .sandbox
        )

        // Then
        XCTAssertEqual(gr4vy.setup?.gr4vyId, specialGr4vyId)
        XCTAssertEqual(gr4vy.setup?.token, specialToken)
        XCTAssertEqual(gr4vy.setup?.merchantId, specialMerchantId)
    }

    func testGr4vyWithVeryLongStrings() throws {
        // Given
        let longGr4vyId = String(repeating: "a", count: 1_000)
        let longToken = String(repeating: "b", count: 2_000)
        let longMerchantId = String(repeating: "c", count: 1_500)

        // When
        let gr4vy = try Gr4vy(
            gr4vyId: longGr4vyId,
            token: longToken,
            merchantId: longMerchantId,
            server: .production
        )

        // Then
        XCTAssertEqual(gr4vy.setup?.gr4vyId, longGr4vyId)
        XCTAssertEqual(gr4vy.setup?.token, longToken)
        XCTAssertEqual(gr4vy.setup?.merchantId, longMerchantId)
    }

    func testGr4vyWithEmptyMerchantId() throws {
        // Given
        let gr4vyId = "test_merchant"
        let token = "test_token"
        let emptyMerchantId = ""

        // When
        let gr4vy = try Gr4vy(
            gr4vyId: gr4vyId,
            token: token,
            merchantId: emptyMerchantId,
            server: .sandbox
        )

        // Then
        XCTAssertEqual(gr4vy.setup?.gr4vyId, gr4vyId)
        XCTAssertEqual(gr4vy.setup?.token, token)
        XCTAssertEqual(gr4vy.setup?.merchantId, emptyMerchantId)
    }

    func testGr4vyWithMerchantIdEdgeCases() throws {
        // Test various merchantId edge cases
        let testCases: [(String, String?)] = [
            ("nil_merchant", nil),
            ("empty_merchant", ""),
            ("space_merchant", " "),
            ("tab_merchant", "\t"),
            ("newline_merchant", "\n"),
            ("unicode_merchant", "merchant_测试_🚀"),
            ("numeric_merchant", "12345"),
            ("hyphen_merchant", "merchant-123-test"),
            ("underscore_merchant", "merchant_123_test"),
            ("dot_merchant", "merchant.123.test"),
        ]

        for (testName, merchantId) in testCases {
            // When
            let gr4vy = try Gr4vy(
                gr4vyId: testName,
                token: "test_token",
                merchantId: merchantId,
                server: .sandbox
            )

            // Then
            XCTAssertEqual(gr4vy.setup?.merchantId, merchantId, "Failed for test case: \(testName)")
            XCTAssertEqual(gr4vy.setup?.gr4vyId, testName)
        }
    }

    func testGr4vyWithExtremeTimeoutValues() throws {
        // Test zero timeout
        let zeroTimeoutGr4vy = try Gr4vy(
            gr4vyId: "test",
            token: "token",
            merchantId: "zero_merchant",
            server: .sandbox,
            timeout: 0.0
        )
        XCTAssertEqual(zeroTimeoutGr4vy.setup?.timeout, 0.0)
        XCTAssertEqual(zeroTimeoutGr4vy.setup?.merchantId, "zero_merchant")

        // Test negative timeout
        let negativeTimeoutGr4vy = try Gr4vy(
            gr4vyId: "test",
            token: "token",
            merchantId: "negative_merchant",
            server: .production,
            timeout: -10.0
        )
        XCTAssertEqual(negativeTimeoutGr4vy.setup?.timeout, -10.0)
        XCTAssertEqual(negativeTimeoutGr4vy.setup?.merchantId, "negative_merchant")

        // Test very large timeout
        let largeTimeoutGr4vy = try Gr4vy(
            gr4vyId: "test",
            token: "token",
            merchantId: "large_merchant",
            server: .sandbox,
            timeout: 999_999.0
        )
        XCTAssertEqual(largeTimeoutGr4vy.setup?.timeout, 999_999.0)
        XCTAssertEqual(largeTimeoutGr4vy.setup?.merchantId, "large_merchant")
    }

    // MARK: - Memory Management Tests

    func testGr4vyMemoryManagement() throws {
        // Test that Gr4vy instances can be created and released properly
        weak var weakGr4vy: Gr4vy?

        autoreleasepool {
            do {
                let gr4vy = try Gr4vy(gr4vyId: "memory_test", token: "token", merchantId: "memory_merchant", server: .sandbox)
                weakGr4vy = gr4vy
                XCTAssertNotNil(weakGr4vy)
            } catch {
                XCTFail("Gr4vy initialization should not fail: \(error)")
            }
        }

        // After autoreleasepool, the instance should be deallocated
        XCTAssertNil(weakGr4vy)
    }
}
