//
//  Gr4vyCheckoutSessionService.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

// API Documentation: https://docs.gr4vy.com/reference/checkout-sessions/update-checkout-session-fields

public final class Gr4vyCheckoutSessionService {
    // MARK: - Properties
    private var httpClient: Gr4vyHTTPClientProtocol
    private var configuration: Gr4vyHTTPConfiguration
    public let debugMode: Bool
    
    // MARK: - Initializer
    public init(setup: Gr4vySetup, debugMode: Bool = false, session: URLSessionProtocol = URLSession.shared) {
        self.configuration = Gr4vyHTTPConfiguration(setup: setup, debugMode: debugMode, session: session)
        self.httpClient = Gr4vyHTTPClientFactory.create(setup: setup, debugMode: debugMode, session: session)
        self.debugMode = debugMode
    }
    
    public init(httpClient: Gr4vyHTTPClientProtocol, configuration: Gr4vyHTTPConfiguration) {
        self.httpClient = httpClient
        self.configuration = configuration
        self.debugMode = configuration.debugMode
    }
    
    // MARK: - Public Methods
    public func updateSetup(_ newSetup: Gr4vySetup) {
        self.configuration = configuration.updated(with: newSetup)
        self.httpClient = Gr4vyHTTPClientFactory.create(
            setup: newSetup,
            debugMode: debugMode,
            session: configuration.session
        )
    }
}

// MARK: - Tokenize Card Data Methods
extension Gr4vyCheckoutSessionService {
    // MARK: - Public Methods
    public func tokenize(checkoutSessionId: String, cardData: Gr4vyCardData) async throws {
        try await performTokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
    }

    public func tokenize(
        checkoutSessionId: String,
        cardData: Gr4vyCardData,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await performTokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private Methods
    private func performTokenize(checkoutSessionId: String, cardData: Gr4vyCardData) async throws {
        let url = try Gr4vyUtility.checkoutSessionFieldsURL(from: configuration.setup, checkoutSessionId: checkoutSessionId)

        let requestBody = Gr4vyCheckoutSessionRequest(paymentMethod: cardData.paymentMethod)

        _ = try await httpClient.perform(
            to: url,
            method: "PUT",
            body: requestBody,
            merchantId: nil,
            timeout: requestBody.timeout
        )
    }
}

// MARK: - Versioning Methods
extension Gr4vyCheckoutSessionService {
    func callVersioning(checkoutSessionId: String) async throws -> Gr4vyVersioningResponse {
        try await performVersioning(checkoutSessionId: checkoutSessionId)
    }
    
    func callVersioning(checkoutSessionId: String, completion: @escaping (Result<Gr4vyVersioningResponse, Error>) -> Void) {
        Task {
            do {
                let result = try await performVersioning(checkoutSessionId: checkoutSessionId)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func performVersioning(checkoutSessionId: String) async throws -> Gr4vyVersioningResponse {
        let url = try Gr4vyUtility.versioningURL(from: configuration.setup, checkoutSessionId: checkoutSessionId)

        let data = try await httpClient.perform(
            to: url,
            method: "GET",
            body: Gr4vyEmptyRequest?.none,
            merchantId: nil,
            timeout: nil
        )
        
        return try JSONDecoder().decode(Gr4vyVersioningResponse.self, from: data)
    }
}

// MARK: - Create Transaction Methods
extension Gr4vyCheckoutSessionService {
    /// Configuration constants for 3D Secure
    private enum ThreeDSConfig {
        /// Default SDK interface type: "03" = Native UI with both OOB and HTML
        static let defaultSdkInterface = "03"
    }
    
    func createTransaction(
        checkoutSessionId: String,
        sdkAppId: String,
        sdkEncryptedData: String,
        sdkEphemeralPubKey: SdkEphemeralPubKey,
        sdkReferenceNumber: String,
        sdkTransactionId: String,
        sdkMaxTimeoutMinutes: Int
    ) async throws -> Gr4vyThreeDSecureResponse {
        try await performCreateTransaction(
            checkoutSessionId: checkoutSessionId,
            sdkAppId: sdkAppId,
            sdkEncryptedData: sdkEncryptedData,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: sdkReferenceNumber,
            sdkTransactionId: sdkTransactionId,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
        )
    }
    
    func createTransaction(
        checkoutSessionId: String,
        sdkAppId: String,
        sdkEncryptedData: String,
        sdkEphemeralPubKey: SdkEphemeralPubKey,
        sdkReferenceNumber: String,
        sdkTransactionId: String,
        sdkMaxTimeoutMinutes: Int,
        completion: @escaping (Result<Gr4vyThreeDSecureResponse, Error>) -> Void) {
            Task {
                do {
                    let result = try await performCreateTransaction(
                        checkoutSessionId: checkoutSessionId,
                        sdkAppId: sdkAppId,
                        sdkEncryptedData: sdkEncryptedData,
                        sdkEphemeralPubKey: sdkEphemeralPubKey,
                        sdkReferenceNumber: sdkReferenceNumber,
                        sdkTransactionId: sdkTransactionId,
                        sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
                    )
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    
    private func performCreateTransaction(
        checkoutSessionId: String,
        sdkAppId: String,
        sdkEncryptedData: String,
        sdkEphemeralPubKey: SdkEphemeralPubKey,
        sdkReferenceNumber: String,
        sdkTransactionId: String,
        sdkMaxTimeoutMinutes: Int
    ) async throws -> Gr4vyThreeDSecureResponse {
        let url = try Gr4vyUtility.createTransactionURL(from: configuration.setup, checkoutSessionId: checkoutSessionId)
        
        let sdkInterface = ThreeDSConfig.defaultSdkInterface
        let sdkUiTypes = getSdkUiTypes(for: sdkInterface)

        let requestBody = Gr4vyThreeDSecureAuthenticateRequest(
            defaultSdkType: DefaultSdkType(wrappedInd: "Y", sdkVariant: "01"),
            deviceChannel: "01", // App-based channel
            deviceRenderOptions: DeviceRenderOptions(
                sdkInterface: sdkInterface,
                sdkUiType: sdkUiTypes
            ),
            sdkAppId: sdkAppId,
            sdkEncryptedData: sdkEncryptedData,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: sdkReferenceNumber,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes,
            sdkTransactionId: sdkTransactionId
        )
        
        let data = try await httpClient.perform(
            to: url,
            method: "POST",
            body: requestBody,
            merchantId: nil,
            timeout: requestBody.timeout
        )
        
        let authenticateResponse = try JSONDecoder().decode(Gr4vyThreeDSecureResponse.self, from: data)
        
        if debugMode {
            Gr4vyLogger.debug("3DS transaction response - Indicator: \(authenticateResponse.indicator)")
            if authenticateResponse.isChallenge, let challenge = authenticateResponse.challenge {
                Gr4vyLogger.debug("Challenge required - Server Transaction ID: \(challenge.serverTransactionId ?? "nil")")
                Gr4vyLogger.debug("ACS Transaction ID: \(challenge.acsTransactionId ?? "nil")")
            } else if authenticateResponse.isFrictionless {
                Gr4vyLogger.debug("3DS authentication completed - FINISH indicator")
            } else if authenticateResponse.isError {
                Gr4vyLogger.debug("3DS authentication error occurred")
            }
        }
        return authenticateResponse
    }
    
    private func getSdkUiTypes(for sdkInterface: String) -> [String] {
        // SDK UI type logic based on interface type as per SDK provider's sample
        switch sdkInterface {
        case "01":
            return ["01", "02", "03", "04"]
        case "02":
            return ["01", "02", "03", "04", "05"]
        default:
            return ["01", "02", "03", "04", "05"]
        }
    }
}
