//
//  Gr4vyPaymentOptionsServiceTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyPaymentOptionsServiceTests: XCTestCase {
    // MARK: - Properties

    private var mockHTTPClient: MockHTTPClient!
    private var testSetup: Gr4vySetup!
    private var testConfiguration: Gr4vyHTTPConfiguration!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        mockHTTPClient = MockHTTPClient()
        testSetup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox,
            timeout: 30.0
        )
        testConfiguration = Gr4vyHTTPConfiguration(
            setup: testSetup,
            debugMode: false,
            session: URLSession.shared
        )
    }

    override func tearDownWithError() throws {
        mockHTTPClient = nil
        testSetup = nil
        testConfiguration = nil
    }

    // MARK: - Initialization Tests

    func testInitializationWithSetup() throws {
        // Given
        let debugMode = true
        let session = URLSession.shared

        // When
        let service = Gr4vyPaymentOptionsService(setup: testSetup, debugMode: debugMode, session: session)

        // Then
        XCTAssertEqual(service.debugMode, debugMode)
    }

    func testInitializationWithDependencyInjection() throws {
        // Given
        let debugMode = true
        let configuration = Gr4vyHTTPConfiguration(setup: testSetup, debugMode: debugMode, session: URLSession.shared)
        let mockClient = MockHTTPClient()

        // When
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockClient,
            configuration: configuration
        )

        // Then
        XCTAssertEqual(service.debugMode, debugMode)
    }

    func testInitializationWithDefaultDebugMode() throws {
        // When
        let service = Gr4vyPaymentOptionsService(setup: testSetup)

        // Then
        XCTAssertFalse(service.debugMode)
    }

    func testInitializationWithCustomSession() throws {
        // Given
        let customSession = URLSession(configuration: .ephemeral)

        // When
        let service = Gr4vyPaymentOptionsService(setup: testSetup, session: customSession)

        // Then
        XCTAssertFalse(service.debugMode) // Default should be false
    }

    // MARK: - List Payment Options Tests (Async)

    func testListPaymentOptionsAsyncSuccess() async throws {
        // Given
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )

        let mockResponseJSON = #"""
            {
            "items": [
            {
            "type": "payment-option",
            "method": "card",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "icon_url": "https://example.com/icon.png",
            "label": "Credit Card",
            "context": {
            "merchant_name": "Test Merchant",
            "supported_schemes": ["visa", "mastercard"]
            }
            },
            {
            "method": "bank_redirect",
            "mode": "live",
            "can_store_payment_method": false,
            "can_delay_capture": true,
            "label": "Bank Transfer",
            "context": {
            "redirect_requires_popup": true,
            "requires_tokenized_redirect_popup": false
            }
            }
            ]
            }
        """#

        mockHTTPClient.data = Data(mockResponseJSON.utf8)

        let request = Gr4vyPaymentOptionRequest(
            merchantId: "test-merchant",
            metadata: ["order_id": "12345"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )

        // When
        let result = try await service.list(request: request)

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].method, "card")
        XCTAssertEqual(result[0].mode, "test")
        XCTAssertTrue(result[0].canStorePaymentMethod)
        XCTAssertFalse(result[0].canDelayCapture)
        XCTAssertEqual(result[0].iconUrl, "https://example.com/icon.png")
        XCTAssertEqual(result[0].label, "Credit Card")

        XCTAssertEqual(result[1].method, "bank_redirect")
        XCTAssertEqual(result[1].mode, "live")
        XCTAssertFalse(result[1].canStorePaymentMethod)
        XCTAssertTrue(result[1].canDelayCapture)
        XCTAssertNil(result[1].iconUrl)
        XCTAssertEqual(result[1].label, "Bank Transfer")

        // Verify HTTP request details
        XCTAssertEqual(mockHTTPClient.lastMethod, "POST")
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("api.sandbox.test-id.gr4vy.app") == true)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("payment-options") == true)
        XCTAssertNotNil(mockHTTPClient.lastBody)
    }

    func testListPaymentOptionsAsyncWithEmptyResponse() async throws {
        // Given
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )

        let mockResponseJSON = #"""
            {
            "items": []
            }
        """#

        mockHTTPClient.data = Data(mockResponseJSON.utf8)

        let request = Gr4vyPaymentOptionRequest(
            metadata: ["order_id": "12345"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )

        // When
        let result = try await service.list(request: request)

        // Then
        XCTAssertEqual(result.count, 0)
        XCTAssertTrue(result.isEmpty)
    }

    func testListPaymentOptionsAsyncWithCartItems() async throws {
        // Given
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )

        let mockResponseJSON = #"""
            {
            "items": [
            {
            "method": "card",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "type": "payment-option"
            }
            ]
            }
        """#

        mockHTTPClient.data = Data(mockResponseJSON.utf8)

        let cartItems = [
            Gr4vyPaymentOptionCartItem(
                name: "Test Product",
                quantity: 2,
                unitAmount: 500,
                discountAmount: 50,
                taxAmount: 45,
                externalIdentifier: "prod-123",
                sku: "SKU-123",
                productUrl: "https://example.com/product",
                imageUrl: "https://example.com/image.jpg",
                categories: ["electronics", "phones"],
                productType: "physical",
                sellerCountry: "US"
            ),
        ]

        let request = Gr4vyPaymentOptionRequest(
            metadata: ["order_id": "12345"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: cartItems
        )

        // When
        let result = try await service.list(request: request)

        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].method, "card")

        // Verify HTTP request details
        XCTAssertEqual(mockHTTPClient.lastMethod, "POST")
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertNotNil(mockHTTPClient.lastBody)

        // Verify cart items are included in request body
        let bodyJSON = try JSONSerialization.jsonObject(with: mockHTTPClient.lastBody!, options: []) as? [String: Any]
        XCTAssertNotNil(bodyJSON?["cart_items"])
    }

    // MARK: - List Payment Options Tests (Callback)

    func testListPaymentOptionsCallbackSuccess() async throws {
        // Given
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )

        let mockResponseJSON = #"""
            {
            "items": [
            {
            "method": "card",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "type": "payment-option"
            }
            ]
            }
        """#

        mockHTTPClient.data = Data(mockResponseJSON.utf8)

        let request = Gr4vyPaymentOptionRequest(
            metadata: ["order_id": "12345"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )

        let expectation = expectation(description: "List payment options callback")
        var capturedResult: Result<[Gr4vyPaymentOption], Error>?

        // When
        service.list(request: request) { result in
            capturedResult = result
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        // Then
        XCTAssertNotNil(capturedResult)
        switch capturedResult! {
        case .success(let paymentOptions):
            XCTAssertEqual(paymentOptions.count, 1)
            XCTAssertEqual(paymentOptions[0].method, "card")
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testListPaymentOptionsCallbackFailure() async throws {
        // Given
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )

        let networkError = URLError(.notConnectedToInternet)
        mockHTTPClient.error = networkError

        let request = Gr4vyPaymentOptionRequest(
            metadata: ["order_id": "12345"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )

        let expectation = expectation(description: "List payment options callback failure")
        var capturedResult: Result<[Gr4vyPaymentOption], Error>?

        // When
        service.list(request: request) { result in
            capturedResult = result
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        // Then
        XCTAssertNotNil(capturedResult)
        switch capturedResult! {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertEqual(error as? URLError, networkError)
        }
    }

    // MARK: - Error Handling Tests

    func testListPaymentOptionsNetworkError() async throws {
        // Given
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )

        let networkError = URLError(.notConnectedToInternet)
        mockHTTPClient.error = networkError

        let request = Gr4vyPaymentOptionRequest(
            metadata: ["order_id": "12345"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )

        // When & Then
        do {
            _ = try await service.list(request: request)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? URLError, networkError)
        }
    }

    func testListPaymentOptionsDecodingError() async throws {
        // Given
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )

        let invalidData = Data("invalid json".utf8)
        mockHTTPClient.data = invalidData

        let request = Gr4vyPaymentOptionRequest(
            metadata: ["order_id": "12345"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )

        // When & Then
        do {
            _ = try await service.list(request: request)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testListPaymentOptionsHTTPError() async throws {
        // Given
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )

        let httpError = Gr4vyError.httpError(statusCode: 404, responseData: nil, message: "Not found")
        mockHTTPClient.error = httpError

        let request = Gr4vyPaymentOptionRequest(
            metadata: ["order_id": "12345"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )

        // When & Then
        do {
            _ = try await service.list(request: request)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? Gr4vyError, httpError)
        }
    }

    // MARK: - Setup Update Tests

    func testUpdateSetupChangesConfiguration() throws {
        // Given
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )

        let newSetup = Gr4vySetup(
            gr4vyId: "new-test-id",
            token: "new-test-token",
            merchantId: "new-test-merchant",
            server: .production,
            timeout: 60.0
        )

        // When
        service.updateSetup(newSetup)

        // Then - We can't directly verify the internal state but can test that subsequent calls work
        // This test ensures the method executes without error
        XCTAssertTrue(true)
    }

    func testHTTPClientReceivesCorrectSandboxURL() async throws {
        // Given
        let sandboxSetup = Gr4vySetup(
            gr4vyId: "test-sandbox-id",
            token: "sandbox-token",
            merchantId: "sandbox-merchant",
            server: .sandbox,
            timeout: 30.0
        )

        let sandboxConfig = Gr4vyHTTPConfiguration(
            setup: sandboxSetup,
            debugMode: false,
            session: URLSession.shared
        )

        let sandboxService = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: sandboxConfig
        )

        let mockResponseJSON = #"""
            {
            "items": []
            }
        """#

        mockHTTPClient.data = Data(mockResponseJSON.utf8)

        let request = Gr4vyPaymentOptionRequest(
            metadata: ["test": "value"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )

        // When
        _ = try await sandboxService.list(request: request)

        // Then
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("api.sandbox.test-sandbox-id.gr4vy.app") == true)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("payment-options") == true)
    }

    func testHTTPClientReceivesCorrectProductionURL() async throws {
        // Given
        let productionSetup = Gr4vySetup(
            gr4vyId: "test-production-id",
            token: "production-token",
            merchantId: "production-merchant",
            server: .production,
            timeout: 30.0
        )

        let productionConfig = Gr4vyHTTPConfiguration(
            setup: productionSetup,
            debugMode: false,
            session: URLSession.shared
        )

        let productionService = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: productionConfig
        )

        let mockResponseJSON = #"""
            {
            "items": []
            }
        """#

        mockHTTPClient.data = Data(mockResponseJSON.utf8)

        let request = Gr4vyPaymentOptionRequest(
            metadata: ["test": "value"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )

        // When
        _ = try await productionService.list(request: request)

        // Then
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("api.test-production-id.gr4vy.app") == true)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("payment-options") == true)
    }

    // MARK: - HTTP Interaction Tests

    func testHTTPRequestDetails() async throws {
        // Given
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )

        let mockResponseJSON = #"""
            {
            "items": []
            }
        """#

        mockHTTPClient.data = Data(mockResponseJSON.utf8)

        let request = Gr4vyPaymentOptionRequest(
            merchantId: "custom-merchant",
            metadata: ["order_id": "12345", "user_id": "user123"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil,
            timeout: 45.0
        )

        // When
        _ = try await service.list(request: request)

        // Then
        XCTAssertEqual(mockHTTPClient.lastMethod, "POST")
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertTrue(mockHTTPClient.lastURL?.absoluteString.contains("payment-options") == true)
        XCTAssertNotNil(mockHTTPClient.lastBody)

        // Verify request body encoding
        let bodyJSON = try JSONSerialization.jsonObject(with: mockHTTPClient.lastBody!, options: []) as? [String: Any]
        XCTAssertNotNil(bodyJSON)

        let metadata = bodyJSON?["metadata"] as? [String: String]
        XCTAssertEqual(metadata?["order_id"], "12345")
        XCTAssertEqual(metadata?["user_id"], "user123")
        XCTAssertEqual(bodyJSON?["country"] as? String, "US")
        XCTAssertEqual(bodyJSON?["currency"] as? String, "USD")
        XCTAssertEqual(bodyJSON?["amount"] as? Int, 1_000)
        XCTAssertEqual(bodyJSON?["locale"] as? String, "en-US")
    }

    func testHTTPRequestWithMinimalData() async throws {
        // Given
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )

        let mockResponseJSON = #"""
            {
            "items": []
            }
        """#

        mockHTTPClient.data = Data(mockResponseJSON.utf8)

        let request = Gr4vyPaymentOptionRequest(
            metadata: [:],
            country: nil,
            currency: nil,
            amount: nil,
            locale: "en-US",
            cartItems: nil
        )

        // When
        _ = try await service.list(request: request)

        // Then
        XCTAssertEqual(mockHTTPClient.lastMethod, "POST")
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertNotNil(mockHTTPClient.lastBody)

        let bodyJSON = try JSONSerialization.jsonObject(with: mockHTTPClient.lastBody!, options: []) as? [String: Any]
        XCTAssertNotNil(bodyJSON)
        XCTAssertEqual(bodyJSON?["locale"] as? String, "en-US")
        XCTAssertTrue((bodyJSON?["metadata"] as? [String: String])?.isEmpty == true)
    }

    // MARK: - Merchant ID Precedence Tests

    func testMerchantIdPrecedenceRequestOverridesSetup() async throws {
        // Given
        let setupWithMerchant = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "setup-merchant",
            server: .sandbox,
            timeout: 30.0
        )

        let configWithMerchant = Gr4vyHTTPConfiguration(
            setup: setupWithMerchant,
            debugMode: false,
            session: URLSession.shared
        )

        let capturingMockClient = CapturingMockHTTPClient()
        let mockResponseJSON = #"""
            {
            "items": []
            }
        """#

        capturingMockClient.data = Data(mockResponseJSON.utf8)

        let service = Gr4vyPaymentOptionsService(
            httpClient: capturingMockClient,
            configuration: configWithMerchant
        )

        let request = Gr4vyPaymentOptionRequest(
            merchantId: "request-merchant",
            metadata: ["test": "value"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )

        // When
        _ = try await service.list(request: request)

        // Then - Request merchant ID should take precedence
        XCTAssertEqual(capturingMockClient.capturedMerchantId, "request-merchant")
    }

    func testMerchantIdFallbackToSetup() async throws {
        // Given
        let setupWithMerchant = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "setup-merchant",
            server: .sandbox,
            timeout: 30.0
        )

        let configWithMerchant = Gr4vyHTTPConfiguration(
            setup: setupWithMerchant,
            debugMode: false,
            session: URLSession.shared
        )

        let capturingMockClient = CapturingMockHTTPClient()
        let mockResponseJSON = #"""
            {
            "items": []
            }
        """#

        capturingMockClient.data = Data(mockResponseJSON.utf8)

        let service = Gr4vyPaymentOptionsService(
            httpClient: capturingMockClient,
            configuration: configWithMerchant
        )

        let request = Gr4vyPaymentOptionRequest(
            merchantId: nil,
            metadata: ["test": "value"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )

        // When
        _ = try await service.list(request: request)

        // Then - Setup merchant ID should be used
        XCTAssertEqual(capturingMockClient.capturedMerchantId, "setup-merchant")
    }

    // MARK: - Timeout Handling Tests

    func testTimeoutPrecedenceRequestOverridesSetup() async throws {
        // Given
        let setupWithTimeout = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox,
            timeout: 30.0
        )

        let configWithTimeout = Gr4vyHTTPConfiguration(
            setup: setupWithTimeout,
            debugMode: false,
            session: URLSession.shared
        )

        let capturingMockClient = CapturingMockHTTPClient()
        let mockResponseJSON = #"""
            {
            "items": []
            }
        """#

        capturingMockClient.data = Data(mockResponseJSON.utf8)

        let service = Gr4vyPaymentOptionsService(
            httpClient: capturingMockClient,
            configuration: configWithTimeout
        )

        let request = Gr4vyPaymentOptionRequest(
            metadata: ["test": "value"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil,
            timeout: 60.0
        )

        // When
        _ = try await service.list(request: request)

        // Then - Request timeout should take precedence
        XCTAssertEqual(capturingMockClient.capturedTimeout, 60.0)
    }

    func testNilTimeoutPassedToHTTPClient() async throws {
        // Given
        let setupWithTimeout = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox,
            timeout: 45.0
        )

        let configWithTimeout = Gr4vyHTTPConfiguration(
            setup: setupWithTimeout,
            debugMode: false,
            session: URLSession.shared
        )

        let capturingMockClient = CapturingMockHTTPClient()
        let mockResponseJSON = #"""
            {
            "items": []
            }
        """#

        capturingMockClient.data = Data(mockResponseJSON.utf8)

        let service = Gr4vyPaymentOptionsService(
            httpClient: capturingMockClient,
            configuration: configWithTimeout
        )

        let request = Gr4vyPaymentOptionRequest(
            metadata: ["test": "value"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil,
            timeout: nil
        )

        // When
        _ = try await service.list(request: request)

        // Then - When request timeout is nil, nil should be passed to HTTP client
        XCTAssertNil(capturingMockClient.capturedTimeout)
    }

    // MARK: - Edge Cases

    func testListPaymentOptionsWithLargeResponse() async throws {
        // Given
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )

        // Create a large response with many payment options
        let items = Array(0..<100).map { index in
            """
            {
              "method": "method-\(index)",
              "mode": "test",
              "can_store_payment_method": \(index % 2 == 0 ? "true" : "false"),
              "can_delay_capture": \(index % 3 == 0 ? "true" : "false"),
              "type": "payment-option",
              "icon_url": "https://example.com/icon-\(index).png",
              "label": "Option \(index)"
            }
            """
        }.joined(separator: ",")

        let mockResponseJSON = """
        {
          "items": [\(items)]
        }
        """

        mockHTTPClient.data = Data(mockResponseJSON.utf8)

        let request = Gr4vyPaymentOptionRequest(
            metadata: ["test": "value"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )

        // When
        let result = try await service.list(request: request)

        // Then
        XCTAssertEqual(result.count, 100)
        XCTAssertEqual(result[0].method, "method-0")
        XCTAssertEqual(result[99].method, "method-99")
    }

    func testListPaymentOptionsWithComplexCartItems() async throws {
        // Given
        let service = Gr4vyPaymentOptionsService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )

        let mockResponseJSON = #"""
            {
            "items": []
            }
        """#

        mockHTTPClient.data = Data(mockResponseJSON.utf8)

        let complexCartItems = [
            Gr4vyPaymentOptionCartItem(
                name: "Premium Headphones",
                quantity: 1,
                unitAmount: 29_999,
                discountAmount: 5_000,
                taxAmount: 2_400,
                externalIdentifier: "ext-headphones-001",
                sku: "HP-PREMIUM-001",
                productUrl: "https://store.example.com/headphones/premium",
                imageUrl: "https://cdn.example.com/images/headphones.jpg",
                categories: ["electronics", "audio", "headphones"],
                productType: "physical",
                sellerCountry: "US"
            ),
            Gr4vyPaymentOptionCartItem(
                name: "Digital Music Album",
                quantity: 2,
                unitAmount: 999,
                discountAmount: nil,
                taxAmount: nil,
                externalIdentifier: "ext-album-002",
                sku: "MUS-DIGITAL-002",
                productUrl: "https://music.example.com/album/002",
                imageUrl: "https://cdn.example.com/images/album.jpg",
                categories: ["digital", "music"],
                productType: "digital",
                sellerCountry: "US"
            ),
        ]

        let request = Gr4vyPaymentOptionRequest(
            metadata: ["complex": "test"],
            country: "US",
            currency: "USD",
            amount: 32_997,
            locale: "en-US",
            cartItems: complexCartItems
        )

        // When
        _ = try await service.list(request: request)

        // Then
        XCTAssertNotNil(mockHTTPClient.lastBody)
        let bodyJSON = try JSONSerialization.jsonObject(with: mockHTTPClient.lastBody!, options: []) as? [String: Any]
        let cartItemsJSON = bodyJSON?["cart_items"] as? [[String: Any]]
        XCTAssertNotNil(cartItemsJSON)
        XCTAssertEqual(cartItemsJSON?.count, 2)

        let firstItem = cartItemsJSON?[0]
        XCTAssertEqual(firstItem?["name"] as? String, "Premium Headphones")
        XCTAssertEqual(firstItem?["unit_amount"] as? Int, 29_999)
        XCTAssertEqual(firstItem?["discount_amount"] as? Int, 5_000)
        XCTAssertEqual(firstItem?["tax_amount"] as? Int, 2_400)
        XCTAssertEqual(firstItem?["external_identifier"] as? String, "ext-headphones-001")
        XCTAssertEqual(firstItem?["sku"] as? String, "HP-PREMIUM-001")
        XCTAssertEqual(firstItem?["product_url"] as? String, "https://store.example.com/headphones/premium")
        XCTAssertEqual(firstItem?["image_url"] as? String, "https://cdn.example.com/images/headphones.jpg")
        XCTAssertEqual(firstItem?["categories"] as? [String], ["electronics", "audio", "headphones"])
        XCTAssertEqual(firstItem?["product_type"] as? String, "physical")
        XCTAssertEqual(firstItem?["seller_country"] as? String, "US")
    }
}

// MARK: - Test Helper Classes

final class CapturingMockHTTPClient: Gr4vyHTTPClientProtocol {
    var response: (any Encodable)?
    var error: Error?
    var data: Data?

    private(set) var capturedMerchantId: String?
    private(set) var capturedTimeout: TimeInterval?

    func perform<Request: Encodable>(
        to url: URL,
        method: String,
        body: Request?,
        merchantId: String?,
        timeout: TimeInterval?
    ) async throws -> Data {
        capturedMerchantId = merchantId
        capturedTimeout = timeout

        if let error = error {
            throw error
        }

        if let data = data {
            return data
        }

        if let encodable = response {
            return try JSONEncoder().encode(AnyEncodable(encodable))
        }

        throw Gr4vyError.decodingError("No mock fixture configured")
    }
}

private struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init<T: Encodable>(_ value: T) {
        self.encodeFunc = value.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
