//
//  Gr4vyBuyersServiceTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyBuyersServiceTests: XCTestCase {
    private var mockHTTPClient: MockHTTPClient!
    private var configuration: Gr4vyHTTPConfiguration!
    private var paymentMethodsService: Gr4vyBuyersPaymentMethodsService!
    private var buyersService: Gr4vyBuyersService!

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

        paymentMethodsService = Gr4vyBuyersPaymentMethodsService(
            httpClient: mockHTTPClient,
            configuration: configuration
        )

        buyersService = Gr4vyBuyersService(setup: setup)
    }

    override func tearDownWithError() throws {
        mockHTTPClient = nil
        configuration = nil
        paymentMethodsService = nil
        buyersService = nil
    }

    // MARK: - Gr4vyBuyersService Tests

    func testBuyersServiceInitialization() {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        // When
        let service = Gr4vyBuyersService(setup: setup, debugMode: true)

        // Then
        XCTAssertNotNil(service.paymentMethods)
        XCTAssertTrue(service.paymentMethods.debugMode)
    }

    func testBuyersServiceInitializationWithDefaultDebugMode() {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        // When
        let service = Gr4vyBuyersService(setup: setup)

        // Then
        XCTAssertNotNil(service.paymentMethods)
        XCTAssertFalse(service.paymentMethods.debugMode)
    }

    func testBuyersServiceInitializationWithCustomSession() {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )
        let customSession = URLSession.shared

        // When
        let service = Gr4vyBuyersService(
            setup: setup,
            debugMode: false,
            session: customSession
        )

        // Then
        XCTAssertNotNil(service.paymentMethods)
        XCTAssertFalse(service.paymentMethods.debugMode)
    }

    func testBuyersServiceUpdateSetup() {
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

        let service = Gr4vyBuyersService(setup: originalSetup)

        // When
        service.updateSetup(newSetup)

        // Then
        XCTAssertNotNil(service.paymentMethods)
    }

    // MARK: - Gr4vyBuyersPaymentMethodsService Initialization Tests

    func testPaymentMethodsServiceInitializationWithSetup() {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        // When
        let service = Gr4vyBuyersPaymentMethodsService(
            setup: setup,
            debugMode: true
        )

        // Then
        XCTAssertTrue(service.debugMode)
    }

    func testPaymentMethodsServiceInitializationWithDefaultDebugMode() {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        // When
        let service = Gr4vyBuyersPaymentMethodsService(setup: setup)

        // Then
        XCTAssertFalse(service.debugMode)
    }

    func testPaymentMethodsServiceInitializationWithCustomSession() {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )
        let customSession = URLSession.shared

        // When
        let service = Gr4vyBuyersPaymentMethodsService(
            setup: setup,
            debugMode: false,
            session: customSession
        )

        // Then
        XCTAssertFalse(service.debugMode)
    }

    func testPaymentMethodsServiceInitializationWithDependencyInjection() {
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
        let service = Gr4vyBuyersPaymentMethodsService(
            httpClient: mockClient,
            configuration: config
        )

        // Then
        XCTAssertTrue(service.debugMode)
    }

    // MARK: - List Payment Methods Tests

    func testListPaymentMethodsAsyncSuccess() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer-123",
            buyerExternalIdentifier: "external-123",
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: "US",
            currency: "USD"
        )
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        let mockPaymentMethod = Gr4vyBuyersPaymentMethod(
            type: "payment-method",
            approvalURL: URL(string: "https://gr4vy.app/redirect/12345"),
            country: "US",
            currency: "USD",
            details: Gr4vyBuyersPaymentMethod.Gr4vyBuyersPaymentMethodDetails(
                bin: "411111",
                cardType: "credit",
                cardIssuerName: "Test Bank"
            ),
            expirationDate: "12/30",
            fingerprint: "test-fingerprint",
            label: "****1234",
            lastReplacedAt: "2023-01-01T00:00:00Z",
            method: "card",
            mode: "card",
            scheme: "visa",
            id: "payment-method-123",
            merchantAccountId: "merchant-123",
            additionalSchemes: ["visa", "maestro"],
            citLastUsedAt: "2023-01-01T00:00:00Z",
            citUsageCount: 5,
            hasReplacement: false,
            lastUsedAt: "2023-01-01T00:00:00Z",
            usageCount: 10
        )

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [mockPaymentMethod])
        mockHTTPClient.response = mockResponse

        // When
        let result = try await paymentMethodsService.list(request: request)

        // Then
        XCTAssertEqual(result.count, 1)
        let paymentMethod = result.first!
        XCTAssertEqual(paymentMethod.type, "payment-method")
        XCTAssertEqual(paymentMethod.id, "payment-method-123")
        XCTAssertEqual(paymentMethod.country, "US")
        XCTAssertEqual(paymentMethod.currency, "USD")
        XCTAssertEqual(paymentMethod.method, "card")
        XCTAssertEqual(paymentMethod.scheme, "visa")
        XCTAssertEqual(paymentMethod.label, "****1234")
        XCTAssertEqual(paymentMethod.expirationDate, "12/30")
        XCTAssertEqual(paymentMethod.usageCount, 10)
        XCTAssertEqual(paymentMethod.citUsageCount, 5)
        XCTAssertEqual(paymentMethod.hasReplacement, false)

        // Verify details
        XCTAssertNotNil(paymentMethod.details)
        XCTAssertEqual(paymentMethod.details?.bin, "411111")
        XCTAssertEqual(paymentMethod.details?.cardType, "credit")
        XCTAssertEqual(paymentMethod.details?.cardIssuerName, "Test Bank")

        // Verify HTTP client was called correctly
        XCTAssertEqual(mockHTTPClient.lastMethod, "GET")
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("api.sandbox.test-id.gr4vy.app") == true)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("buyers/payment-methods") == true)
    }

    func testListPaymentMethodsAsyncWithTimeout() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            timeout: 60.0
        )

        let mockPaymentMethod = Gr4vyBuyersPaymentMethod(
            type: "payment-method",
            approvalURL: nil,
            country: "GB",
            currency: "GBP",
            details: nil,
            expirationDate: nil,
            fingerprint: nil,
            label: nil,
            lastReplacedAt: nil,
            method: "card",
            mode: "card",
            scheme: "mastercard",
            id: "payment-method-456",
            merchantAccountId: nil,
            additionalSchemes: nil,
            citLastUsedAt: nil,
            citUsageCount: nil,
            hasReplacement: nil,
            lastUsedAt: nil,
            usageCount: nil
        )

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [mockPaymentMethod])
        mockHTTPClient.response = mockResponse

        // When
        let result = try await paymentMethodsService.list(request: request)

        // Then
        XCTAssertEqual(result.count, 1)
        let paymentMethod = result.first!
        XCTAssertEqual(paymentMethod.type, "payment-method")
        XCTAssertEqual(paymentMethod.id, "payment-method-456")
        XCTAssertEqual(paymentMethod.country, "GB")
        XCTAssertEqual(paymentMethod.currency, "GBP")
        XCTAssertEqual(paymentMethod.scheme, "mastercard")
        XCTAssertNil(paymentMethod.details)
        XCTAssertNil(paymentMethod.label)
        XCTAssertNil(paymentMethod.usageCount)
    }

    func testListPaymentMethodsAsyncEmptyResponse() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [])
        mockHTTPClient.response = mockResponse

        // When
        let result = try await paymentMethodsService.list(request: request)

        // Then
        XCTAssertEqual(result.count, 0)
        XCTAssertTrue(result.isEmpty)
    }

    func testListPaymentMethodsCallbackSuccess() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        let mockPaymentMethod = Gr4vyBuyersPaymentMethod(
            type: "payment-method",
            approvalURL: nil,
            country: "US",
            currency: "USD",
            details: nil,
            expirationDate: nil,
            fingerprint: nil,
            label: "****5678",
            lastReplacedAt: nil,
            method: "card",
            mode: "card",
            scheme: "visa",
            id: "callback-payment-method",
            merchantAccountId: nil,
            additionalSchemes: nil,
            citLastUsedAt: nil,
            citUsageCount: nil,
            hasReplacement: nil,
            lastUsedAt: nil,
            usageCount: nil
        )

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [mockPaymentMethod])
        mockHTTPClient.response = mockResponse

        // When
        let expectation = XCTestExpectation(description: "Callback completion")
        var result: [Gr4vyBuyersPaymentMethod]?
        var error: Error?

        paymentMethodsService.list(request: request) { callbackResult in
            switch callbackResult {
            case .success(let paymentMethods):
                result = paymentMethods
            case .failure(let callbackError):
                error = callbackError
            }
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        // Then
        XCTAssertNil(error)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, "callback-payment-method")
        XCTAssertEqual(result?.first?.label, "****5678")
        XCTAssertEqual(result?.first?.scheme, "visa")
    }

    func testListPaymentMethodsWithDiscardableResult() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [])
        mockHTTPClient.response = mockResponse

        // When/Then - Should not produce compiler warning
        try await paymentMethodsService.list(request: request)

        // Verify HTTP client was called
        XCTAssertEqual(mockHTTPClient.lastMethod, "GET")
        XCTAssertNotNil(mockHTTPClient.lastURL)
    }

    // MARK: - Error Handling Tests

    func testListPaymentMethodsAsyncNetworkError() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        let networkError = URLError(.networkConnectionLost)
        mockHTTPClient.error = networkError

        // When/Then
        do {
            _ = try await paymentMethodsService.list(request: request)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
            XCTAssertEqual((error as? URLError)?.code, .networkConnectionLost)
        }
    }

    func testListPaymentMethodsAsyncDecodingError() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        // Invalid JSON data
        let invalidData = "{ invalid json }".data(using: .utf8)!
        mockHTTPClient.data = invalidData

        // When/Then
        do {
            _ = try await paymentMethodsService.list(request: request)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testListPaymentMethodsAsyncHTTPError() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        let httpError = Gr4vyError.httpError(statusCode: 404, responseData: nil, message: "Not Found")
        mockHTTPClient.error = httpError

        // When/Then
        do {
            _ = try await paymentMethodsService.list(request: request)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is Gr4vyError)
            if case let Gr4vyError.httpError(statusCode, responseData, message) = error {
                XCTAssertEqual(statusCode, 404)
                XCTAssertNil(responseData)
                XCTAssertEqual(message, "Not Found")
            } else {
                XCTFail("Expected httpError")
            }
        }
    }

    func testListPaymentMethodsCallbackNetworkError() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        let networkError = URLError(.timedOut)
        mockHTTPClient.error = networkError

        // When
        let expectation = XCTestExpectation(description: "Callback completion")
        var result: [Gr4vyBuyersPaymentMethod]?
        var error: Error?

        paymentMethodsService.list(request: request) { callbackResult in
            switch callbackResult {
            case .success(let paymentMethods):
                result = paymentMethods
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

    func testListPaymentMethodsCallbackDecodingError() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        // Invalid JSON data
        let invalidData = "{ malformed json".data(using: .utf8)!
        mockHTTPClient.data = invalidData

        // When
        let expectation = XCTestExpectation(description: "Callback completion")
        var result: [Gr4vyBuyersPaymentMethod]?
        var error: Error?

        paymentMethodsService.list(request: request) { callbackResult in
            switch callbackResult {
            case .success(let paymentMethods):
                result = paymentMethods
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

    func testPaymentMethodsServiceUpdateSetup() {
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

        let service = Gr4vyBuyersPaymentMethodsService(setup: originalSetup)

        // When
        service.updateSetup(newSetup)

        // Then
        XCTAssertNotNil(service)
    }

    func testPaymentMethodsServiceUpdateSetupWithDifferentServer() {
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

        let service = Gr4vyBuyersPaymentMethodsService(setup: sandboxSetup)

        // When
        service.updateSetup(productionSetup)

        // Then
        XCTAssertNotNil(service)
    }

    func testPaymentMethodsServiceUpdateSetupWithNilMerchantId() {
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

        let service = Gr4vyBuyersPaymentMethodsService(setup: setupWithMerchant)

        // When
        service.updateSetup(setupWithoutMerchant)

        // Then
        XCTAssertNotNil(service)
    }

    // MARK: - HTTP Client Interaction Tests

    func testHTTPClientReceivesCorrectParameters() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer-123",
            sortBy: .lastUsedAt,
            orderBy: .asc
        )
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            timeout: 45.0
        )

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [])
        mockHTTPClient.response = mockResponse

        // When
        _ = try await paymentMethodsService.list(request: request)

        // Then
        XCTAssertEqual(mockHTTPClient.lastMethod, "GET")
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("buyers/payment-methods") == true)
        XCTAssertNotNil(mockHTTPClient.lastBody)

        // Verify the request body was encoded correctly
        let bodyJSON = try JSONSerialization.jsonObject(with: mockHTTPClient.lastBody!, options: []) as? [String: Any]
        XCTAssertNotNil(bodyJSON)

        let paymentMethodsJSON = bodyJSON?["payment_methods"] as? [String: Any]
        XCTAssertNotNil(paymentMethodsJSON)
        XCTAssertEqual(paymentMethodsJSON?["buyer_id"] as? String, "buyer-123")
        XCTAssertEqual(paymentMethodsJSON?["sort_by"] as? String, "last_used_at")
        XCTAssertEqual(paymentMethodsJSON?["order_by"] as? String, "asc")

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
        let sandboxService = Gr4vyBuyersPaymentMethodsService(
            httpClient: mockHTTPClient,
            configuration: sandboxConfig
        )

        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [])
        mockHTTPClient.response = mockResponse

        // When
        _ = try await sandboxService.list(request: request)

        // Then
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("api.sandbox.test-sandbox-id.gr4vy.app") == true)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("buyers/payment-methods") == true)
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
        let productionService = Gr4vyBuyersPaymentMethodsService(
            httpClient: mockHTTPClient,
            configuration: productionConfig
        )

        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [])
        mockHTTPClient.response = mockResponse

        // When
        _ = try await productionService.list(request: request)

        // Then
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("api.test-production-id.gr4vy.app") == true)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("buyers/payment-methods") == true)
    }

    // MARK: - Merchant ID Tests

    func testServicePassesRequestMerchantId() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            merchantId: "request-merchant-id"
        )

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [])

        // Create a custom mock that can capture the merchantId parameter
        class MerchantIdCapturingMock: Gr4vyHTTPClientProtocol {
            var capturedMerchantId: String?
            var mockResponse: Gr4vyBuyersPaymentMethodsResponse?

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

        let testService = Gr4vyBuyersPaymentMethodsService(
            httpClient: capturingMock,
            configuration: configuration
        )

        // When
        _ = try await testService.list(request: request)

        // Then
        XCTAssertEqual(capturingMock.capturedMerchantId, "request-merchant-id")
    }

    func testServicePassesSetupMerchantIdWhenRequestMerchantIdIsNil() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            merchantId: nil
        )

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [])

        // Create a custom mock that can capture the merchantId parameter
        class MerchantIdCapturingMock: Gr4vyHTTPClientProtocol {
            var capturedMerchantId: String?
            var mockResponse: Gr4vyBuyersPaymentMethodsResponse?

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

        let testService = Gr4vyBuyersPaymentMethodsService(
            httpClient: capturingMock,
            configuration: configuration
        )

        // When
        _ = try await testService.list(request: request)

        // Then
        XCTAssertEqual(capturingMock.capturedMerchantId, "test-merchant") // From setup
    }

    func testServicePassesNilMerchantIdWhenBothAreNil() async throws {
        // Given
        let setupWithNilMerchant = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: nil,
            server: .sandbox
        )

        let configWithNilMerchant = Gr4vyHTTPConfiguration(setup: setupWithNilMerchant)

        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            merchantId: nil
        )

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [])

        // Create a custom mock that can capture the merchantId parameter
        class MerchantIdCapturingMock: Gr4vyHTTPClientProtocol {
            var capturedMerchantId: String?
            var mockResponse: Gr4vyBuyersPaymentMethodsResponse?

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

        let testService = Gr4vyBuyersPaymentMethodsService(
            httpClient: capturingMock,
            configuration: configWithNilMerchant
        )

        // When
        _ = try await testService.list(request: request)

        // Then
        XCTAssertNil(capturingMock.capturedMerchantId)
    }

    // MARK: - Timeout Tests

    func testTimeoutPassedToHTTPClient() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            timeout: 120.0
        )

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [])

        // Create a custom mock that can capture the timeout parameter
        class TimeoutCapturingMock: Gr4vyHTTPClientProtocol {
            var capturedTimeout: TimeInterval?
            var mockResponse: Gr4vyBuyersPaymentMethodsResponse?

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

        let testService = Gr4vyBuyersPaymentMethodsService(
            httpClient: capturingMock,
            configuration: configuration
        )

        // When
        _ = try await testService.list(request: request)

        // Then
        XCTAssertEqual(capturingMock.capturedTimeout, 120.0)
    }

    func testNilTimeoutPassedToHTTPClient() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods) // No timeout

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [])

        // Create a custom mock that can capture the timeout parameter
        class TimeoutCapturingMock: Gr4vyHTTPClientProtocol {
            var capturedTimeout: TimeInterval?
            var mockResponse: Gr4vyBuyersPaymentMethodsResponse?

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

        let testService = Gr4vyBuyersPaymentMethodsService(
            httpClient: capturingMock,
            configuration: configuration
        )

        // When
        _ = try await testService.list(request: request)

        // Then
        XCTAssertNil(capturingMock.capturedTimeout)
    }

    // MARK: - Edge Cases Tests

    func testListPaymentMethodsWithEmptyResponse() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        let emptyData = Data()
        mockHTTPClient.data = emptyData

        // When/Then
        do {
            _ = try await paymentMethodsService.list(request: request)
            XCTFail("Expected error to be thrown")
        } catch {
            // Empty data should cause a decoding error
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testListPaymentMethodsWithLargeResponse() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        let largeString = String(repeating: "a", count: 10_000)
        let mockPaymentMethod = Gr4vyBuyersPaymentMethod(
            type: "payment-method",
            approvalURL: nil,
            country: "US",
            currency: "USD",
            details: nil,
            expirationDate: nil,
            fingerprint: nil,
            label: largeString,
            lastReplacedAt: nil,
            method: "card",
            mode: "card",
            scheme: "visa",
            id: "large-payment-method",
            merchantAccountId: nil,
            additionalSchemes: nil,
            citLastUsedAt: nil,
            citUsageCount: nil,
            hasReplacement: nil,
            lastUsedAt: nil,
            usageCount: nil
        )

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [mockPaymentMethod])
        mockHTTPClient.response = mockResponse

        // When
        let result = try await paymentMethodsService.list(request: request)

        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.label, largeString)
        XCTAssertEqual(result.first?.id, "large-payment-method")
    }

    func testListPaymentMethodsWithMultipleItems() async throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer-123")
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        let paymentMethod1 = Gr4vyBuyersPaymentMethod(
            type: "payment-method",
            approvalURL: nil,
            country: "US",
            currency: "USD",
            details: nil,
            expirationDate: nil,
            fingerprint: nil,
            label: "****1234",
            lastReplacedAt: nil,
            method: "card",
            mode: "card",
            scheme: "visa",
            id: "payment-method-1",
            merchantAccountId: nil,
            additionalSchemes: nil,
            citLastUsedAt: nil,
            citUsageCount: nil,
            hasReplacement: nil,
            lastUsedAt: nil,
            usageCount: nil
        )

        let paymentMethod2 = Gr4vyBuyersPaymentMethod(
            type: "payment-method",
            approvalURL: nil,
            country: "GB",
            currency: "GBP",
            details: nil,
            expirationDate: nil,
            fingerprint: nil,
            label: "****5678",
            lastReplacedAt: nil,
            method: "card",
            mode: "card",
            scheme: "mastercard",
            id: "payment-method-2",
            merchantAccountId: nil,
            additionalSchemes: nil,
            citLastUsedAt: nil,
            citUsageCount: nil,
            hasReplacement: nil,
            lastUsedAt: nil,
            usageCount: nil
        )

        let mockResponse = Gr4vyBuyersPaymentMethodsResponse(items: [paymentMethod1, paymentMethod2])
        mockHTTPClient.response = mockResponse

        // When
        let result = try await paymentMethodsService.list(request: request)

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, "payment-method-1")
        XCTAssertEqual(result[0].label, "****1234")
        XCTAssertEqual(result[0].scheme, "visa")
        XCTAssertEqual(result[1].id, "payment-method-2")
        XCTAssertEqual(result[1].label, "****5678")
        XCTAssertEqual(result[1].scheme, "mastercard")
    }
}
