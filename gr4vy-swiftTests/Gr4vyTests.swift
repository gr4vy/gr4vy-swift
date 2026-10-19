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
        let mockSession = MockURLSession()
        mockSession.mockData = Data("{}".utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test.gr4vy.app/checkout/sessions/session_123/fields")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let gr4vy = try Gr4vy(
            gr4vyId: "test",
            token: "token",
            merchantId: "tokenize_merchant",
            server: .sandbox,
            session: mockSession
        )
        let checkoutSessionId = "session_123"
        let cardData = Gr4vyCardData(paymentMethod: .card(.init(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))

        // When
        try await gr4vy.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
        
        // Then - Verify request was made
        XCTAssertNotNil(mockSession.lastRequest)
        XCTAssertEqual(mockSession.lastRequest?.httpMethod, "PUT")
        XCTAssertTrue(mockSession.lastRequest?.url?.absoluteString.contains("session_123") == true)
    }

    func testTokenizeCompletionMethod() throws {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = Data("{}".utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.test.gr4vy.app/checkout/sessions/session_456/fields")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let gr4vy = try Gr4vy(
            gr4vyId: "test",
            token: "token",
            merchantId: "completion_merchant",
            server: .production,
            session: mockSession
        )
        let checkoutSessionId = "session_456"
        let cardData = Gr4vyCardData(paymentMethod: .card(.init(
            number: "5555555555554444",
            expirationDate: "06/26",
            securityCode: "456"
        )))

        let expectation = XCTestExpectation(description: "Tokenize completion called")

        // When
        gr4vy.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData) { result in
            // Then
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Tokenize should succeed with mock session: \(error)")
            }
        }

        // Then
        wait(for: [expectation], timeout: 5.0)
        
        // Verify request was made
        XCTAssertNotNil(mockSession.lastRequest)
        XCTAssertEqual(mockSession.lastRequest?.httpMethod, "PUT")
        XCTAssertTrue(mockSession.lastRequest?.url?.absoluteString.contains("session_456") == true)
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

    // MARK: - Preferred Scheme Tests

    /// Session answering every request with 204 + empty body: PUT /fields succeeds, versioning gets 204 No Content.
    private func makeNoContentSession() throws -> MockURLSession {
        let session = MockURLSession()
        session.mockData = Data()
        session.mockResponse = try XCTUnwrap(
            HTTPURLResponse(
                url: try XCTUnwrap(URL(string: "https://api.sandbox.test.gr4vy.app")),
                statusCode: 204,
                httpVersion: nil,
                headerFields: nil
            )
        )
        return session
    }

    private func makePreferredSchemeCardData() -> Gr4vyCardData {
        Gr4vyCardData(paymentMethod: .card(.init(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
    }

    /// Forwarding + contract test only: the public overload sends `preferred_scheme` and a versioning 204 gives
    /// `attempted == false` without an error. It can't tell the explicit 204 branch from the catch-all; the
    /// regression guard is `Gr4vyCheckoutSessionServiceTests.testCallVersioningReturnsNilOnHTTP204`.
    func testTokenizeAsyncWithViewControllerForwardsPreferredScheme() async throws {
        // Given
        let session = try makeNoContentSession()
        let gr4vy = try Gr4vy(
            gr4vyId: "test",
            token: "token",
            merchantId: "preferred_scheme_merchant",
            server: .sandbox,
            session: session
        )

        // When
        let result = try await gr4vy.tokenize(
            checkoutSessionId: "session_preferred_scheme_async",
            cardData: makePreferredSchemeCardData(),
            viewController: UIViewController(),
            sdkMaxTimeoutMinutes: 5,
            authenticate: true,
            preferredScheme: "cartes-bancaires"
        )

        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertFalse(result.authentication?.attempted ?? true)
        XCTAssertEqual(session.lastRequest?.httpMethod, "GET")
        XCTAssertEqual(session.lastRequest?.url?.query, "preferred_scheme=cartes-bancaires")
    }

    /// Forwarding + contract test only: the public overload sends `preferred_scheme` and a versioning 204 gives
    /// `attempted == false` without an error. It can't tell the explicit 204 branch from the catch-all; the
    /// regression guard is `Gr4vyCheckoutSessionServiceTests.testCallVersioningReturnsNilOnHTTP204`.
    func testTokenizeCompletionWithViewControllerForwardsPreferredScheme() throws {
        // Given
        let session = try makeNoContentSession()
        let gr4vy = try Gr4vy(
            gr4vyId: "test",
            token: "token",
            merchantId: "preferred_scheme_merchant",
            server: .sandbox,
            session: session
        )
        let expectation = XCTestExpectation(description: "Tokenize with preferredScheme completion called")

        // When
        gr4vy.tokenize(
            checkoutSessionId: "session_preferred_scheme_completion",
            cardData: makePreferredSchemeCardData(),
            viewController: UIViewController(),
            sdkMaxTimeoutMinutes: 5,
            authenticate: true,
            preferredScheme: "cartes-bancaires"
        ) { result in
            // Then
            switch result {
            case .success(let tokenizeResult):
                XCTAssertTrue(tokenizeResult.tokenized)
                XCTAssertFalse(tokenizeResult.authentication?.attempted ?? true)
            case .failure(let error):
                XCTFail("Tokenize should succeed with a 204 versioning response: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(session.lastRequest?.httpMethod, "GET")
        XCTAssertEqual(session.lastRequest?.url?.query, "preferred_scheme=cartes-bancaires")
    }

    /// Records every request. The versioning GET is answered with `versioningStatus` (or fails with
    /// `versioningError`); every other request gets 204. All bodies are empty.
    private final class RecordingURLSession: URLSessionProtocol {
        var versioningStatus = 204
        var versioningError: Error?

        private let lock = NSLock()
        private var recorded: [URLRequest] = []

        var requests: [URLRequest] { lock.withLock { recorded } }
        var versioningURLs: [URL] {
            requests.compactMap(\.url).filter { $0.path.hasSuffix("/three-d-secure-version") }
        }

        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            lock.withLock { recorded.append(request) }
            let url = try XCTUnwrap(request.url)
            let isVersioning = url.path.hasSuffix("/three-d-secure-version")
            if isVersioning, let versioningError {
                throw versioningError
            }
            let response = try XCTUnwrap(
                HTTPURLResponse(url: url, statusCode: isVersioning ? versioningStatus : 204, httpVersion: nil, headerFields: nil)
            )
            return (Data(), response)
        }
    }

    private func makePreferredSchemeGr4vy(session: URLSessionProtocol) throws -> Gr4vy {
        try Gr4vy(
            gr4vyId: "test",
            token: "token",
            merchantId: "preferred_scheme_merchant",
            server: .sandbox,
            session: session
        )
    }

    /// The exact result for "3DS requested but not attempted".
    private func assertUnattempted(_ result: Gr4vyTokenizeResult, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(result.tokenized, file: file, line: line)
        guard let authentication = result.authentication else {
            XCTFail("Expected an unattempted authentication, got nil", file: file, line: line)
            return
        }
        XCTAssertFalse(authentication.attempted, file: file, line: line)
        XCTAssertNil(authentication.type, file: file, line: line)
        XCTAssertNil(authentication.transactionStatus, file: file, line: line)
        XCTAssertFalse(authentication.hasCancelled, file: file, line: line)
        XCTAssertFalse(authentication.hasTimedOut, file: file, line: line)
        XCTAssertNil(authentication.cardholderInfo, file: file, line: line)
    }

    func testTokenizeAsyncWithEmptyPreferredSchemeSendsNoQuery() async throws {
        let session = RecordingURLSession()

        let result = try await makePreferredSchemeGr4vy(session: session).tokenize(
            checkoutSessionId: "session_preferred_scheme",
            cardData: makePreferredSchemeCardData(),
            viewController: UIViewController(),
            sdkMaxTimeoutMinutes: 5,
            authenticate: true,
            preferredScheme: ""
        )

        assertUnattempted(result)
        XCTAssertEqual(session.versioningURLs.count, 1)
        XCTAssertNil(session.versioningURLs.first?.query)
    }

    func testTokenizeAsyncDeliversReservedAndNonASCIIPreferredSchemeEncoded() async throws {
        let session = RecordingURLSession()
        let scheme = "Carte Bancaire & Co=1#x%2F/é"

        let result = try await makePreferredSchemeGr4vy(session: session).tokenize(
            checkoutSessionId: "session_preferred_scheme",
            cardData: makePreferredSchemeCardData(),
            viewController: UIViewController(),
            sdkMaxTimeoutMinutes: 5,
            authenticate: true,
            preferredScheme: scheme
        )

        assertUnattempted(result)
        let url = try XCTUnwrap(session.versioningURLs.first)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let query = try XCTUnwrap(components.percentEncodedQuery)
        XCTAssertEqual(components.queryItems?.count, 1)
        XCTAssertEqual(components.queryItems?.first?.value, scheme)
        XCTAssertNil(url.fragment)
        XCTAssertTrue(query.unicodeScalars.allSatisfy { $0.value > 0x20 && $0.value < 0x7F }, "Query must be printable ASCII: \(query)")
    }

    func testTokenizeAsyncSendsUnknownPreferredSchemeVerbatim() async throws {
        let session = RecordingURLSession()

        let result = try await makePreferredSchemeGr4vy(session: session).tokenize(
            checkoutSessionId: "session_preferred_scheme",
            cardData: makePreferredSchemeCardData(),
            viewController: UIViewController(),
            sdkMaxTimeoutMinutes: 5,
            authenticate: true,
            preferredScheme: "Not-A-Real-Scheme"
        )

        assertUnattempted(result)
        XCTAssertEqual(session.versioningURLs.first?.query, "preferred_scheme=Not-A-Real-Scheme")
    }

    func testTokenizeDoesNotLeakPreferredSchemeBetweenCalls() async throws {
        let session = RecordingURLSession()
        let gr4vy = try makePreferredSchemeGr4vy(session: session)
        let viewController = UIViewController()

        _ = try await gr4vy.tokenize(
            checkoutSessionId: "session_preferred_scheme",
            cardData: makePreferredSchemeCardData(),
            viewController: viewController,
            sdkMaxTimeoutMinutes: 5,
            authenticate: true,
            preferredScheme: "cartes-bancaires"
        )
        _ = try await gr4vy.tokenize(
            checkoutSessionId: "session_preferred_scheme",
            cardData: makePreferredSchemeCardData(),
            viewController: viewController,
            sdkMaxTimeoutMinutes: 5,
            authenticate: true
        )
        _ = try await gr4vy.tokenize(
            checkoutSessionId: "session_preferred_scheme",
            cardData: makePreferredSchemeCardData(),
            viewController: viewController,
            sdkMaxTimeoutMinutes: 5,
            authenticate: true,
            preferredScheme: "visa"
        )

        XCTAssertEqual(session.versioningURLs.map(\.query), ["preferred_scheme=cartes-bancaires", nil, "preferred_scheme=visa"])
    }

    func testTokenizeSendsPreferredSchemeOnlyOnVersioningRequest() async throws {
        let session = RecordingURLSession()

        _ = try await makePreferredSchemeGr4vy(session: session).tokenize(
            checkoutSessionId: "session_preferred_scheme",
            cardData: makePreferredSchemeCardData(),
            viewController: UIViewController(),
            sdkMaxTimeoutMinutes: 5,
            authenticate: true,
            preferredScheme: "cartes-bancaires"
        )

        let fields = try XCTUnwrap(session.requests.first { $0.url?.path.hasSuffix("/fields") == true })
        XCTAssertEqual(fields.httpMethod, "PUT")
        XCTAssertNil(fields.url?.query)
        let body = try XCTUnwrap(fields.httpBody.flatMap { String(bytes: $0, encoding: .utf8) })
        XCTAssertFalse(body.contains("preferred_scheme"))
        XCTAssertFalse(body.contains("preferredScheme"))
        XCTAssertFalse(body.contains("cartes-bancaires"))
    }

    func testTokenizeAsyncVersioningHTTP500ReturnsUnattempted() async throws {
        let session = RecordingURLSession()
        session.versioningStatus = 500

        let result = try await makePreferredSchemeGr4vy(session: session).tokenize(
            checkoutSessionId: "session_preferred_scheme",
            cardData: makePreferredSchemeCardData(),
            viewController: UIViewController(),
            sdkMaxTimeoutMinutes: 5,
            authenticate: true,
            preferredScheme: "cartes-bancaires"
        )

        assertUnattempted(result)
    }

    func testTokenizeAsyncVersioningNetworkErrorReturnsUnattempted() async throws {
        let session = RecordingURLSession()
        session.versioningError = URLError(.notConnectedToInternet)

        let result = try await makePreferredSchemeGr4vy(session: session).tokenize(
            checkoutSessionId: "session_preferred_scheme",
            cardData: makePreferredSchemeCardData(),
            viewController: UIViewController(),
            sdkMaxTimeoutMinutes: 5,
            authenticate: true,
            preferredScheme: "cartes-bancaires"
        )

        assertUnattempted(result)
    }

    func testTokenizeAsyncVersioning200WithEmptyBodyReturnsUnattempted() async throws {
        let session = RecordingURLSession()
        session.versioningStatus = 200

        let result = try await makePreferredSchemeGr4vy(session: session).tokenize(
            checkoutSessionId: "session_preferred_scheme",
            cardData: makePreferredSchemeCardData(),
            viewController: UIViewController(),
            sdkMaxTimeoutMinutes: 5,
            authenticate: true,
            preferredScheme: "cartes-bancaires"
        )

        assertUnattempted(result)
    }

    func testTokenizeCompletionTrailingClosureWithoutPreferredSchemeSendsNoQuery() throws {
        let session = RecordingURLSession()
        let gr4vy = try makePreferredSchemeGr4vy(session: session)
        let expectation = XCTestExpectation(description: "Tokenize without preferredScheme completion called")

        // Existing trailing-closure call shape, without the new parameter
        gr4vy.tokenize(
            checkoutSessionId: "session_preferred_scheme",
            cardData: makePreferredSchemeCardData(),
            viewController: UIViewController(),
            sdkMaxTimeoutMinutes: 5,
            authenticate: true
        ) { result in
            switch result {
            case .success(let tokenizeResult):
                self.assertUnattempted(tokenizeResult)
            case .failure(let error):
                XCTFail("Tokenize should succeed with a 204 versioning response: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(session.versioningURLs.count, 1)
        XCTAssertNil(session.versioningURLs.first?.query)
    }

    /// The overloads without `viewController` resolve a presenter from the key window, which the unit-test host
    /// doesn't have, so they're not invoked. This proves they accept `preferredScheme`; forwarding is checked in review.
    func testTokenizeConvenienceOverloadsAcceptPreferredScheme() throws {
        let session = RecordingURLSession()
        let gr4vy = try makePreferredSchemeGr4vy(session: session)
        let cardData = makePreferredSchemeCardData()

        let asyncCall: () async throws -> Gr4vyTokenizeResult = {
            try await gr4vy.tokenize(
                checkoutSessionId: "session_preferred_scheme",
                cardData: cardData,
                sdkMaxTimeoutMinutes: 5,
                authenticate: true,
                uiCustomization: nil,
                preferredScheme: "cartes-bancaires"
            )
        }
        let completionCall: () -> Void = {
            gr4vy.tokenize(
                checkoutSessionId: "session_preferred_scheme",
                cardData: cardData,
                sdkMaxTimeoutMinutes: 5,
                authenticate: true,
                uiCustomization: nil,
                preferredScheme: "cartes-bancaires"
            ) { _ in }
        }

        _ = asyncCall
        _ = completionCall
        XCTAssertTrue(session.requests.isEmpty)
    }
}
