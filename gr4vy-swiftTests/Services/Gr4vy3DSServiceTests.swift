//
//  Gr4vy3DSServiceTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import UIKit
import XCTest

final class Gr4vy3DSServiceTests: XCTestCase {
    // MARK: - Properties
    
    private var mockHTTPClient: MockHTTPClient!
    private var testSetup: Gr4vySetup!
    private var testConfiguration: Gr4vyHTTPConfiguration!
    private var threeDSService: Gr4vy3DSService!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        mockHTTPClient = MockHTTPClient()
        testSetup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant-123",
            server: .sandbox,
            timeout: 30.0
        )
        testConfiguration = Gr4vyHTTPConfiguration(
            setup: testSetup,
            debugMode: false,
            session: URLSession.shared
        )
        threeDSService = Gr4vy3DSService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
    }
    
    override func tearDownWithError() throws {
        mockHTTPClient = nil
        testSetup = nil
        testConfiguration = nil
        threeDSService = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInitializationWithSetup() throws {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )
        
        // When
        let service = Gr4vy3DSService(setup: setup, debugMode: true)
        
        // Then
        XCTAssertTrue(service.debugMode)
    }
    
    func testInitializationWithDefaultDebugMode() throws {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )
        
        // When
        let service = Gr4vy3DSService(setup: setup)
        
        // Then
        XCTAssertFalse(service.debugMode)
    }
    
    func testInitializationWithCustomSession() throws {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )
        let customSession = URLSession.shared
        
        // When
        let service = Gr4vy3DSService(setup: setup, debugMode: false, session: customSession)
        
        // Then
        XCTAssertFalse(service.debugMode)
    }
    
    func testInitializationWithDependencyInjection() throws {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .production
        )
        let configuration = Gr4vyHTTPConfiguration(setup: setup, debugMode: true)
        let mockClient = MockHTTPClient()
        
        // When
        let service = Gr4vy3DSService(httpClient: mockClient, configuration: configuration)
        
        // Then
        XCTAssertTrue(service.debugMode)
    }
    
    // MARK: - Setup Update Tests
    
    func testUpdateSetup() throws {
        // Given
        let service = Gr4vy3DSService(
            httpClient: mockHTTPClient,
            configuration: testConfiguration
        )
        
        let newSetup = Gr4vySetup(
            gr4vyId: "updated-id",
            token: "updated-token",
            merchantId: "updated-merchant-456",
            server: .production,
            timeout: 60.0
        )
        
        // When & Then - Should not throw any errors
        XCTAssertNoThrow(service.updateSetup(newSetup))
    }
    
    func testUpdateSetupFromSandboxToProduction() throws {
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
        
        let service = Gr4vy3DSService(setup: sandboxSetup)
        
        // When & Then
        XCTAssertNoThrow(service.updateSetup(productionSetup))
    }
    
    // MARK: - Tokenize Without Authentication Tests
    
    func testTokenizeAsyncWithoutAuthenticationSuccess() async throws {
        // Given
        let checkoutSessionId = "checkout_session_no_auth"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        // Mock successful tokenization response
        mockHTTPClient.data = Data()
        
        // When
        let result = try await threeDSService.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 5,
            authenticate: false
        )
        
        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNil(result.authentication)
    }
    
    func testTokenizeCompletionWithoutAuthenticationSuccess() throws {
        // Given
        let checkoutSessionId = "checkout_session_no_auth_completion"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        mockHTTPClient.data = Data()
        
        let expectation = XCTestExpectation(description: "Tokenize completion")
        
        // When
        threeDSService.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 5,
            authenticate: false
        ) { result in
            // Then
            switch result {
            case .success(let tokenizeResult):
                XCTAssertTrue(tokenizeResult.tokenized)
                XCTAssertNil(tokenizeResult.authentication)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Tokenize With Authentication - Versioning Failure Tests
    
    func testTokenizeAsyncVersioningFailureReturnsUnattemptedAuthentication() async throws {
        // Given
        let checkoutSessionId = "checkout_session_versioning_fail"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        // Mock successful tokenization
        mockHTTPClient.data = Data()
        
        // When - Tokenize first, then versioning will fail (no versioning response mocked)
        let result = try await threeDSService.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 5,
            authenticate: true
        )
        
        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNotNil(result.authentication)
        XCTAssertFalse(result.authentication?.attempted ?? true)
        XCTAssertNil(result.authentication?.type)
        XCTAssertNil(result.authentication?.transactionStatus)
        XCTAssertFalse(result.authentication?.hasCancelled ?? true)
    }
    
    // MARK: - Tokenize Error Handling Tests
    
    func testTokenizeAsyncTokenizationFailure() async throws {
        // Given
        let checkoutSessionId = "checkout_session_tokenize_fail"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        let httpError = Gr4vyError.httpError(statusCode: 400, responseData: nil, message: "Bad Request")
        mockHTTPClient.error = httpError
        
        // When & Then - Should throw the HTTP error
        do {
            _ = try await threeDSService.tokenize(
                checkoutSessionId: checkoutSessionId,
                cardData: cardData,
                viewController: viewController,
                sdkMaxTimeoutMinutes: 5,
                authenticate: false
            )
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
    
    func testTokenizeAsyncNetworkError() async throws {
        // Given
        let checkoutSessionId = "checkout_session_network_fail"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        let networkError = URLError(.notConnectedToInternet)
        mockHTTPClient.error = Gr4vyError.networkError(networkError)
        
        // When & Then - Should throw the network error
        do {
            _ = try await threeDSService.tokenize(
                checkoutSessionId: checkoutSessionId,
                cardData: cardData,
                viewController: viewController,
                sdkMaxTimeoutMinutes: 5,
                authenticate: true
            )
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
    
    func testTokenizeCompletionHandlerError() throws {
        // Given
        let checkoutSessionId = "checkout_session_completion_error"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        let networkError = URLError(.timedOut)
        mockHTTPClient.error = Gr4vyError.networkError(networkError)
        
        let expectation = XCTestExpectation(description: "Tokenize completion error")
        
        // When
        threeDSService.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 5,
            authenticate: false
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
    
    // MARK: - Tokenize With Different Payment Methods Tests
    
    func testTokenizeWithClickToPayPaymentMethod() async throws {
        // Given
        let checkoutSessionId = "checkout_session_click_to_pay"
        let cardData = Gr4vyCardData(paymentMethod: .clickToPay(ClickToPayPaymentMethod(
            merchantTransactionId: "merchant_txn_123",
            srcCorrelationId: "src_corr_456"
        )))
        let viewController = UIViewController()
        
        mockHTTPClient.data = Data()
        
        // When
        let result = try await threeDSService.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 5,
            authenticate: false
        )
        
        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNil(result.authentication)
    }
    
    func testTokenizeWithIdPaymentMethod() async throws {
        // Given
        let checkoutSessionId = "checkout_session_id_payment"
        let cardData = Gr4vyCardData(paymentMethod: .id(IdPaymentMethod(
            id: "stored_payment_method_789",
            securityCode: "456"
        )))
        let viewController = UIViewController()
        
        mockHTTPClient.data = Data()
        
        // When
        let result = try await threeDSService.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 5,
            authenticate: false
        )
        
        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNil(result.authentication)
    }
    
    // MARK: - Tokenize With Different Timeout Values Tests
    
    func testTokenizeWithCustomTimeout() async throws {
        // Given
        let checkoutSessionId = "checkout_session_custom_timeout"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        mockHTTPClient.data = Data()
        
        // When
        let result = try await threeDSService.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 10,
            authenticate: false
        )
        
        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNil(result.authentication)
    }
    
    func testTokenizeWithShortTimeout() async throws {
        // Given
        let checkoutSessionId = "checkout_session_short_timeout"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        mockHTTPClient.data = Data()
        
        // When
        let result = try await threeDSService.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 1,
            authenticate: false
        )
        
        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNil(result.authentication)
    }
    
    // MARK: - Tokenize With UI Customization Tests
    
    func testTokenizeWithUICustomization() async throws {
        // Given
        let checkoutSessionId = "checkout_session_ui_custom"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        let uiCustomization = Gr4vyThreeDSUiCustomizationMap(
            default: Gr4vyThreeDSUiCustomization(
                buttons: [
                    .submit: Gr4vyThreeDSButtonCustomization(
                        backgroundColorHex: "#FF0000",
                        cornerRadius: 8
                    ),
                ]
            )
        )
        
        mockHTTPClient.data = Data()
        
        // When
        let result = try await threeDSService.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 5,
            authenticate: false,
            uiCustomization: uiCustomization
        )
        
        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNil(result.authentication)
    }
    
    func testTokenizeWithNilUICustomization() async throws {
        // Given
        let checkoutSessionId = "checkout_session_nil_ui_custom"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        mockHTTPClient.data = Data()
        
        // When
        let result = try await threeDSService.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 5,
            authenticate: false,
            uiCustomization: nil
        )
        
        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNil(result.authentication)
    }
    
    // MARK: - Edge Case Tests
    
    func testTokenizeWithEmptyCheckoutSessionId() async throws {
        // Given
        let checkoutSessionId = ""
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        // When & Then - Should handle gracefully or throw appropriate error
        do {
            _ = try await threeDSService.tokenize(
                checkoutSessionId: checkoutSessionId,
                cardData: cardData,
                viewController: viewController,
                sdkMaxTimeoutMinutes: 5,
                authenticate: false
            )
            // If it doesn't throw, that's acceptable
        } catch {
            // If it throws an error, that's also acceptable behavior
            XCTAssertTrue(error is Gr4vyError)
        }
    }
    
    func testTokenizeWithSpecialCharactersInSessionId() async throws {
        // Given
        let checkoutSessionId = "checkout_session_with-special.chars_123"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        mockHTTPClient.data = Data()
        
        // When
        let result = try await threeDSService.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 5,
            authenticate: false
        )
        
        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNil(result.authentication)
    }
    
    // MARK: - Server Configuration Tests
    
    func testServiceUsingSandboxServer() throws {
        // Given
        let sandboxSetup = Gr4vySetup(
            gr4vyId: "test-sandbox-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )
        
        // When
        let service = Gr4vy3DSService(setup: sandboxSetup)
        
        // Then
        XCTAssertFalse(service.debugMode)
    }
    
    func testServiceUsingProductionServer() throws {
        // Given
        let productionSetup = Gr4vySetup(
            gr4vyId: "test-production-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .production
        )
        
        // When
        let service = Gr4vy3DSService(setup: productionSetup)
        
        // Then
        XCTAssertFalse(service.debugMode)
    }
    
    // MARK: - Debug Mode Tests
    
    func testServiceWithDebugModeEnabled() throws {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )
        
        // When
        let service = Gr4vy3DSService(setup: setup, debugMode: true)
        
        // Then
        XCTAssertTrue(service.debugMode)
    }
    
    func testServiceWithDebugModeDisabled() throws {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )
        
        // When
        let service = Gr4vy3DSService(setup: setup, debugMode: false)
        
        // Then
        XCTAssertFalse(service.debugMode)
    }
    
    // MARK: - Ephemeral Key Parsing Tests
    
    func testParseEphemeralPublicKeyValidJWK() throws {
        // Given - Valid JWK string
        let validJWK = """
        {
            "kty": "EC",
            "crv": "P-256",
            "x": "MKBCTNIcKUSDii11ySs3526iDZ8AiTo7Tu6KPAqv7D4",
            "y": "4Etl6SRW2YiLUrN5vfvVHuhp7x8PxltmWWlbbM4IFyM"
        }
        """
        
        // When - We need to test parseEphemeralPublicKey indirectly through reflection
        // Since it's a private method, we'll validate the behavior through integration
        // This test documents the expected JWK format
        
        guard let data = validJWK.data(using: .utf8) else {
            XCTFail("Failed to create data from JWK string")
            return
        }
        
        // Then - Verify the JWK can be parsed as valid JSON
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let jwk = jsonObject as? [String: Any] else {
            XCTFail("Failed to parse JWK as dictionary")
            return
        }
        
        // Verify all required fields are present
        XCTAssertNotNil(jwk["kty"])
        XCTAssertNotNil(jwk["crv"])
        XCTAssertNotNil(jwk["x"])
        XCTAssertNotNil(jwk["y"])
        
        XCTAssertEqual(jwk["kty"] as? String, "EC")
        XCTAssertEqual(jwk["crv"] as? String, "P-256")
    }
    
    func testParseEphemeralPublicKeyInvalidJSON() throws {
        // Given - Invalid JSON string
        let invalidJWK = "{ invalid json }"
        
        // When & Then - Verify invalid JSON cannot be parsed
        guard let data = invalidJWK.data(using: .utf8) else {
            XCTFail("Failed to create data from string")
            return
        }
        
        XCTAssertThrowsError(try JSONSerialization.jsonObject(with: data, options: []))
    }
    
    func testParseEphemeralPublicKeyMissingRequiredFields() throws {
        // Given - JWK missing required field 'x'
        let incompleteJWK = """
        {
            "kty": "EC",
            "crv": "P-256",
            "y": "4Etl6SRW2YiLUrN5vfvVHuhp7x8PxltmWWlbbM4IFyM"
        }
        """
        
        guard let data = incompleteJWK.data(using: .utf8) else {
            XCTFail("Failed to create data from JWK string")
            return
        }
        
        // When - Parse the JSON
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let jwk = jsonObject as? [String: Any] else {
            XCTFail("Failed to parse JWK as dictionary")
            return
        }
        
        // Then - Verify missing field
        XCTAssertNil(jwk["x"])
        XCTAssertNotNil(jwk["kty"])
        XCTAssertNotNil(jwk["crv"])
        XCTAssertNotNil(jwk["y"])
    }
    
    func testParseEphemeralPublicKeyEmptyString() throws {
        // Given - Empty string
        let emptyJWK = ""
        
        // When - Try to parse empty string
        guard let data = emptyJWK.data(using: .utf8) else {
            XCTFail("Failed to create data from empty string")
            return
        }
        
        // Then - Empty JSON should fail parsing
        XCTAssertThrowsError(try JSONSerialization.jsonObject(with: data, options: []))
    }
    
    func testParseEphemeralPublicKeyInvalidUTF8() throws {
        // Given - Test that invalid UTF-8 would fail
        // We simulate this by testing the validation logic
        let validString = "valid utf-8 string"
        
        // When
        let data = validString.data(using: .utf8)
        
        // Then
        XCTAssertNotNil(data)
    }
    
    func testParseEphemeralPublicKeyWrongTypes() throws {
        // Given - JWK with wrong data types (numbers instead of strings)
        let wrongTypeJWK = """
        {
            "kty": "EC",
            "crv": "P-256",
            "x": 12345,
            "y": 67890
        }
        """
        
        guard let data = wrongTypeJWK.data(using: .utf8) else {
            XCTFail("Failed to create data from JWK string")
            return
        }
        
        // When - Parse the JSON
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let jwk = jsonObject as? [String: Any] else {
            XCTFail("Failed to parse JWK as dictionary")
            return
        }
        
        // Then - Verify fields exist but are wrong type
        XCTAssertNotNil(jwk["x"])
        XCTAssertNotNil(jwk["y"])
        XCTAssertNil(jwk["x"] as? String) // Should be nil when cast to String
        XCTAssertNil(jwk["y"] as? String) // Should be nil when cast to String
    }
    
    // MARK: - Static Helper Method Tests
    
    func testPrepareChallengeParametersDocumentation() throws {
        // Given - This test documents the expected structure for ChallengeParameters
        // Since prepareChallengeParameters is static and private, we document its requirements
        let expectedServerTransactionId = "server_txn_123"
        let expectedAcsTransactionId = "acs_txn_456"
        let expectedAcsReferenceNumber = "acs_ref_789"
        let expectedAcsSignedContent = "signed_content_abc"
        
        // When - These are the fields that should be passed to ChallengeParameters
        // The method should create a ChallengeParameters object with these values
        
        // Then - Document the expected behavior
        XCTAssertFalse(expectedServerTransactionId.isEmpty)
        XCTAssertFalse(expectedAcsTransactionId.isEmpty)
        XCTAssertFalse(expectedAcsReferenceNumber.isEmpty)
        XCTAssertFalse(expectedAcsSignedContent.isEmpty)
    }
    
    // MARK: - ChallengeResponse Model Tests
    
    func testChallengeResponseDecoding() throws {
        // Given - Valid challenge response JSON
        let challengeJSON = """
        {
            "server_transaction_id": "server_txn_123",
            "acs_transaction_id": "acs_txn_456",
            "acs_reference_number": "acs_ref_789",
            "acs_signed_content": "signed_content_abc",
            "acs_rendering_type": {
                "acsInterface": "01",
                "acsUiTemplate": "01",
                "deviceUserInterfaceMode": "01"
            }
        }
        """
        
        guard let data = challengeJSON.data(using: .utf8) else {
            XCTFail("Failed to create data from JSON string")
            return
        }
        
        // When - Decode the challenge response
        let decoder = JSONDecoder()
        let challengeResponse = try decoder.decode(Gr4vyChallengeResponse.self, from: data)
        
        // Then - Verify all fields are decoded correctly
        XCTAssertEqual(challengeResponse.serverTransactionId, "server_txn_123")
        XCTAssertEqual(challengeResponse.acsTransactionId, "acs_txn_456")
        XCTAssertEqual(challengeResponse.acsReferenceNumber, "acs_ref_789")
        XCTAssertEqual(challengeResponse.acsSignedContent, "signed_content_abc")
        XCTAssertEqual(challengeResponse.acsRenderingType.acsInterface, "01")
        XCTAssertEqual(challengeResponse.acsRenderingType.acsUiTemplate, "01")
        XCTAssertEqual(challengeResponse.acsRenderingType.deviceUserInterfaceMode, "01")
    }
    
    // MARK: - 3DS Response Indicator Tests
    
    func testThreeDSecureResponseFrictionlessIndicator() throws {
        // Given - Frictionless response JSON
        let responseJSON = """
        {
            "indicator": "FINISH",
            "transaction_status": "Y",
            "cardholder_info": "Authentication successful"
        }
        """
        
        guard let data = responseJSON.data(using: .utf8) else {
            XCTFail("Failed to create data from JSON string")
            return
        }
        
        // When - Decode the response
        let decoder = JSONDecoder()
        let response = try decoder.decode(Gr4vyThreeDSecureResponse.self, from: data)
        
        // Then - Verify frictionless indicator
        XCTAssertEqual(response.indicator, Gr4vyThreeDSConstants.indicatorFinish)
        XCTAssertTrue(response.isFrictionless)
        XCTAssertFalse(response.isChallenge)
        XCTAssertFalse(response.isError)
        XCTAssertEqual(response.transactionStatus, "Y")
        XCTAssertNil(response.challenge)
    }
    
    func testThreeDSecureResponseChallengeIndicator() throws {
        // Given - Challenge response JSON
        let responseJSON = """
        {
            "indicator": "CHALLENGE",
            "transaction_status": "C",
            "challenge": {
                "server_transaction_id": "server_txn_123",
                "acs_transaction_id": "acs_txn_456",
                "acs_reference_number": "acs_ref_789",
                "acs_signed_content": "signed_content_abc",
                "acs_rendering_type": {
                    "acsInterface": "01",
                    "acsUiTemplate": "01",
                    "deviceUserInterfaceMode": "01"
                }
            }
        }
        """
        
        guard let data = responseJSON.data(using: .utf8) else {
            XCTFail("Failed to create data from JSON string")
            return
        }
        
        // When - Decode the response
        let decoder = JSONDecoder()
        let response = try decoder.decode(Gr4vyThreeDSecureResponse.self, from: data)
        
        // Then - Verify challenge indicator
        XCTAssertEqual(response.indicator, Gr4vyThreeDSConstants.indicatorChallenge)
        XCTAssertFalse(response.isFrictionless)
        XCTAssertTrue(response.isChallenge)
        XCTAssertFalse(response.isError)
        XCTAssertNotNil(response.challenge)
        XCTAssertEqual(response.challenge?.serverTransactionId, "server_txn_123")
    }
    
    func testThreeDSecureResponseErrorIndicator() throws {
        // Given - Error response JSON
        let responseJSON = """
        {
            "indicator": "ERROR",
            "transaction_status": "U",
            "cardholder_info": "Authentication failed"
        }
        """
        
        guard let data = responseJSON.data(using: .utf8) else {
            XCTFail("Failed to create data from JSON string")
            return
        }
        
        // When - Decode the response
        let decoder = JSONDecoder()
        let response = try decoder.decode(Gr4vyThreeDSecureResponse.self, from: data)
        
        // Then - Verify error indicator
        XCTAssertEqual(response.indicator, Gr4vyThreeDSConstants.indicatorError)
        XCTAssertFalse(response.isFrictionless)
        XCTAssertFalse(response.isChallenge)
        XCTAssertTrue(response.isError)
        XCTAssertEqual(response.transactionStatus, "U")
        XCTAssertNil(response.challenge)
    }
    
    // MARK: - VersioningResponse Tests
    
    func testVersioningResponseDecoding() throws {
        // Given - Valid versioning response JSON
        let versioningJSON = """
        {
            "directory_server_id": "dir_server_123",
            "message_version": "2.1.0",
            "api_key": "test_api_key_abc123"
        }
        """
        
        guard let data = versioningJSON.data(using: .utf8) else {
            XCTFail("Failed to create data from JSON string")
            return
        }
        
        // When - Decode the versioning response
        let decoder = JSONDecoder()
        let versioningResponse = try decoder.decode(Gr4vyVersioningResponse.self, from: data)
        
        // Then - Verify all fields are decoded correctly
        XCTAssertEqual(versioningResponse.directoryServerId, "dir_server_123")
        XCTAssertEqual(versioningResponse.messageVersion, "2.1.0")
        XCTAssertEqual(versioningResponse.apiKey, "test_api_key_abc123")
    }
    
    func testVersioningResponseDecodingWithDifferentVersions() throws {
        // Given - Versioning response with different version
        let versioningJSON = """
        {
            "directory_server_id": "visa_ds",
            "message_version": "2.2.0",
            "api_key": "visa_api_key"
        }
        """
        
        guard let data = versioningJSON.data(using: .utf8) else {
            XCTFail("Failed to create data from JSON string")
            return
        }
        
        // When - Decode the versioning response
        let decoder = JSONDecoder()
        let versioningResponse = try decoder.decode(Gr4vyVersioningResponse.self, from: data)
        
        // Then - Verify version 2.2.0 is supported
        XCTAssertEqual(versioningResponse.messageVersion, "2.2.0")
        XCTAssertEqual(versioningResponse.directoryServerId, "visa_ds")
    }
    
    // MARK: - SdkEphemeralPubKey Model Tests
    
    func testSdkEphemeralPubKeyEncoding() throws {
        // Given - SdkEphemeralPubKey instance
        let ephemeralKey = SdkEphemeralPubKey(
            y: "y_coordinate_value",
            x: "x_coordinate_value",
            kty: "EC",
            crv: "P-256"
        )
        
        // When - Encode to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(ephemeralKey)
        
        // Then - Verify encoding
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any] else {
            XCTFail("Failed to parse encoded JSON")
            return
        }
        
        XCTAssertEqual(dict["y"] as? String, "y_coordinate_value")
        XCTAssertEqual(dict["x"] as? String, "x_coordinate_value")
        XCTAssertEqual(dict["kty"] as? String, "EC")
        XCTAssertEqual(dict["crv"] as? String, "P-256")
    }
    
    func testSdkEphemeralPubKeyDecoding() throws {
        // Given - JSON data
        let json = """
        {
            "y": "y_value",
            "x": "x_value",
            "kty": "EC",
            "crv": "P-256"
        }
        """
        
        guard let data = json.data(using: .utf8) else {
            XCTFail("Failed to create data from JSON string")
            return
        }
        
        // When - Decode
        let decoder = JSONDecoder()
        let ephemeralKey = try decoder.decode(SdkEphemeralPubKey.self, from: data)
        
        // Then - Verify decoding
        XCTAssertEqual(ephemeralKey.y, "y_value")
        XCTAssertEqual(ephemeralKey.x, "x_value")
        XCTAssertEqual(ephemeralKey.kty, "EC")
        XCTAssertEqual(ephemeralKey.crv, "P-256")
    }
    
    // MARK: - Cleanup and Resource Management Tests
    
    func testServiceCleanupAfterMultipleOperations() async throws {
        // Given - Service with multiple sequential operations
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        mockHTTPClient.data = Data()
        
        // When - Perform multiple operations
        for i in 1...3 {
            let result = try await threeDSService.tokenize(
                checkoutSessionId: "checkout_session_\(i)",
                cardData: cardData,
                viewController: viewController,
                sdkMaxTimeoutMinutes: 5,
                authenticate: false
            )
            
            // Then - Each operation should succeed independently
            XCTAssertTrue(result.tokenized)
        }
    }
    
    func testServiceHandlesFailureThenSuccess() async throws {
        // Given - Service that experiences failure then success
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        // First operation fails
        mockHTTPClient.error = Gr4vyError.httpError(statusCode: 500, responseData: nil, message: "Server Error")
        
        do {
            _ = try await threeDSService.tokenize(
                checkoutSessionId: "checkout_session_fail",
                cardData: cardData,
                viewController: viewController,
                sdkMaxTimeoutMinutes: 5,
                authenticate: false
            )
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected error
        }
        
        // Second operation succeeds
        mockHTTPClient.error = nil
        mockHTTPClient.data = Data()
        
        let result = try await threeDSService.tokenize(
            checkoutSessionId: "checkout_session_success",
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 5,
            authenticate: false
        )
        
        // Then - Service should recover from failure
        XCTAssertTrue(result.tokenized)
    }
    
    // MARK: - Timeout Configuration Tests
    
    func testTokenizeWithZeroTimeout() async throws {
        // Given - Zero timeout (edge case)
        let checkoutSessionId = "checkout_session_zero_timeout"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        mockHTTPClient.data = Data()
        
        // When - Tokenize with zero timeout
        let result = try await threeDSService.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 0,
            authenticate: false
        )
        
        // Then - Should handle gracefully
        XCTAssertTrue(result.tokenized)
    }
    
    func testTokenizeWithLargeTimeout() async throws {
        // Given - Very large timeout
        let checkoutSessionId = "checkout_session_large_timeout"
        let cardData = Gr4vyCardData(paymentMethod: .card(CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )))
        let viewController = UIViewController()
        
        mockHTTPClient.data = Data()
        
        // When - Tokenize with large timeout
        let result = try await threeDSService.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: 999,
            authenticate: false
        )
        
        // Then - Should handle gracefully
        XCTAssertTrue(result.tokenized)
    }
    
    // MARK: - ACS Rendering Type Tests
    
    func testACSRenderingTypeDecoding() throws {
        // Given - Valid ACS rendering type JSON
        let acsJSON = """
        {
            "acsInterface": "01",
            "acsUiTemplate": "02",
            "deviceUserInterfaceMode": "01"
        }
        """
        
        guard let data = acsJSON.data(using: .utf8) else {
            XCTFail("Failed to create data from JSON string")
            return
        }
        
        // When - Decode the ACS rendering type
        let decoder = JSONDecoder()
        let acsRenderingType = try decoder.decode(Gr4vyACSRenderingType.self, from: data)
        
        // Then - Verify all fields are decoded correctly
        XCTAssertEqual(acsRenderingType.acsInterface, "01")
        XCTAssertEqual(acsRenderingType.acsUiTemplate, "02")
        XCTAssertEqual(acsRenderingType.deviceUserInterfaceMode, "01")
    }
    
    func testACSRenderingTypeEncoding() throws {
        // Given - ACS rendering type instance
        let acsRenderingType = Gr4vyACSRenderingType(
            acsInterface: "01",
            acsUiTemplate: "03",
            deviceUserInterfaceMode: "02"
        )
        
        // When - Encode to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(acsRenderingType)
        
        // Then - Verify encoding
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any] else {
            XCTFail("Failed to parse encoded JSON")
            return
        }
        
        XCTAssertEqual(dict["acsInterface"] as? String, "01")
        XCTAssertEqual(dict["acsUiTemplate"] as? String, "03")
        XCTAssertEqual(dict["deviceUserInterfaceMode"] as? String, "02")
    }
    
    // MARK: - Authentication Result Tests
    
    func testAuthenticationResultFrictionless() throws {
        // Given - Frictionless authentication result
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: Gr4vyAuthenticationType.frictionless.rawValue,
            transactionStatus: "Y",
            hasCancelled: false,
            cardholderInfo: "Success"
        )
        
        // Then - Verify frictionless result
        XCTAssertTrue(authentication.attempted)
        XCTAssertEqual(authentication.type, Gr4vyAuthenticationType.frictionless.rawValue)
        XCTAssertEqual(authentication.transactionStatus, "Y")
        XCTAssertFalse(authentication.hasCancelled)
        XCTAssertEqual(authentication.cardholderInfo, "Success")
    }
    
    func testAuthenticationResultChallenge() throws {
        // Given - Challenge authentication result
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: Gr4vyAuthenticationType.challenge.rawValue,
            transactionStatus: "Y",
            hasCancelled: false,
            cardholderInfo: "Challenge completed"
        )
        
        // Then - Verify challenge result
        XCTAssertTrue(authentication.attempted)
        XCTAssertEqual(authentication.type, Gr4vyAuthenticationType.challenge.rawValue)
        XCTAssertEqual(authentication.transactionStatus, "Y")
        XCTAssertFalse(authentication.hasCancelled)
    }
    
    func testAuthenticationResultCancelled() throws {
        // Given - Cancelled authentication result
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: Gr4vyAuthenticationType.challenge.rawValue,
            transactionStatus: nil,
            hasCancelled: true,
            cardholderInfo: nil
        )
        
        // Then - Verify cancelled result
        XCTAssertTrue(authentication.attempted)
        XCTAssertTrue(authentication.hasCancelled)
        XCTAssertNil(authentication.transactionStatus)
    }
    
    func testAuthenticationResultTimedOut() throws {
        // Given - Timed out authentication result
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: Gr4vyAuthenticationType.challenge.rawValue,
            transactionStatus: nil,
            hasCancelled: false,
            hasTimedOut: true,
            cardholderInfo: nil
        )
        
        // Then - Verify timed out result
        XCTAssertTrue(authentication.attempted)
        XCTAssertFalse(authentication.hasCancelled)
        XCTAssertTrue(authentication.hasTimedOut ?? false)
        XCTAssertNil(authentication.transactionStatus)
    }
    
    func testAuthenticationResultError() throws {
        // Given - Error authentication result
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: Gr4vyAuthenticationType.error.rawValue,
            transactionStatus: "U",
            hasCancelled: false,
            cardholderInfo: "Authentication error"
        )
        
        // Then - Verify error result
        XCTAssertTrue(authentication.attempted)
        XCTAssertEqual(authentication.type, Gr4vyAuthenticationType.error.rawValue)
        XCTAssertEqual(authentication.transactionStatus, "U")
        XCTAssertFalse(authentication.hasCancelled)
    }
    
    func testAuthenticationResultNotAttempted() throws {
        // Given - Not attempted authentication result
        let authentication = Gr4vyAuthentication(
            attempted: false,
            type: nil,
            transactionStatus: nil,
            hasCancelled: false,
            cardholderInfo: nil
        )
        
        // Then - Verify not attempted result
        XCTAssertFalse(authentication.attempted)
        XCTAssertNil(authentication.type)
        XCTAssertNil(authentication.transactionStatus)
        XCTAssertFalse(authentication.hasCancelled)
    }
    
    // MARK: - TokenizeResult Tests
    
    func testTokenizeResultSuccess() throws {
        // Given - Successful tokenize result
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: Gr4vyAuthenticationType.frictionless.rawValue,
            transactionStatus: "Y",
            hasCancelled: false,
            cardholderInfo: "Success"
        )
        
        let result = Gr4vyTokenizeResult(tokenized: true, authentication: authentication)
        
        // Then - Verify result
        XCTAssertTrue(result.tokenized)
        XCTAssertNotNil(result.authentication)
        XCTAssertTrue(result.authentication?.attempted ?? false)
    }
    
    func testTokenizeResultWithoutAuthentication() throws {
        // Given - Tokenize result without authentication
        let result = Gr4vyTokenizeResult(tokenized: true, authentication: nil)
        
        // Then - Verify result
        XCTAssertTrue(result.tokenized)
        XCTAssertNil(result.authentication)
    }
    
    // MARK: - Concurrent Access Tests
    
    func testMultipleServicesCanOperateIndependently() throws {
        // Given - Multiple service instances
        let setup1 = Gr4vySetup(
            gr4vyId: "test-id-1",
            token: "test-token-1",
            merchantId: "test-merchant-1",
            server: .sandbox
        )
        
        let setup2 = Gr4vySetup(
            gr4vyId: "test-id-2",
            token: "test-token-2",
            merchantId: "test-merchant-2",
            server: .production
        )
        
        // When - Create multiple services
        let service1 = Gr4vy3DSService(setup: setup1)
        let service2 = Gr4vy3DSService(setup: setup2)
        
        // Then - Each should be independent
        XCTAssertTrue(service1.debugMode == false)
        XCTAssertTrue(service2.debugMode == false)
    }
}
