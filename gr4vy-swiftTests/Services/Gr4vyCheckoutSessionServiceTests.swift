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
            case .success():
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
            case .success():
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
}
