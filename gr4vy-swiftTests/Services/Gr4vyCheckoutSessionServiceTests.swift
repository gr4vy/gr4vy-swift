//
//  Gr4vyCheckoutSessionServiceTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyCheckoutSessionServiceTests: XCTestCase {
    // MARK: - Properties
    
    private var mockHTTPClient: MockHTTPClient!
    private var testSetup: Gr4vySetup!
    private var testConfiguration: Gr4vyHTTPConfiguration!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        mockHTTPClient = MockHTTPClient()
        testSetup = Gr4vySetup(
            gr4vyId: "test-checkout-id",
            token: "test-checkout-token",
            merchantId: "test-merchant-123",
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
        let service = Gr4vyCheckoutSessionService(setup: testSetup, debugMode: debugMode, session: session)
        
        // Then
        XCTAssertEqual(service.debugMode, debugMode)
    }
    
    func testInitializationWithDependencyInjection() throws {
        // Given
        let debugMode = true
        let configuration = Gr4vyHTTPConfiguration(setup: testSetup, debugMode: debugMode, session: URLSession.shared)
        let mockClient = MockHTTPClient()
        
        // When
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockClient,
            configuration: configuration
        )
        
        // Then
        XCTAssertEqual(service.debugMode, debugMode)
    }
    
    func testInitializationWithDefaultDebugMode() throws {
        // When
        let service = Gr4vyCheckoutSessionService(setup: testSetup)
        
        // Then
        XCTAssertFalse(service.debugMode)
    }
    
    func testInitializationWithCustomSession() throws {
        // Given
        let customSession = URLSession(configuration: .ephemeral)
        
        // When
        let service = Gr4vyCheckoutSessionService(setup: testSetup, session: customSession)
        
        // Then
        XCTAssertFalse(service.debugMode) // Default should be false
    }
    
    // MARK: - Setup Update Tests
    
    func testUpdateSetup() throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let newSetup = Gr4vySetup(
            gr4vyId: "updated-checkout-id",
            token: "updated-checkout-token",
            merchantId: "updated-merchant-456",
            server: .production,
            timeout: 60.0
        )
        
        // When & Then - Should not throw any errors
        XCTAssertNoThrow(service.updateSetup(newSetup))
    }
    
    // MARK: - Tokenize Tests (Async)
    
    func testTokenizeAsyncSuccess() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_12345"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        
        // Mock HTTP client to return empty data (tokenize returns void)
        mockHTTPClient.data = Data()
        
        // When & Then - Should not throw
        try await service.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
        
        // Verify the HTTP client was called correctly
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertEqual(mockHTTPClient.lastMethod, "PUT")
        XCTAssertNotNil(mockHTTPClient.lastBody)
        
        // Verify URL construction
        let expectedURL = try Gr4vyUtility.checkoutSessionFieldsURL(from: testSetup, checkoutSessionId: checkoutSessionId)
        XCTAssertEqual(mockHTTPClient.lastURL, expectedURL)
    }
    
    func testTokenizeAsyncWithClickToPay() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_67890"
        let cardData = Gr4vyCardData(paymentMethod: .clickToPay(ClickToPayPaymentMethod(
            merchantTransactionId: "merchant_txn_123",
            srcCorrelationId: "src_corr_456"
        )))
        
        mockHTTPClient.data = Data()
        
        // When & Then - Should not throw
        try await service.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
        
        // Verify the HTTP client was called correctly
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertEqual(mockHTTPClient.lastMethod, "PUT")
        XCTAssertNotNil(mockHTTPClient.lastBody)
    }
    
    func testTokenizeAsyncWithIdPayment() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_id_test"
        let cardData = Gr4vyCardData(paymentMethod: .id(IdPaymentMethod(
            id: "stored_payment_method_789",
            securityCode: "456"
        )))
        
        mockHTTPClient.data = Data()
        
        // When & Then - Should not throw
        try await service.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
        
        // Verify the HTTP client was called correctly
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertEqual(mockHTTPClient.lastMethod, "PUT")
        XCTAssertNotNil(mockHTTPClient.lastBody)
    }
    
    func testTokenizeAsyncNetworkError() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_error"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        
        let networkError = URLError(.notConnectedToInternet)
        mockHTTPClient.error = Gr4vyError.networkError(networkError)
        
        // When & Then - Should throw the network error
        do {
            try await service.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
            XCTFail("Expected error to be thrown")
        } catch let error as Gr4vyError {
            switch error {
            case .networkError(let urlError):
                XCTAssertEqual(urlError.code, .notConnectedToInternet)
            default:
                XCTFail("Expected network error, got \(error)")
            }
        }
    }
    
    func testTokenizeAsyncHTTPError() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_http_error"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        
        let httpError = Gr4vyError.httpError(statusCode: 400, responseData: Data(), message: "Bad Request")
        mockHTTPClient.error = httpError
        
        // When & Then - Should throw the HTTP error
        do {
            try await service.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
            XCTFail("Expected error to be thrown")
        } catch let error as Gr4vyError {
            switch error {
            case .httpError(let statusCode, _, let message):
                XCTAssertEqual(statusCode, 400)
                XCTAssertEqual(message, "Bad Request")
            default:
                XCTFail("Expected HTTP error, got \(error)")
            }
        }
    }
    
    // MARK: - Tokenize Tests (Completion Handler)
    
    func testTokenizeCompletionHandlerSuccess() throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_completion_success"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        
        mockHTTPClient.data = Data()
        
        let expectation = XCTestExpectation(description: "Tokenize completion")
        
        // When
        service.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData) { result in
            // Then
            switch result {
            case .success:
                // Expected success
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Verify the HTTP client was called correctly
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertEqual(mockHTTPClient.lastMethod, "PUT")
        XCTAssertNotNil(mockHTTPClient.lastBody)
    }
    
    func testTokenizeCompletionHandlerError() throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_completion_error"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        
        let networkError = URLError(.timedOut)
        mockHTTPClient.error = Gr4vyError.networkError(networkError)
        
        let expectation = XCTestExpectation(description: "Tokenize completion error")
        
        // When
        service.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected error, got success")
            case .failure(let error):
                if case .networkError(let urlError) = error as? Gr4vyError {
                    XCTAssertEqual(urlError.code, .timedOut)
                    expectation.fulfill()
                } else {
                    XCTFail("Expected network error, got \(error)")
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Request Body Validation Tests
    
    func testTokenizeRequestBodyEncoding() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_body_test"
        let cardPaymentMethod = CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )
        let cardData = Gr4vyCardData(paymentMethod: .card(cardPaymentMethod))
        
        mockHTTPClient.data = Data()
        
        // When
        try await service.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
        
        // Then - Verify request body was encoded correctly
        XCTAssertNotNil(mockHTTPClient.lastBody)
        
        if let requestBody = mockHTTPClient.lastBody {
            let jsonObject = try JSONSerialization.jsonObject(with: requestBody, options: [])
            
            guard let requestDict = jsonObject as? [String: Any],
                  let paymentMethodDict = requestDict["payment_method"] as? [String: Any] else {
                XCTFail("Failed to parse request body JSON structure")
                return
            }
            
            // Verify the payment method was encoded correctly
            XCTAssertEqual(paymentMethodDict["method"] as? String, "card")
            XCTAssertEqual(paymentMethodDict["number"] as? String, cardPaymentMethod.number)
            XCTAssertEqual(paymentMethodDict["expiration_date"] as? String, cardPaymentMethod.expirationDate)
            XCTAssertEqual(paymentMethodDict["security_code"] as? String, cardPaymentMethod.securityCode)
        }
    }
    
    func testTokenizeWithUpdatedSetupURL() async throws {
        // Given - Create service with updated setup instead of calling updateSetup()
        let updatedSetup = Gr4vySetup(
            gr4vyId: "updated-checkout-id",
            token: "updated-token",
            merchantId: "updated-merchant",
            server: .production,
            timeout: 45.0
        )
        
        let updatedConfiguration = Gr4vyHTTPConfiguration(
            setup: updatedSetup,
            debugMode: false,
            session: URLSession.shared
        )
        
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: updatedConfiguration
        )
        
        let checkoutSessionId = "checkout_session_updated"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        
        mockHTTPClient.data = Data()
        
        // When
        try await service.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
        
        // Then - Verify URL was constructed with updated setup
        let expectedURL = try Gr4vyUtility.checkoutSessionFieldsURL(from: updatedSetup, checkoutSessionId: checkoutSessionId)
        XCTAssertEqual(mockHTTPClient.lastURL, expectedURL)
    }
    
    // MARK: - Edge Case Tests
    
    func testTokenizeWithEmptyCheckoutSessionId() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "" // Empty session ID
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        
        // When & Then - Should handle gracefully or throw appropriate error
        do {
            try await service.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
            // If it doesn't throw, verify the URL was still constructed
            XCTAssertNotNil(mockHTTPClient.lastURL)
        } catch {
            // If it throws an error, that's also acceptable behavior
            XCTAssertTrue(error is Gr4vyError)
        }
    }
    
    func testTokenizeWithSpecialCharactersInSessionId() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_with-special.chars_123"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        
        mockHTTPClient.data = Data()
        
        // When & Then - Should handle special characters in URL encoding
        try await service.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
        
        // Verify URL was constructed
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertEqual(mockHTTPClient.lastMethod, "PUT")
    }
    
    // MARK: - Versioning Tests (Async)
    
    func testCallVersioningAsyncSuccess() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_version_123"
        
        // Mock versioning response
        let versioningResponse = """
        {
            "directory_server_id": "dir_server_001",
            "message_version": "2.2.0",
            "api_key": "test_api_key_12345"
        }
        """.data(using: .utf8)!
        
        mockHTTPClient.data = versioningResponse
        
        // When
        let result = try await service.callVersioning(checkoutSessionId: checkoutSessionId)
        
        // Then
        XCTAssertEqual(result.directoryServerId, "dir_server_001")
        XCTAssertEqual(result.messageVersion, "2.2.0")
        XCTAssertEqual(result.apiKey, "test_api_key_12345")
        
        // Verify the HTTP client was called correctly
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertEqual(mockHTTPClient.lastMethod, "GET")
        
        // Verify URL construction
        let expectedURL = try Gr4vyUtility.versioningURL(from: testSetup, checkoutSessionId: checkoutSessionId)
        XCTAssertEqual(mockHTTPClient.lastURL, expectedURL)
    }
    
    func testCallVersioningAsyncNetworkError() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_version_error"
        
        let networkError = URLError(.networkConnectionLost)
        mockHTTPClient.error = Gr4vyError.networkError(networkError)
        
        // When & Then - Should throw the network error
        do {
            _ = try await service.callVersioning(checkoutSessionId: checkoutSessionId)
            XCTFail("Expected error to be thrown")
        } catch let error as Gr4vyError {
            switch error {
            case .networkError(let urlError):
                XCTAssertEqual(urlError.code, .networkConnectionLost)
            default:
                XCTFail("Expected network error, got \(error)")
            }
        }
    }
    
    func testCallVersioningAsyncDecodingError() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_version_decode_error"
        
        // Mock invalid JSON response
        let invalidResponse = """
        {
            "invalid_field": "unexpected_value"
        }
        """.data(using: .utf8)!
        
        mockHTTPClient.data = invalidResponse
        
        // When & Then - Should throw decoding error
        do {
            _ = try await service.callVersioning(checkoutSessionId: checkoutSessionId)
            XCTFail("Expected decoding error to be thrown")
        } catch {
            // Expected to fail due to missing required fields
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    func testCallVersioningAsyncHTTPError() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_version_http_error"
        
        let httpError = Gr4vyError.httpError(statusCode: 404, responseData: Data(), message: "Not Found")
        mockHTTPClient.error = httpError
        
        // When & Then - Should throw the HTTP error
        do {
            _ = try await service.callVersioning(checkoutSessionId: checkoutSessionId)
            XCTFail("Expected error to be thrown")
        } catch let error as Gr4vyError {
            switch error {
            case .httpError(let statusCode, _, let message):
                XCTAssertEqual(statusCode, 404)
                XCTAssertEqual(message, "Not Found")
            default:
                XCTFail("Expected HTTP error, got \(error)")
            }
        }
    }
    
    // MARK: - Versioning Tests (Completion Handler)
    
    func testCallVersioningCompletionHandlerSuccess() throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_version_completion_success"
        
        // Mock versioning response
        let versioningResponse = """
        {
            "directory_server_id": "dir_server_002",
            "message_version": "2.1.0",
            "api_key": "test_api_key_67890"
        }
        """.data(using: .utf8)!
        
        mockHTTPClient.data = versioningResponse
        
        let expectation = XCTestExpectation(description: "Versioning completion")
        
        // When
        service.callVersioning(checkoutSessionId: checkoutSessionId) { result in
            // Then
            switch result {
            case .success(let response):
                XCTAssertEqual(response.directoryServerId, "dir_server_002")
                XCTAssertEqual(response.messageVersion, "2.1.0")
                XCTAssertEqual(response.apiKey, "test_api_key_67890")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Verify the HTTP client was called correctly
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertEqual(mockHTTPClient.lastMethod, "GET")
    }
    
    func testCallVersioningCompletionHandlerError() throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_version_completion_error"
        
        let networkError = URLError(.badServerResponse)
        mockHTTPClient.error = Gr4vyError.networkError(networkError)
        
        let expectation = XCTestExpectation(description: "Versioning completion error")
        
        // When
        service.callVersioning(checkoutSessionId: checkoutSessionId) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected error, got success")
            case .failure(let error):
                if case .networkError(let urlError) = error as? Gr4vyError {
                    XCTAssertEqual(urlError.code, .badServerResponse)
                    expectation.fulfill()
                } else {
                    XCTFail("Expected network error, got \(error)")
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Create Transaction Tests (Async)
    
    func testCreateTransactionAsyncWithChallengeResponse() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_3ds_challenge"
        let sdkAppId = "app_id_123"
        let sdkEncryptedData = "encrypted_data_xyz"
        let sdkEphemeralPubKey = SdkEphemeralPubKey(
            y: "y_coordinate_value",
            x: "x_coordinate_value",
            kty: "EC",
            crv: "P-256"
        )
        let sdkReferenceNumber = "ref_num_456"
        let sdkTransactionId = "txn_id_789"
        let sdkMaxTimeoutMinutes = 5
        
        // Mock 3DS challenge response
        let threeDSResponse = """
        {
            "indicator": "CHALLENGE",
            "challenge": {
                "server_transaction_id": "server_txn_123",
                "acs_transaction_id": "acs_txn_456",
                "acs_reference_number": "acs_ref_789",
                "acs_rendering_type": {
                    "acsInterface": "01",
                    "acsUiTemplate": "01",
                    "deviceUserInterfaceMode": "01"
                },
                "acs_signed_content": "signed_content_data"
            },
            "transaction_status": null,
            "cardholder_info": null
        }
        """.data(using: .utf8)!
        
        mockHTTPClient.data = threeDSResponse
        
        // When
        let result = try await service.createTransaction(
            checkoutSessionId: checkoutSessionId,
            sdkAppId: sdkAppId,
            sdkEncryptedData: sdkEncryptedData,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: sdkReferenceNumber,
            sdkTransactionId: sdkTransactionId,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
        )
        
        // Then
        XCTAssertEqual(result.indicator, "CHALLENGE")
        XCTAssertTrue(result.isChallenge)
        XCTAssertFalse(result.isFrictionless)
        XCTAssertFalse(result.isError)
        XCTAssertNotNil(result.challenge)
        XCTAssertEqual(result.challenge?.serverTransactionId, "server_txn_123")
        XCTAssertEqual(result.challenge?.acsTransactionId, "acs_txn_456")
        
        // Verify the HTTP client was called correctly
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertEqual(mockHTTPClient.lastMethod, "POST")
        XCTAssertNotNil(mockHTTPClient.lastBody)
        
        // Verify URL construction
        let expectedURL = try Gr4vyUtility.createTransactionURL(from: testSetup, checkoutSessionId: checkoutSessionId)
        XCTAssertEqual(mockHTTPClient.lastURL, expectedURL)
    }
    
    func testCreateTransactionAsyncWithFrictionlessResponse() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_3ds_frictionless"
        let sdkAppId = "app_id_frictionless"
        let sdkEncryptedData = "encrypted_data_frictionless"
        let sdkEphemeralPubKey = SdkEphemeralPubKey(
            y: "y_frictionless",
            x: "x_frictionless",
            kty: "EC",
            crv: "P-256"
        )
        let sdkReferenceNumber = "ref_num_frictionless"
        let sdkTransactionId = "txn_id_frictionless"
        let sdkMaxTimeoutMinutes = 5
        
        // Mock 3DS frictionless response
        let threeDSResponse = """
        {
            "indicator": "FINISH",
            "challenge": null,
            "transaction_status": "Y",
            "cardholder_info": "Authentication successful"
        }
        """.data(using: .utf8)!
        
        mockHTTPClient.data = threeDSResponse
        
        // When
        let result = try await service.createTransaction(
            checkoutSessionId: checkoutSessionId,
            sdkAppId: sdkAppId,
            sdkEncryptedData: sdkEncryptedData,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: sdkReferenceNumber,
            sdkTransactionId: sdkTransactionId,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
        )
        
        // Then
        XCTAssertEqual(result.indicator, "FINISH")
        XCTAssertTrue(result.isFrictionless)
        XCTAssertFalse(result.isChallenge)
        XCTAssertFalse(result.isError)
        XCTAssertNil(result.challenge)
        XCTAssertEqual(result.transactionStatus, "Y")
        XCTAssertEqual(result.cardholderInfo, "Authentication successful")
    }
    
    func testCreateTransactionAsyncWithErrorResponse() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_3ds_error"
        let sdkAppId = "app_id_error"
        let sdkEncryptedData = "encrypted_data_error"
        let sdkEphemeralPubKey = SdkEphemeralPubKey(
            y: "y_error",
            x: "x_error",
            kty: "EC",
            crv: "P-256"
        )
        let sdkReferenceNumber = "ref_num_error"
        let sdkTransactionId = "txn_id_error"
        let sdkMaxTimeoutMinutes = 5
        
        // Mock 3DS error response
        let threeDSResponse = """
        {
            "indicator": "ERROR",
            "challenge": null,
            "transaction_status": null,
            "cardholder_info": "Authentication failed"
        }
        """.data(using: .utf8)!
        
        mockHTTPClient.data = threeDSResponse
        
        // When
        let result = try await service.createTransaction(
            checkoutSessionId: checkoutSessionId,
            sdkAppId: sdkAppId,
            sdkEncryptedData: sdkEncryptedData,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: sdkReferenceNumber,
            sdkTransactionId: sdkTransactionId,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
        )
        
        // Then
        XCTAssertEqual(result.indicator, "ERROR")
        XCTAssertTrue(result.isError)
        XCTAssertFalse(result.isFrictionless)
        XCTAssertFalse(result.isChallenge)
        XCTAssertEqual(result.cardholderInfo, "Authentication failed")
    }
    
    func testCreateTransactionAsyncWithDebugMode() async throws {
        // Given
        let debugConfiguration = Gr4vyHTTPConfiguration(
            setup: testSetup,
            debugMode: true,
            session: URLSession.shared
        )
        
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: debugConfiguration
        )
        
        let checkoutSessionId = "checkout_session_3ds_debug"
        let sdkAppId = "app_id_debug"
        let sdkEncryptedData = "encrypted_data_debug"
        let sdkEphemeralPubKey = SdkEphemeralPubKey(
            y: "y_debug",
            x: "x_debug",
            kty: "EC",
            crv: "P-256"
        )
        let sdkReferenceNumber = "ref_num_debug"
        let sdkTransactionId = "txn_id_debug"
        let sdkMaxTimeoutMinutes = 5
        
        // Mock 3DS challenge response
        let threeDSResponse = """
        {
            "indicator": "CHALLENGE",
            "challenge": {
                "server_transaction_id": "server_txn_debug",
                "acs_transaction_id": "acs_txn_debug",
                "acs_reference_number": "acs_ref_debug",
                "acs_rendering_type": {
                    "acsInterface": "01",
                    "acsUiTemplate": "01",
                    "deviceUserInterfaceMode": "01"
                },
                "acs_signed_content": "signed_content_debug"
            },
            "transaction_status": null,
            "cardholder_info": null
        }
        """.data(using: .utf8)!
        
        mockHTTPClient.data = threeDSResponse
        
        // When
        let result = try await service.createTransaction(
            checkoutSessionId: checkoutSessionId,
            sdkAppId: sdkAppId,
            sdkEncryptedData: sdkEncryptedData,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: sdkReferenceNumber,
            sdkTransactionId: sdkTransactionId,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
        )
        
        // Then
        XCTAssertTrue(result.isChallenge)
        XCTAssertTrue(service.debugMode) // Verify debug mode is enabled
    }
    
    func testCreateTransactionAsyncNetworkError() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_3ds_network_error"
        let sdkAppId = "app_id_net_error"
        let sdkEncryptedData = "encrypted_data_net_error"
        let sdkEphemeralPubKey = SdkEphemeralPubKey(
            y: "y_net_error",
            x: "x_net_error",
            kty: "EC",
            crv: "P-256"
        )
        let sdkReferenceNumber = "ref_num_net_error"
        let sdkTransactionId = "txn_id_net_error"
        let sdkMaxTimeoutMinutes = 5
        
        let networkError = URLError(.cannotConnectToHost)
        mockHTTPClient.error = Gr4vyError.networkError(networkError)
        
        // When & Then - Should throw the network error
        do {
            _ = try await service.createTransaction(
                checkoutSessionId: checkoutSessionId,
                sdkAppId: sdkAppId,
                sdkEncryptedData: sdkEncryptedData,
                sdkEphemeralPubKey: sdkEphemeralPubKey,
                sdkReferenceNumber: sdkReferenceNumber,
                sdkTransactionId: sdkTransactionId,
                sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
            )
            XCTFail("Expected error to be thrown")
        } catch let error as Gr4vyError {
            switch error {
            case .networkError(let urlError):
                XCTAssertEqual(urlError.code, .cannotConnectToHost)
            default:
                XCTFail("Expected network error, got \(error)")
            }
        }
    }
    
    func testCreateTransactionAsyncHTTPError() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_3ds_http_error"
        let sdkAppId = "app_id_http_error"
        let sdkEncryptedData = "encrypted_data_http_error"
        let sdkEphemeralPubKey = SdkEphemeralPubKey(
            y: "y_http_error",
            x: "x_http_error",
            kty: "EC",
            crv: "P-256"
        )
        let sdkReferenceNumber = "ref_num_http_error"
        let sdkTransactionId = "txn_id_http_error"
        let sdkMaxTimeoutMinutes = 5
        
        let httpError = Gr4vyError.httpError(statusCode: 500, responseData: Data(), message: "Internal Server Error")
        mockHTTPClient.error = httpError
        
        // When & Then - Should throw the HTTP error
        do {
            _ = try await service.createTransaction(
                checkoutSessionId: checkoutSessionId,
                sdkAppId: sdkAppId,
                sdkEncryptedData: sdkEncryptedData,
                sdkEphemeralPubKey: sdkEphemeralPubKey,
                sdkReferenceNumber: sdkReferenceNumber,
                sdkTransactionId: sdkTransactionId,
                sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
            )
            XCTFail("Expected error to be thrown")
        } catch let error as Gr4vyError {
            switch error {
            case .httpError(let statusCode, _, let message):
                XCTAssertEqual(statusCode, 500)
                XCTAssertEqual(message, "Internal Server Error")
            default:
                XCTFail("Expected HTTP error, got \(error)")
            }
        }
    }
    
    func testCreateTransactionAsyncDecodingError() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_3ds_decode_error"
        let sdkAppId = "app_id_decode_error"
        let sdkEncryptedData = "encrypted_data_decode_error"
        let sdkEphemeralPubKey = SdkEphemeralPubKey(
            y: "y_decode_error",
            x: "x_decode_error",
            kty: "EC",
            crv: "P-256"
        )
        let sdkReferenceNumber = "ref_num_decode_error"
        let sdkTransactionId = "txn_id_decode_error"
        let sdkMaxTimeoutMinutes = 5
        
        // Mock invalid JSON response
        let invalidResponse = """
        {
            "invalid_field": "unexpected_value"
        }
        """.data(using: .utf8)!
        
        mockHTTPClient.data = invalidResponse
        
        // When & Then - Should throw decoding error
        do {
            _ = try await service.createTransaction(
                checkoutSessionId: checkoutSessionId,
                sdkAppId: sdkAppId,
                sdkEncryptedData: sdkEncryptedData,
                sdkEphemeralPubKey: sdkEphemeralPubKey,
                sdkReferenceNumber: sdkReferenceNumber,
                sdkTransactionId: sdkTransactionId,
                sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
            )
            XCTFail("Expected decoding error to be thrown")
        } catch {
            // Expected to fail due to missing required fields
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    // MARK: - Create Transaction Tests (Completion Handler)
    
    func testCreateTransactionCompletionHandlerSuccess() throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_3ds_completion_success"
        let sdkAppId = "app_id_completion"
        let sdkEncryptedData = "encrypted_data_completion"
        let sdkEphemeralPubKey = SdkEphemeralPubKey(
            y: "y_completion",
            x: "x_completion",
            kty: "EC",
            crv: "P-256"
        )
        let sdkReferenceNumber = "ref_num_completion"
        let sdkTransactionId = "txn_id_completion"
        let sdkMaxTimeoutMinutes = 5
        
        // Mock 3DS frictionless response
        let threeDSResponse = """
        {
            "indicator": "FINISH",
            "challenge": null,
            "transaction_status": "Y",
            "cardholder_info": "Success"
        }
        """.data(using: .utf8)!
        
        mockHTTPClient.data = threeDSResponse
        
        let expectation = XCTestExpectation(description: "Create transaction completion")
        
        // When
        service.createTransaction(
            checkoutSessionId: checkoutSessionId,
            sdkAppId: sdkAppId,
            sdkEncryptedData: sdkEncryptedData,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: sdkReferenceNumber,
            sdkTransactionId: sdkTransactionId,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
        ) { result in
            // Then
            switch result {
            case .success(let response):
                XCTAssertEqual(response.indicator, "FINISH")
                XCTAssertTrue(response.isFrictionless)
                XCTAssertEqual(response.transactionStatus, "Y")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Verify the HTTP client was called correctly
        XCTAssertNotNil(mockHTTPClient.lastURL)
        XCTAssertEqual(mockHTTPClient.lastMethod, "POST")
        XCTAssertNotNil(mockHTTPClient.lastBody)
    }
    
    func testCreateTransactionCompletionHandlerError() throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_3ds_completion_error"
        let sdkAppId = "app_id_completion_error"
        let sdkEncryptedData = "encrypted_data_completion_error"
        let sdkEphemeralPubKey = SdkEphemeralPubKey(
            y: "y_completion_error",
            x: "x_completion_error",
            kty: "EC",
            crv: "P-256"
        )
        let sdkReferenceNumber = "ref_num_completion_error"
        let sdkTransactionId = "txn_id_completion_error"
        let sdkMaxTimeoutMinutes = 5
        
        let networkError = URLError(.timedOut)
        mockHTTPClient.error = Gr4vyError.networkError(networkError)
        
        let expectation = XCTestExpectation(description: "Create transaction completion error")
        
        // When
        service.createTransaction(
            checkoutSessionId: checkoutSessionId,
            sdkAppId: sdkAppId,
            sdkEncryptedData: sdkEncryptedData,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: sdkReferenceNumber,
            sdkTransactionId: sdkTransactionId,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
        ) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected error, got success")
            case .failure(let error):
                if case .networkError(let urlError) = error as? Gr4vyError {
                    XCTAssertEqual(urlError.code, .timedOut)
                    expectation.fulfill()
                } else {
                    XCTFail("Expected network error, got \(error)")
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Request Body Validation Tests for Create Transaction
    
    func testCreateTransactionRequestBodyEncoding() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_3ds_body_test"
        let sdkAppId = "app_id_body_test"
        let sdkEncryptedData = "encrypted_data_body_test"
        let sdkEphemeralPubKey = SdkEphemeralPubKey(
            y: "y_body_test",
            x: "x_body_test",
            kty: "EC",
            crv: "P-256"
        )
        let sdkReferenceNumber = "ref_num_body_test"
        let sdkTransactionId = "txn_id_body_test"
        let sdkMaxTimeoutMinutes = 10
        
        // Mock 3DS response
        let threeDSResponse = """
        {
            "indicator": "FINISH",
            "challenge": null,
            "transaction_status": "Y",
            "cardholder_info": null
        }
        """.data(using: .utf8)!
        
        mockHTTPClient.data = threeDSResponse
        
        // When
        _ = try await service.createTransaction(
            checkoutSessionId: checkoutSessionId,
            sdkAppId: sdkAppId,
            sdkEncryptedData: sdkEncryptedData,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: sdkReferenceNumber,
            sdkTransactionId: sdkTransactionId,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
        )
        
        // Then - Verify request body was encoded correctly
        XCTAssertNotNil(mockHTTPClient.lastBody)
        
        if let requestBody = mockHTTPClient.lastBody {
            let jsonObject = try JSONSerialization.jsonObject(with: requestBody, options: [])
            
            guard let requestDict = jsonObject as? [String: Any] else {
                XCTFail("Failed to parse request body JSON structure")
                return
            }
            
            // Verify the request body contains expected fields
            XCTAssertEqual(requestDict["sdk_app_id"] as? String, sdkAppId)
            XCTAssertEqual(requestDict["sdk_encrypted_data"] as? String, sdkEncryptedData)
            XCTAssertEqual(requestDict["sdk_reference_number"] as? String, sdkReferenceNumber)
            XCTAssertEqual(requestDict["sdk_transaction_id"] as? String, sdkTransactionId)
            XCTAssertEqual(requestDict["sdk_max_timeout"] as? String, "10")
            XCTAssertEqual(requestDict["device_channel"] as? String, "01")
            
            // Verify device render options
            if let deviceRenderOptions = requestDict["device_render_options"] as? [String: Any] {
                XCTAssertEqual(deviceRenderOptions["sdkInterface"] as? String, "03")
                XCTAssertNotNil(deviceRenderOptions["sdkUiType"] as? [String])
            } else {
                XCTFail("Missing device_render_options in request body")
            }
            
            // Verify sdk ephemeral public key
            if let sdkEphemeralPubKeyDict = requestDict["sdk_ephemeral_pub_key"] as? [String: Any] {
                XCTAssertEqual(sdkEphemeralPubKeyDict["y"] as? String, "y_body_test")
                XCTAssertEqual(sdkEphemeralPubKeyDict["x"] as? String, "x_body_test")
                XCTAssertEqual(sdkEphemeralPubKeyDict["kty"] as? String, "EC")
                XCTAssertEqual(sdkEphemeralPubKeyDict["crv"] as? String, "P-256")
            } else {
                XCTFail("Missing sdk_ephemeral_pub_key in request body")
            }
        }
    }
    
    func testCreateTransactionWithMaxTimeoutPadding() async throws {
        // Given
        let service = Gr4vyCheckoutSessionService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let checkoutSessionId = "checkout_session_timeout_test"
        let sdkAppId = "app_id_timeout"
        let sdkEncryptedData = "encrypted_data_timeout"
        let sdkEphemeralPubKey = SdkEphemeralPubKey(
            y: "y_timeout",
            x: "x_timeout",
            kty: "EC",
            crv: "P-256"
        )
        let sdkReferenceNumber = "ref_num_timeout"
        let sdkTransactionId = "txn_id_timeout"
        let sdkMaxTimeoutMinutes = 5 // Should be encoded as "05"
        
        // Mock 3DS response
        let threeDSResponse = """
        {
            "indicator": "FINISH",
            "challenge": null,
            "transaction_status": "Y",
            "cardholder_info": null
        }
        """.data(using: .utf8)!
        
        mockHTTPClient.data = threeDSResponse
        
        // When
        _ = try await service.createTransaction(
            checkoutSessionId: checkoutSessionId,
            sdkAppId: sdkAppId,
            sdkEncryptedData: sdkEncryptedData,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: sdkReferenceNumber,
            sdkTransactionId: sdkTransactionId,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
        )
        
        // Then - Verify timeout is zero-padded
        XCTAssertNotNil(mockHTTPClient.lastBody)
        
        if let requestBody = mockHTTPClient.lastBody {
            let jsonObject = try JSONSerialization.jsonObject(with: requestBody, options: [])
            
            guard let requestDict = jsonObject as? [String: Any] else {
                XCTFail("Failed to parse request body JSON structure")
                return
            }
            
            // Verify timeout is formatted as "05" not "5"
            XCTAssertEqual(requestDict["sdk_max_timeout"] as? String, "05")
        }
    }
}
