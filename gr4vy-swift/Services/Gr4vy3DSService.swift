//
//  Gr4vy3DSService.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation
import ThreeDS_SDK
import UIKit

/// Service responsible for handling 3D Secure authentication using the Netcetera SDK
/// 
/// This service manages the complete 3DS authentication flow including:
/// - SDK initialization with certificates
/// - Transaction creation and management  
/// - Challenge flow execution
/// - Result processing
final class Gr4vy3DSService {
    // MARK: - Properties
    
    private var httpClient: Gr4vyHTTPClientProtocol
    private var configuration: Gr4vyHTTPConfiguration
    let debugMode: Bool
    private var server: Gr4vyServer
    private var transaction: Transaction?
    private var threeDS2Service: ThreeDS2Service?
    
    // Global static transaction to prevent deallocation during challenge
    private static var globalTransaction: Transaction?
    private var progressView: ProgressDialog?
    private var challengeReceiver: ChallengeReceiver?
    
    private let checkoutSessionService: Gr4vyCheckoutSessionService

    // MARK: - Initializers
    
    /// Initialize service with Gr4vy setup configuration
    /// - Parameters:
    ///   - setup: Gr4vy configuration containing API credentials and settings
    ///   - debugMode: Enable debug logging (default: false)
    ///   - session: URLSession for network requests (default: .shared)
    init(setup: Gr4vySetup, debugMode: Bool = false, session: URLSessionProtocol = URLSession.shared) {
        self.configuration = Gr4vyHTTPConfiguration(setup: setup, debugMode: debugMode, session: session)
        self.httpClient = Gr4vyHTTPClientFactory.create(setup: setup, debugMode: debugMode, session: session)
        self.debugMode = debugMode
        self.server = setup.server
        self.checkoutSessionService = Gr4vyCheckoutSessionService(httpClient: httpClient, configuration: configuration)
    }

    /// Initialize service with pre-configured HTTP client and configuration
    /// - Parameters:
    ///   - httpClient: Pre-configured HTTP client
    ///   - configuration: HTTP configuration settings
    init(httpClient: Gr4vyHTTPClientProtocol, configuration: Gr4vyHTTPConfiguration) {
        self.httpClient = httpClient
        self.configuration = configuration
        self.debugMode = configuration.debugMode
        self.server = configuration.setup.server
        self.checkoutSessionService = Gr4vyCheckoutSessionService(httpClient: httpClient, configuration: configuration)
    }
    
    // MARK: - Public Methods
    
    /// Updates the service configuration with new setup parameters
    /// - Parameter newSetup: New Gr4vySetup configuration
    func updateSetup(_ newSetup: Gr4vySetup) {
        self.configuration = configuration.updated(with: newSetup)
        self.httpClient = Gr4vyHTTPClientFactory.create(
            setup: newSetup,
            debugMode: debugMode,
            session: configuration.session
        )
        self.server = newSetup.server
    }
    
    // MARK: - Private Helper Methods
    
    /// Cleans up all 3DS SDK resources after authentication completes
    ///
    /// This method is called in the following scenarios:
    /// - After completed frictionless authentication
    /// - After challenge flow completes (complete or cancellation) via defer
    /// - When an error occurs during authentication
    ///
    /// Cleanup includes:
    /// - Calling SDK cleanup() to release internal resources
    /// - Clearing all transaction references (instance and static)
    /// - Removing progress view and challenge receiver references
    ///
    /// Note: This method is safe to call multiple times and handles cleanup errors gracefully
    private func cleanupTransaction() {
        Gr4vyLogger.debug("Cleaning up 3DS resources")
        
        // Clean up SDK if exists
        if let service = self.threeDS2Service {
            do {
                try service.cleanup()
            } catch {
                Gr4vyLogger.error("3DS cleanup error: \(error.localizedDescription)")
            }
        }
        
        self.threeDS2Service = nil
        self.transaction = nil
        Gr4vy3DSService.globalTransaction = nil
        self.progressView = nil
        self.challengeReceiver = nil
    }
    
    /// Parses SDK ephemeral public key from JWK string format
    /// - Parameter jwkString: JWK formatted string containing the public key
    /// - Returns: Parsed SdkEphemeralPubKey structure
    /// - Throws: Gr4vyError.threeDSError if parsing fails
    private func parseEphemeralPublicKey(from jwkString: String) throws -> SdkEphemeralPubKey {
        guard let data = jwkString.data(using: .utf8) else {
            throw Gr4vyError.threeDSError("3DS SDK ephemeral public key encoding failed: Invalid UTF-8 data")
        }
        
        do {
            guard let jwk = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let x = jwk["x"] as? String,
                  let y = jwk["y"] as? String,
                  let kty = jwk["kty"] as? String,
                  let crv = jwk["crv"] as? String else {
                throw Gr4vyError.threeDSError("3DS SDK ephemeral public key invalid: Missing required JWK fields (x, y, kty, crv)")
            }
            
            return SdkEphemeralPubKey(y: y, x: x, kty: kty, crv: crv)
        } catch let error as Gr4vyError {
            throw error
        } catch {
            Gr4vyLogger.error("Failed to parse ephemeral public key JWK: \(error.localizedDescription)")
            throw Gr4vyError.threeDSError("3DS SDK ephemeral public key parsing failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Tokenization Methods
    
    /// Tokenizes payment card data with 3D Secure authentication using async/await
    /// - Parameters:
    ///   - checkoutSessionId: Unique checkout session identifier
    ///   - cardData: Payment card data to tokenize and authenticate
    ///   - viewController: View controller to present 3DS challenge UI
    ///   - sdkMaxTimeoutMinutes: Maximum timeout for 3DS challenge in minutes
    ///   - authenticate: If we should authenticate the user
    ///   - uiCustomization: Optional UI customization for 3DS challenge
    /// - Returns: Gr4vyTokenizeResult containing authentication status and transaction details
    /// - Throws: Gr4vyError if authentication fails or other errors occur
    func tokenize(
        checkoutSessionId: String,
        cardData: Gr4vyCardData,
        viewController: UIViewController,
        sdkMaxTimeoutMinutes: Int,
        authenticate: Bool,
        uiCustomization: Gr4vyThreeDSUiCustomizationMap? = nil
    ) async throws -> Gr4vyTokenizeResult {
        try await performTokenization(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes,
            authenticate: authenticate,
            uiCustomization: uiCustomization
        )
    }

    /// Tokenizes payment card data with 3D Secure authentication using completion handler
    /// - Parameters:
    ///   - checkoutSessionId: Unique checkout session identifier
    ///   - cardData: Payment card data to tokenize and authenticate
    ///   - viewController: View controller to present 3DS challenge UI
    ///   - sdkMaxTimeoutMinutes: Maximum timeout for 3DS challenge in minutes
    ///   - authenticate: If we should authenticate the user
    ///   - uiCustomization: Optional UI customization for 3DS challenge
    ///   - completion: Result callback with Gr4vyTokenizeResult on success or Error on failure
    func tokenize(
        checkoutSessionId: String,
        cardData: Gr4vyCardData,
        viewController: UIViewController,
        sdkMaxTimeoutMinutes: Int,
        authenticate: Bool,
        uiCustomization: Gr4vyThreeDSUiCustomizationMap? = nil,
        completion: @escaping (Result<Gr4vyTokenizeResult, Error>) -> Void
    ) {
        Task {
            do {
                let result = try await performTokenization(
                    checkoutSessionId: checkoutSessionId,
                    cardData: cardData, 
                    viewController: viewController,
                    sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes,
                    authenticate: authenticate,
                    uiCustomization: uiCustomization
                )
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private Implementation Methods
    
    /// Initializes 3DS SDK and handles authentication flow
    /// - Parameters:
    ///   - checkoutSessionId: Unique checkout session identifier
    ///   - versioningResponse: Response from versioning API call
    ///   - sdkMaxTimeoutMinutes: Maximum timeout for 3DS challenge in minutes
    ///   - uiCustomization: Optional UI customization for 3DS challenge
    ///   - viewController: View controller to present 3DS challenge UI
    /// - Returns: Gr4vyTokenizeResult containing authentication status and transaction details
    /// - Throws: Gr4vyError if authentication fails or other errors occur
    private func performThreeDSAuthentication(
        checkoutSessionId: String,
        versioningResponse: Gr4vyVersioningResponse,
        sdkMaxTimeoutMinutes: Int,
        uiCustomization: Gr4vyThreeDSUiCustomizationMap?,
        viewController: UIViewController
    ) async throws -> Gr4vyTokenizeResult {
        Gr4vyLogger.debug("Initializing 3DS SDK")
        
        // Clean up any existing SDK instance
        if let existingService = self.threeDS2Service {
            do {
                try existingService.cleanup()
            } catch {
                Gr4vyLogger.error("Cleanup error: \(error.localizedDescription)")
            }
        }
        
        // Configure and create new SDK instance
        let configurationBuilder = ConfigurationBuilder()
        try configurationBuilder.log(to: debugMode ? LogLevel.debug : LogLevel.noLog)
        try configurationBuilder.api(key: versioningResponse.apiKey)
        
        // Only configure test certificates in sandbox environment
        if server == .sandbox {
            try configureTestSDKCertificates(configurationBuilder)
        }
        
        let threeDS2Service: ThreeDS2Service = ThreeDS2ServiceSDK()
        self.threeDS2Service = threeDS2Service
        let configParameters = configurationBuilder.configParameters()
        
        // Initialize SDK
        let uiMap = Gr4vyThreeDSUiCustomizationMapper.map(uiCustomization)
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            threeDS2Service.initialize(configParameters, locale: nil, uiCustomizationMap: uiMap, success: {
                Gr4vyLogger.debug("3DS SDK initialization complete - proceeding with transaction creation")
                continuation.resume()
            }, failure: { error in
                Gr4vyLogger.error("3DS SDK initialization failed - throwing error")
                continuation.resume(throwing: Gr4vyError.threeDSError("ThreeDS2Service initialization failed: \(error.localizedDescription)"))
            })
        }
        
        // Create 3DS transaction
        Gr4vyLogger.debug("Creating 3DS transaction with Directory Server ID: \(versioningResponse.directoryServerId), Message Version: \(versioningResponse.messageVersion)")
        let transaction = try threeDS2Service.createTransaction(
            directoryServerId: versioningResponse.directoryServerId,
            messageVersion: versioningResponse.messageVersion
        )
        
        // Store transaction references to prevent deallocation during challenge
        self.transaction = transaction
        Gr4vy3DSService.globalTransaction = transaction
        
        // Get authentication request parameters
        let params = try transaction.getAuthenticationRequestParameters()
        
        // Parse SDK ephemeral public key from JWK string
        let ephemeralKeyJWK = params.getSDKEphemeralPublicKey()
        let sdkEphemeralPubKey = try self.parseEphemeralPublicKey(from: ephemeralKeyJWK)
        
        // Call 3DS authenticate endpoint
        let response = try await checkoutSessionService.createTransaction(
            checkoutSessionId: checkoutSessionId,
            sdkAppId: params.getSDKAppID(),
            sdkEncryptedData: params.getDeviceData(),
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: params.getSDKReferenceNumber(),
            sdkTransactionId: params.getSDKTransactionId(),
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes
        )
        
        // Process authentication response based on indicator
        switch response.indicator {
        case Gr4vyThreeDSConstants.indicatorFinish:
            cleanupTransaction()
            
            let authentication = Gr4vyAuthentication(
                attempted: true,
                type: Gr4vyAuthenticationType.frictionless.rawValue,
                transactionStatus: response.transactionStatus,
                hasCancelled: false,
                cardholderInfo: response.cardholderInfo
            )
            return Gr4vyTokenizeResult(tokenized: true, authentication: authentication)
            
        case Gr4vyThreeDSConstants.indicatorChallenge:
            guard let challenge = response.challenge else {
                let errorMessage = "3DS Challenge object is missing from response"
                Gr4vyLogger.error(errorMessage)
                // Clean up on error
                cleanupTransaction()
                throw Gr4vyError.decodingError(errorMessage)
            }
            
            Gr4vyLogger.debug("3DS Challenge required - starting challenge flow")
            
            // Use defer to ensure cleanup happens even if an error is thrown
            defer {
                cleanupTransaction()
            }
            
            let challengeResult = try await performChallengeFlow(
                challenge: challenge, 
                transaction: transaction, 
                in: viewController, 
                timeoutMinutes: sdkMaxTimeoutMinutes
            )
            
            Gr4vyLogger.debug("3DS Challenge flow completed - statusCode: \(challengeResult.statusCode ?? "nil"), hasCancelled: \(challengeResult.hasCancelled), hasTimedOut: \(challengeResult.hasTimedOut)")
            
            let authentication = Gr4vyAuthentication(
                attempted: true,
                type: Gr4vyAuthenticationType.challenge.rawValue,
                transactionStatus: challengeResult.statusCode,
                hasCancelled: challengeResult.hasCancelled,
                hasTimedOut: challengeResult.hasTimedOut,
                cardholderInfo: response.cardholderInfo
            )
            return Gr4vyTokenizeResult(tokenized: true, authentication: authentication)
            
        case Gr4vyThreeDSConstants.indicatorError:
            cleanupTransaction()
            let authentication = Gr4vyAuthentication(
                attempted: true,
                type: Gr4vyAuthenticationType.error.rawValue,
                transactionStatus: response.transactionStatus,
                hasCancelled: false,
                cardholderInfo: response.cardholderInfo
            )
            return Gr4vyTokenizeResult(tokenized: true, authentication: authentication)
            
        default:
            // Clean up on error
            cleanupTransaction()
            Gr4vyLogger.error("3DS Received unknown indicator: \(response.indicator)")
            throw Gr4vyError.threeDSError("Received unknown indicator: \(response.indicator)")
        }
    }

    /// Main tokenization flow orchestrating all steps
    /// - Parameters:
    ///   - checkoutSessionId: Unique checkout session identifier
    ///   - cardData: Payment card data to tokenize and authenticate
    ///   - viewController: View controller to present 3DS challenge UI
    ///   - sdkMaxTimeoutMinutes: Maximum timeout for 3DS challenge in minutes
    ///   - authenticate: If we should authenticate the user
    ///   - uiCustomization: Optional UI customization for 3DS challenge
    /// - Returns: Gr4vyTokenizeResult containing authentication status and transaction details
    /// - Throws: Gr4vyError if any step fails
    private func performTokenization(
        checkoutSessionId: String,
        cardData: Gr4vyCardData,
        viewController: UIViewController,
        sdkMaxTimeoutMinutes: Int,
        authenticate: Bool,
        uiCustomization: Gr4vyThreeDSUiCustomizationMap?
    ) async throws -> Gr4vyTokenizeResult {
        // Step 1: Tokenize card data
        try await checkoutSessionService.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
        
        if authenticate == false {
            return Gr4vyTokenizeResult(tokenized: true, authentication: nil)
        }
        
        // Step 2: Get 3DS versioning information
        var versioningResponse: Gr4vyVersioningResponse?
        
        do {
            versioningResponse = try await checkoutSessionService.callVersioning(checkoutSessionId: checkoutSessionId)
        } catch {
            Gr4vyLogger.error("Versioning failed: \(error.localizedDescription)")
            versioningResponse = nil
        }

        guard let versioningResponse = versioningResponse else {
            return Gr4vyTokenizeResult(
                    tokenized: true,
                    authentication: Gr4vyAuthentication(
                        attempted: false,
                        type: nil,
                        transactionStatus: nil,
                        hasCancelled: false,
                        cardholderInfo: nil
                    )
                )
        }
        
        // Step 3: Initialize 3DS SDK and handle authentication flow
        return try await performThreeDSAuthentication(
            checkoutSessionId: checkoutSessionId, 
            versioningResponse: versioningResponse,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes,
            uiCustomization: uiCustomization,
            viewController: viewController
        )
    }

    /// Executes the 3DS challenge flow with the user
    /// - Parameters:
    ///   - challenge: Challenge information from the authentication response
    ///   - transaction: Active 3DS transaction
    ///   - viewController: View controller to present challenge UI
    ///   - timeoutMinutes: Challenge timeout in minutes
    /// - Returns: Tuple containing status code and transaction ID
    /// - Throws: Gr4vyError if challenge fails
    private func performChallengeFlow(
        challenge: Gr4vyChallengeResponse, 
        transaction: Transaction, 
        in viewController: UIViewController, 
        timeoutMinutes: Int
    ) async throws -> (statusCode: String?, transactionId: String?, hasCancelled: Bool, hasTimedOut: Bool) {
        let params = Self.prepareChallengeParameters(challenge, transaction: transaction)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(statusCode: String?, transactionId: String?, hasCancelled: Bool, hasTimedOut: Bool), Error>) in
            let receiver = ChallengeReceiver(onComplete: { result in
                switch result {
                case .success(let challengeResult):
                    continuation.resume(returning: (statusCode: challengeResult.statusCode, transactionId: challengeResult.transactionId, hasCancelled: challengeResult.hasCancelled, hasTimedOut: challengeResult.hasTimedOut))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            })
            
            // Store receiver to prevent deallocation during challenge
            self.challengeReceiver = receiver

            // Execute challenge on main thread (required for UI operations)
            DispatchQueue.main.async {
                do {
                    // Try to show progress dialog (optional - failure is non-fatal)
                    do {
                        self.progressView = try transaction.getProgressView()
                        self.progressView?.start()
                    } catch {
                        Gr4vyLogger.debug("Progress dialog unavailable: \(error.localizedDescription)")
                    }

                    try transaction.doChallenge(
                        challengeParameters: params,
                        challengeStatusReceiver: receiver,
                        timeOut: timeoutMinutes,
                        inViewController: viewController
                    )
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Static Helper Methods
    
    /// Prepares challenge parameters from challenge info and transaction
    /// - Parameters:
    ///   - challenge: Challenge information from authentication response
    ///   - transaction: Active 3DS transaction
    /// - Returns: Configured ChallengeParameters for the challenge flow
    static func prepareChallengeParameters(_ challenge: Gr4vyChallengeResponse, transaction: Transaction) -> ChallengeParameters {
        let challengeParameters = ChallengeParameters(
            threeDSServerTransactionID: challenge.serverTransactionId,
            acsTransactionID: challenge.acsTransactionId,
            acsRefNumber: challenge.acsReferenceNumber,
            acsSignedContent: challenge.acsSignedContent
        )
        
        return challengeParameters
    }
}

// MARK: - Challenge Types

/// Result of a 3DS challenge flow
private struct ChallengeResult {
    let statusCode: String?
    let transactionId: String?
    let hasCancelled: Bool
    let hasTimedOut: Bool
    
    /// Creates a completed challenge result
    static func completed(status: String?, transactionId: String?) -> ChallengeResult {
        ChallengeResult(statusCode: status, transactionId: transactionId, hasCancelled: false, hasTimedOut: false)
    }
    
    /// Creates a cancelled challenge result
    static func cancelled() -> ChallengeResult {
        ChallengeResult(statusCode: nil, transactionId: nil, hasCancelled: true, hasTimedOut: false)
    }
    
    /// Creates a timed out challenge result
    static func timedOut() -> ChallengeResult {
        ChallengeResult(statusCode: nil, transactionId: nil, hasCancelled: false, hasTimedOut: true)
    }
}

// MARK: - Challenge Status Receiver

/// Internal challenge status receiver to bridge Netcetera callbacks to async/await
private final class ChallengeReceiver: NSObject, ChallengeStatusReceiver {
    private let onComplete: (Result<ChallengeResult, Error>) -> Void
    
    init(onComplete: @escaping (Result<ChallengeResult, Error>) -> Void) {
        self.onComplete = onComplete
        super.init()
    }
    
    func completed(completionEvent: CompletionEvent) {
        let status = completionEvent.getTransactionStatus()
        let transactionID = completionEvent.getSDKTransactionID()
        
        Gr4vyLogger.debug("3DS Challenge complete - status: \(status), transactionID: \(transactionID)")
        onComplete(.success(.completed(status: status, transactionId: transactionID)))
    }
    
    func cancelled() {
        Gr4vyLogger.debug("3DS Challenge was cancelled by user")
        onComplete(.success(.cancelled()))
    }
    
    func timedout() {
        Gr4vyLogger.error("3DS Challenge timed out")
        onComplete(.success(.timedOut()))
    }
    
    func protocolError(protocolErrorEvent: ProtocolErrorEvent) {
        let msg = protocolErrorEvent.getErrorMessage()
        let desc = msg.getErrorDescription() ?? "Unknown Description"
        let code = msg.getErrorCode() ?? "Unknown Code"
        let detail = msg.getErrorDetail() ?? "Unknown Detail"
        Gr4vyLogger.error("3DS Protocol error [\(code)]: \(desc) \(detail)")
        onComplete(.failure(Gr4vyError.threeDSError("Protocol error [\(code)]: \(desc) \(detail)")))
    }
    
    func runtimeError(runtimeErrorEvent: RuntimeErrorEvent) {
        let message = runtimeErrorEvent.getErrorMessage() ?? "Unknown Message"
        let code = runtimeErrorEvent.getErrorCode() ?? "Unknown Code"
        Gr4vyLogger.error("3DS Runtime error [\(code)]: \(message)")
        onComplete(.failure(Gr4vyError.threeDSError("Runtime error [\(code)]: \(message)")))
    }
}
