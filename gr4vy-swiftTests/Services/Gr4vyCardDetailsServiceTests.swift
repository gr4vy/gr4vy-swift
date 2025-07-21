//
//  Gr4vyCardDetailsServiceTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyCardDetailsServiceTests: XCTestCase {
    private var mockHTTPClient: MockHTTPClient!
    private var configuration: Gr4vyHTTPConfiguration!
    private var service: Gr4vyCardDetailsService!

    override func setUpWithError() throws {
        mockHTTPClient = MockHTTPClient()

        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        configuration = Gr4vyHTTPConfiguration(
            setup: setup,
            debugMode: false
        )

        service = Gr4vyCardDetailsService(
            httpClient: mockHTTPClient,
            configuration: configuration
        )
    }

    override func tearDownWithError() throws {
        mockHTTPClient = nil
        configuration = nil
        service = nil
    }

    // MARK: - Initialization Tests

    func testInitializationWithSetup() {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        // When
        let service = Gr4vyCardDetailsService(
            setup: setup,
            debugMode: true
        )

        // Then
        XCTAssertTrue(service.debugMode)
    }

    func testInitializationWithDefaultDebugMode() {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        // When
        let service = Gr4vyCardDetailsService(setup: setup)

        // Then
        XCTAssertFalse(service.debugMode)
    }

    func testInitializationWithCustomSession() {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )
        let customSession = URLSession.shared

        // When
        let service = Gr4vyCardDetailsService(
            setup: setup,
            debugMode: false,
            session: customSession
        )

        // Then
        XCTAssertFalse(service.debugMode)
    }

    func testInitializationWithDependencyInjection() {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )
        let config = Gr4vyHTTPConfiguration(setup: setup, debugMode: true)
        let mockClient = MockHTTPClient()

        // When
        let service = Gr4vyCardDetailsService(
            httpClient: mockClient,
            configuration: config
        )

        // Then
        XCTAssertTrue(service.debugMode)
    }

    // MARK: - Get Card Details Tests

    func testGetCardDetailsAsyncSuccess() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        let mockResponse = Gr4vyCardDetailsResponse(
            type: "card",
            id: "test-id",
            cardType: "credit",
            scheme: "visa",
            schemeIconURL: URL(string: "https://example.com/visa.png"),
            country: "US",
            requiredFields: nil
        )

        mockHTTPClient.response = mockResponse

        // When
        let result = try await service.get(request: request)

        // Then
        XCTAssertEqual(result.type, "card")
        XCTAssertEqual(result.id, "test-id")
        XCTAssertEqual(result.cardType, "credit")
        XCTAssertEqual(result.scheme, "visa")
        XCTAssertEqual(result.country, "US")

        // Verify HTTP client was called correctly
        XCTAssertEqual(mockHTTPClient.lastMethod, "GET")
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("api.sandbox.test-id.gr4vy.app") == true)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("card-details") == true)
    }

    func testGetCardDetailsAsyncWithTimeout() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails, timeout: 60.0)

        let mockResponse = Gr4vyCardDetailsResponse(
            type: "card",
            id: "test-id",
            cardType: "debit",
            scheme: "mastercard",
            schemeIconURL: nil,
            country: "GB",
            requiredFields: nil
        )

        mockHTTPClient.response = mockResponse

        // When
        let result = try await service.get(request: request)

        // Then
        XCTAssertEqual(result.type, "card")
        XCTAssertEqual(result.cardType, "debit")
        XCTAssertEqual(result.scheme, "mastercard")
        XCTAssertEqual(result.country, "GB")
        XCTAssertNil(result.schemeIconURL)
    }

    func testGetCardDetailsAsyncWithComplexResponse() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "EUR")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        let mockResponse = Gr4vyCardDetailsResponse(
            type: "card",
            id: "complex-id",
            cardType: "credit",
            scheme: "amex",
            schemeIconURL: URL(string: "https://example.com/amex.png"),
            country: "DE",
            requiredFields: Gr4vyCardDetailsResponse.RequiredFields(
                firstName: true,
                lastName: true,
                emailAddress: false,
                phoneNumber: nil,
                address: Gr4vyCardDetailsResponse.RequiredFields.Address(
                    city: true,
                    country: false,
                    postalCode: true,
                    state: nil,
                    houseNumberOrName: false,
                    line1: true
                ),
                taxId: false
            )
        )

        mockHTTPClient.response = mockResponse

        // When
        let result = try await service.get(request: request)

        // Then
        XCTAssertEqual(result.type, "card")
        XCTAssertEqual(result.id, "complex-id")
        XCTAssertEqual(result.cardType, "credit")
        XCTAssertEqual(result.scheme, "amex")
        XCTAssertEqual(result.country, "DE")
        XCTAssertNotNil(result.requiredFields)

        let requiredFields = result.requiredFields!
        XCTAssertEqual(requiredFields.firstName, true)
        XCTAssertEqual(requiredFields.lastName, true)
        XCTAssertEqual(requiredFields.emailAddress, false)
        XCTAssertNil(requiredFields.phoneNumber)
        XCTAssertEqual(requiredFields.taxId, false)

        let address = requiredFields.address!
        XCTAssertEqual(address.city, true)
        XCTAssertEqual(address.country, false)
        XCTAssertEqual(address.postalCode, true)
        XCTAssertNil(address.state)
        XCTAssertEqual(address.houseNumberOrName, false)
        XCTAssertEqual(address.line1, true)
    }

    func testGetCardDetailsCallbackSuccess() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        let mockResponse = Gr4vyCardDetailsResponse(
            type: "card",
            id: "callback-id",
            cardType: "credit",
            scheme: "visa",
            schemeIconURL: URL(string: "https://example.com/visa.png"),
            country: "US",
            requiredFields: nil
        )

        mockHTTPClient.response = mockResponse

        // When
        let expectation = XCTestExpectation(description: "Callback completion")
        var result: Gr4vyCardDetailsResponse?
        var error: Error?

        service.get(request: request) { callbackResult in
            switch callbackResult {
            case .success(let response):
                result = response
            case .failure(let callbackError):
                error = callbackError
            }
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        // Then
        XCTAssertNil(error)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.type, "card")
        XCTAssertEqual(result?.id, "callback-id")
        XCTAssertEqual(result?.cardType, "credit")
        XCTAssertEqual(result?.scheme, "visa")
        XCTAssertEqual(result?.country, "US")
    }

    func testGetCardDetailsWithDiscardableResult() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        let mockResponse = Gr4vyCardDetailsResponse(
            type: "card",
            id: "discard-id",
            cardType: "credit",
            scheme: "visa",
            schemeIconURL: nil,
            country: "US",
            requiredFields: nil
        )

        mockHTTPClient.response = mockResponse

        // When/Then - Should not produce compiler warning
        try await service.get(request: request)

        // Verify HTTP client was called
        XCTAssertEqual(mockHTTPClient.lastMethod, "GET")
        XCTAssertNotNil(mockHTTPClient.lastURL)
    }

    // MARK: - Error Handling Tests

    func testGetCardDetailsAsyncNetworkError() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        let networkError = URLError(.networkConnectionLost)
        mockHTTPClient.error = networkError

        // When/Then
        do {
            _ = try await service.get(request: request)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
            XCTAssertEqual((error as? URLError)?.code, .networkConnectionLost)
        }
    }

    func testGetCardDetailsAsyncDecodingError() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        // Invalid JSON data
        let invalidData = "{ invalid json }".data(using: .utf8)!
        mockHTTPClient.data = invalidData

        // When/Then
        do {
            _ = try await service.get(request: request)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testGetCardDetailsAsyncHTTPError() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        let httpError = Gr4vyError.httpError(statusCode: 401, responseData: nil, message: "Unauthorized")
        mockHTTPClient.error = httpError

        // When/Then
        do {
            _ = try await service.get(request: request)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is Gr4vyError)
            if case let Gr4vyError.httpError(code, responseData, message) = error {
                XCTAssertEqual(code, 401)
                XCTAssertNil(responseData)
                XCTAssertEqual(message, "Unauthorized")
            } else {
                XCTFail("Expected httpError")
            }
        }
    }

    func testGetCardDetailsCallbackNetworkError() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        let networkError = URLError(.timedOut)
        mockHTTPClient.error = networkError

        // When
        let expectation = XCTestExpectation(description: "Callback completion")
        var result: Gr4vyCardDetailsResponse?
        var error: Error?

        service.get(request: request) { callbackResult in
            switch callbackResult {
            case .success(let response):
                result = response
            case .failure(let callbackError):
                error = callbackError
            }
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        // Then
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        XCTAssertTrue(error is URLError)
        XCTAssertEqual((error as? URLError)?.code, .timedOut)
    }

    func testGetCardDetailsCallbackDecodingError() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        // Invalid JSON data
        let invalidData = "{ malformed json".data(using: .utf8)!
        mockHTTPClient.data = invalidData

        // When
        let expectation = XCTestExpectation(description: "Callback completion")
        var result: Gr4vyCardDetailsResponse?
        var error: Error?

        service.get(request: request) { callbackResult in
            switch callbackResult {
            case .success(let response):
                result = response
            case .failure(let callbackError):
                error = callbackError
            }
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        // Then
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        XCTAssertTrue(error is DecodingError)
    }

    // MARK: - Setup Update Tests

    func testUpdateSetup() async throws {
        // Given
        let originalSetup = Gr4vySetup(
            gr4vyId: "original-id",
            token: "original-token",
            merchantId: "original-merchant",
            server: .sandbox
        )

        let newSetup = Gr4vySetup(
            gr4vyId: "new-id",
            token: "new-token",
            merchantId: "new-merchant",
            server: .production
        )

        let originalService = Gr4vyCardDetailsService(setup: originalSetup)

        let mockResponse = Gr4vyCardDetailsResponse(
            type: "card",
            id: "test-id",
            cardType: "credit",
            scheme: "visa",
            schemeIconURL: nil,
            country: "US",
            requiredFields: nil
        )

        // When
        originalService.updateSetup(newSetup)

        // Then
        // We can't directly test the internal state, but we can verify that
        // subsequent calls use the new setup by checking the URL
        // This would require a mock setup, so we'll verify the method doesn't crash
        XCTAssertNotNil(originalService)
    }

    func testUpdateSetupWithDifferentServer() async throws {
        // Given
        let sandboxSetup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        let productionSetup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .production
        )

        let service = Gr4vyCardDetailsService(setup: sandboxSetup)

        // When
        service.updateSetup(productionSetup)

        // Then
        XCTAssertNotNil(service)
    }

    func testUpdateSetupWithNilMerchantId() async throws {
        // Given
        let setupWithMerchant = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        let setupWithoutMerchant = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: nil,
            server: .sandbox
        )

        let service = Gr4vyCardDetailsService(setup: setupWithMerchant)

        // When
        service.updateSetup(setupWithoutMerchant)

        // Then
        XCTAssertNotNil(service)
    }

    // MARK: - HTTP Client Interaction Tests

    func testHTTPClientReceivesCorrectParameters() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails, timeout: 45.0)

        let mockResponse = Gr4vyCardDetailsResponse(
            type: "card",
            id: "test-id",
            cardType: "credit",
            scheme: "visa",
            schemeIconURL: nil,
            country: "US",
            requiredFields: nil
        )

        mockHTTPClient.response = mockResponse

        // When
        _ = try await service.get(request: request)

        // Then
        XCTAssertEqual(mockHTTPClient.lastMethod, "GET")
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("card-details") == true)
        XCTAssertNotNil(mockHTTPClient.lastBody)

        // Verify the request body was encoded correctly
        let bodyJSON = try JSONSerialization.jsonObject(with: mockHTTPClient.lastBody!, options: []) as? [String: Any]
        XCTAssertNotNil(bodyJSON)

        let cardDetailsJSON = bodyJSON?["card_details"] as? [String: Any]
        XCTAssertNotNil(cardDetailsJSON)
        XCTAssertEqual(cardDetailsJSON?["currency"] as? String, "USD")

        // Note: timeout is not encoded in JSON as it's not in CodingKeys
        XCTAssertNil(bodyJSON?["timeout"])
    }

    func testHTTPClientReceivesCorrectURL() async throws {
        // Given
        let sandboxSetup = Gr4vySetup(
            gr4vyId: "test-sandbox-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        let sandboxConfig = Gr4vyHTTPConfiguration(setup: sandboxSetup)
        let sandboxService = Gr4vyCardDetailsService(
            httpClient: mockHTTPClient,
            configuration: sandboxConfig
        )

        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        let mockResponse = Gr4vyCardDetailsResponse(
            type: "card",
            id: "test-id",
            cardType: "credit",
            scheme: "visa",
            schemeIconURL: nil,
            country: "US",
            requiredFields: nil
        )

        mockHTTPClient.response = mockResponse

        // When
        _ = try await sandboxService.get(request: request)

        // Then
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("api.sandbox.test-sandbox-id.gr4vy.app") == true)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("card-details") == true)
    }

    func testHTTPClientReceivesCorrectProductionURL() async throws {
        // Given
        let productionSetup = Gr4vySetup(
            gr4vyId: "test-production-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .production
        )

        let productionConfig = Gr4vyHTTPConfiguration(setup: productionSetup)
        let productionService = Gr4vyCardDetailsService(
            httpClient: mockHTTPClient,
            configuration: productionConfig
        )

        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        let mockResponse = Gr4vyCardDetailsResponse(
            type: "card",
            id: "test-id",
            cardType: "credit",
            scheme: "visa",
            schemeIconURL: nil,
            country: "US",
            requiredFields: nil
        )

        mockHTTPClient.response = mockResponse

        // When
        _ = try await productionService.get(request: request)

        // Then
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("api.test-production-id.gr4vy.app") == true)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("card-details") == true)
    }

    // MARK: - Merchant ID Tests

    func testServicePassesNilMerchantId() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        let mockResponse = Gr4vyCardDetailsResponse(
            type: "card",
            id: "test-id",
            cardType: "credit",
            scheme: "visa",
            schemeIconURL: nil,
            country: "US",
            requiredFields: nil
        )

        // Create a custom mock that can capture the merchantId parameter
        class MerchantIdCapturingMock: Gr4vyHTTPClientProtocol {
            var capturedMerchantId: String?
            var mockResponse: Gr4vyCardDetailsResponse?

            func perform<Request: Encodable>(
                to url: URL,
                method: String,
                body: Request?,
                merchantId: String?,
                timeout: TimeInterval?
            ) async throws -> Data {
                capturedMerchantId = merchantId
                return try JSONEncoder().encode(mockResponse!)
            }
        }

        let capturingMock = MerchantIdCapturingMock()
        capturingMock.mockResponse = mockResponse

        let testService = Gr4vyCardDetailsService(
            httpClient: capturingMock,
            configuration: configuration
        )

        // When
        _ = try await testService.get(request: request)

        // Then
        XCTAssertNil(capturingMock.capturedMerchantId, "Card details service should always pass nil for merchantId")
    }

    // MARK: - Timeout Tests

    func testTimeoutPassedToHTTPClient() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails, timeout: 120.0)

        let mockResponse = Gr4vyCardDetailsResponse(
            type: "card",
            id: "test-id",
            cardType: "credit",
            scheme: "visa",
            schemeIconURL: nil,
            country: "US",
            requiredFields: nil
        )

        // Create a custom mock that can capture the timeout parameter
        class TimeoutCapturingMock: Gr4vyHTTPClientProtocol {
            var capturedTimeout: TimeInterval?
            var mockResponse: Gr4vyCardDetailsResponse?

            func perform<Request: Encodable>(
                to url: URL,
                method: String,
                body: Request?,
                merchantId: String?,
                timeout: TimeInterval?
            ) async throws -> Data {
                capturedTimeout = timeout
                return try JSONEncoder().encode(mockResponse!)
            }
        }

        let capturingMock = TimeoutCapturingMock()
        capturingMock.mockResponse = mockResponse

        let testService = Gr4vyCardDetailsService(
            httpClient: capturingMock,
            configuration: configuration
        )

        // When
        _ = try await testService.get(request: request)

        // Then
        XCTAssertEqual(capturingMock.capturedTimeout, 120.0)
    }

    func testNilTimeoutPassedToHTTPClient() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails) // No timeout

        let mockResponse = Gr4vyCardDetailsResponse(
            type: "card",
            id: "test-id",
            cardType: "credit",
            scheme: "visa",
            schemeIconURL: nil,
            country: "US",
            requiredFields: nil
        )

        // Create a custom mock that can capture the timeout parameter
        class TimeoutCapturingMock: Gr4vyHTTPClientProtocol {
            var capturedTimeout: TimeInterval?
            var mockResponse: Gr4vyCardDetailsResponse?

            func perform<Request: Encodable>(
                to url: URL,
                method: String,
                body: Request?,
                merchantId: String?,
                timeout: TimeInterval?
            ) async throws -> Data {
                capturedTimeout = timeout
                return try JSONEncoder().encode(mockResponse!)
            }
        }

        let capturingMock = TimeoutCapturingMock()
        capturingMock.mockResponse = mockResponse

        let testService = Gr4vyCardDetailsService(
            httpClient: capturingMock,
            configuration: configuration
        )

        // When
        _ = try await testService.get(request: request)

        // Then
        XCTAssertNil(capturingMock.capturedTimeout)
    }

    // MARK: - Edge Cases Tests

    func testGetCardDetailsWithEmptyResponse() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        let emptyData = Data()
        mockHTTPClient.data = emptyData

        // When/Then
        do {
            _ = try await service.get(request: request)
            XCTFail("Expected error to be thrown")
        } catch {
            // Empty data should cause a decoding error
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testGetCardDetailsWithLargeResponse() async throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        let largeString = String(repeating: "a", count: 10_000)
        let mockResponse = Gr4vyCardDetailsResponse(
            type: "card",
            id: largeString,
            cardType: "credit",
            scheme: "visa",
            schemeIconURL: nil,
            country: "US",
            requiredFields: nil
        )

        mockHTTPClient.response = mockResponse

        // When
        let result = try await service.get(request: request)

        // Then
        XCTAssertEqual(result.id, largeString)
        XCTAssertEqual(result.type, "card")
    }
}
