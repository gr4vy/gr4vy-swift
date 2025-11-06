//
//  Gr4vy.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation
import UIKit

// MARK: - UI Context Helper (iOS 13+)
enum UIContext {
    @MainActor
    static func defaultPresenter() -> UIViewController? {
        let root = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
        return top(from: root)
    }
    private static func top(from vc: UIViewController?) -> UIViewController? {
        if let nav = vc as? UINavigationController { return top(from: nav.visibleViewController) }
        if let tab = vc as? UITabBarController { return top(from: tab.selectedViewController) }
        if let presented = vc?.presentedViewController { return top(from: presented) }
        return vc
    }
}

/// The official Gr4vy SDK for Swift.
///
/// This SDK allows you to interact with the Gr4vy API.
///
public final class Gr4vy {
    // MARK: - Properties
    
    /// Internal configuration setup containing API credentials and server settings
    /// - Note: This property is automatically updated when calling `updateToken(_:)` or `updateMerchantId(_:)`
    private(set) var setup: Gr4vySetup?
    
    /// Debug mode flag. When enabled, logs detailed information about API requests and responses.
    /// - Warning: Disable in production to avoid logging sensitive information
    public var debugMode = false

    /// Payment options service for fetching available payment options.
    /// - SeeAlso: `Gr4vyPaymentOptionsService`
    public let paymentOptions: Gr4vyPaymentOptionsService
    
    /// Card details service for retrieving card metadata.
    /// - SeeAlso: `Gr4vyCardDetailsService`
    public let cardDetails: Gr4vyCardDetailsService
    
    /// Buyer payment methods service.
    /// - SeeAlso: `Gr4vyBuyersPaymentMethodsService`
    public let paymentMethods: Gr4vyBuyersPaymentMethodsService
    
    /// Internal checkout session service for tokenization operations
    private let checkoutSession: Gr4vyCheckoutSessionService
    
    /// Internal 3DS service for tokenization with 3DS
    private let threeDS: Gr4vy3DSService

    // MARK: - Initializer
    
    /// Initialize the Gr4vy SDK with required configuration.
    /// - Parameters:
    ///   - gr4vyId: Your  Gr4vy merchant identifier (cannot be empty)
    ///   - token: JWT authentication token for API requests (can be nil and updated later)
    ///   - merchantId: Optional merchant account ID
    ///   - server: Target server environment (use `.sandbox` for testing, `.production` for live)
    ///   - timeout: Request timeout interval in seconds (default: 30)
    ///   - debugMode: Enable detailed debug logging (default: false)
    ///   - session: URLSession for network requests (default: .shared) - primarily for testing
    /// - Note: Debug mode should be disabled in production builds
    /// - SeeAlso: `updateToken(_:)` for updating authentication tokens
    public init(
        gr4vyId: String,
        token: String?,
        merchantId: String? = nil,
        server: Gr4vyServer,
        timeout: TimeInterval = 30,
        debugMode: Bool = false,
        session: URLSessionProtocol = URLSession.shared
    ) throws {
        guard !gr4vyId.isEmpty else { throw Gr4vyError.invalidGr4vyId }

        let setup = Gr4vySetup(gr4vyId: gr4vyId, token: token, merchantId: merchantId, server: server, timeout: timeout)
        self.setup = setup
        self.debugMode = debugMode
        self.paymentOptions = Gr4vyPaymentOptionsService(setup: setup, debugMode: debugMode, session: session)
        self.checkoutSession = Gr4vyCheckoutSessionService(setup: setup, debugMode: debugMode, session: session)
        self.cardDetails = Gr4vyCardDetailsService(setup: setup, debugMode: debugMode, session: session)
        self.paymentMethods = Gr4vyBuyersPaymentMethodsService(setup: setup, debugMode: debugMode, session: session)
        self.threeDS = Gr4vy3DSService(setup: setup, debugMode: debugMode, session: session)

        if debugMode {
            Gr4vyLogger.enable()
        }
    }

    // MARK: - Public Methods
    
    /// Updates the JWT authentication token for all SDK services.
    /// - Parameter newToken: New JWT authentication token
    /// - SeeAlso: `updateMerchantId(_:)` for updating merchant account settings
    public func updateToken(_ newToken: String) {
        guard var setup = setup else {
            Gr4vyLogger.error("Cannot update token before initialization")
            return
        }
        setup.token = newToken
        self.setup = setup

        // Update all service instances with the new setup
        paymentOptions.updateSetup(setup)
        checkoutSession.updateSetup(setup)
        cardDetails.updateSetup(setup)
        paymentMethods.updateSetup(setup)
        threeDS.updateSetup(setup)
    }

    /// Updates the merchant account ID for all SDK services.
    /// - Parameter newMerchantId: New merchant account ID, or nil to use the default account
    /// - SeeAlso: `updateToken(_:)` for updating authentication credentials
    public func updateMerchantId(_ newMerchantId: String?) {
        guard var setup = setup else {
            Gr4vyLogger.error("Cannot update merchant ID before initialization")
            return
        }
        setup.merchantId = newMerchantId
        self.setup = setup

        // Update all service instances with the new setup
        paymentOptions.updateSetup(setup)
        checkoutSession.updateSetup(setup)
        cardDetails.updateSetup(setup)
        paymentMethods.updateSetup(setup)
        threeDS.updateSetup(setup)
    }
}

// MARK: - Tokenization Methods

extension Gr4vy {
    // MARK: - Public Methods
    
    /// Securely tokenizes payment method data for a checkout session using async/await.
    /// - Parameters:
    ///   - checkoutSessionId: Unique identifier for the checkout session from Gr4vy
    ///   - cardData: Payment method data to be securely tokenized
    /// - Warning: Never log, store, or transmit the raw card data outside of this method
    /// - SeeAlso: `Gr4vyCardData` for supported payment method types
    /// - SeeAlso: `tokenize(checkoutSessionId:cardData:completion:)` for callback-based version
    public func tokenize(
        checkoutSessionId: String,
        cardData: Gr4vyCardData
    ) async throws {
        try await checkoutSession.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
    }
    
    /// Securely tokenizes payment method data for a checkout session using completion callbacks.
    /// - Parameters:
    ///   - checkoutSessionId: Unique identifier for the checkout session from Gr4vy
    ///   - cardData: Payment method data to be securely tokenized
    ///   - completion: Result callback executed on completion with success or failure
    /// - Warning: The completion handler may be called on any queue
    /// - SeeAlso: `tokenize(checkoutSessionId:cardData:)` for async/await version
    public func tokenize(
        checkoutSessionId: String,
        cardData: Gr4vyCardData,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        checkoutSession.tokenize(checkoutSessionId: checkoutSessionId, cardData: cardData, completion: completion)
    }

    /// Securely tokenizes payment method data with 3D Secure authentication support using async/await.
    ///
    /// This method handles both frictionless and challenge authentication flows automatically.
    /// The 3DS challenge UI (if required) will be presented modally on the specified view controller.
    ///
    /// - Parameters:
    ///   - checkoutSessionId: Unique identifier for the checkout session from Gr4vy
    ///   - cardData: Payment method data to be securely tokenized
    ///   - viewController: View controller to present the 3DS challenge screen
    ///   - sdkMaxTimeoutMinutes: Maximum time for 3DS authentication in minutes (default: 5)
    ///   - authenticate: This controls if we should attempt to authenticate the card data (default: false)
    ///   - uiCustomization: Optional UI customization for the 3DS challenge screen
    /// - Returns: `Gr4vyTokenizeResult` containing tokenization status and authentication details
    /// - SeeAlso: `Gr4vyTokenizeResult` for the result structure
    /// - SeeAlso: `Gr4vyThreeDSUiCustomizationMap` for UI customization options
    public func tokenize(
        checkoutSessionId: String,
        cardData: Gr4vyCardData,
        viewController: UIViewController,
        sdkMaxTimeoutMinutes: Int,
        authenticate: Bool = false,
        uiCustomization: Gr4vyThreeDSUiCustomizationMap? = nil
    ) async throws -> Gr4vyTokenizeResult {
        try await threeDS.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes,
            authenticate: authenticate,
            uiCustomization: uiCustomization
        )
    }
    
    /// Securely tokenizes payment method data with 3D Secure authentication support using async/await.
    ///
    /// This convenience method automatically resolves the topmost view controller for presenting
    /// the 3DS challenge screen. Use the explicit view controller variant if you need more control.
    ///
    /// - Parameters:
    ///   - checkoutSessionId: Unique identifier for the checkout session from Gr4vy
    ///   - cardData: Payment method data to be securely tokenized
    ///   - sdkMaxTimeoutMinutes: Maximum time for 3DS authentication in minutes (default: 5)
    ///   - authenticate: This controls if we should attempt to authenticate the card data (default: false)
    ///   - uiCustomization: Optional UI customization for the 3DS challenge screen
    /// - Returns: `Gr4vyTokenizeResult` containing tokenization status and authentication details
    /// - Throws: `Gr4vyError.uiContextError` if unable to resolve a presenting view controller
    /// - SeeAlso: `tokenize(checkoutSessionId:cardData:viewController:sdkMaxTimeoutMinutes:authenticate:uiCustomization:)` for explicit view controller control
    public func tokenize(
        checkoutSessionId: String,
        cardData: Gr4vyCardData,
        sdkMaxTimeoutMinutes: Int = 5,
        authenticate: Bool = false,
        uiCustomization: Gr4vyThreeDSUiCustomizationMap? = nil
    ) async throws -> Gr4vyTokenizeResult {
        guard let presenter = await UIContext.defaultPresenter() else {
            throw Gr4vyError.uiContextError("Unable to resolve presenting view controller")
        }
        return try await tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: presenter,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes,
            authenticate: authenticate,
            uiCustomization: uiCustomization
        )
    }

    /// Securely tokenizes payment method data with 3D Secure authentication support using completion callbacks.
    ///
    /// This method handles both frictionless and challenge authentication flows automatically.
    /// The 3DS challenge UI (if required) will be presented modally on the specified view controller.
    ///
    /// - Parameters:
    ///   - checkoutSessionId: Unique identifier for the checkout session from Gr4vy
    ///   - cardData: Payment method data to be securely tokenized
    ///   - viewController: View controller to present the 3DS challenge screen
    ///   - sdkMaxTimeoutMinutes: Maximum time for 3DS authentication in minutes (default: 5)
    ///   - authenticate: This controls if we should attempt to authenticate the card data (default: false)
    ///   - uiCustomization: Optional UI customization for the 3DS challenge screen
    ///   - completion: Result callback with tokenization result or error
    /// - SeeAlso: `tokenize(checkoutSessionId:cardData:viewController:sdkMaxTimeoutMinutes:authenticate:uiCustomization:)` for async/await version
    public func tokenize(
        checkoutSessionId: String,
        cardData: Gr4vyCardData,
        viewController: UIViewController,
        sdkMaxTimeoutMinutes: Int = 5,
        authenticate: Bool = false,
        uiCustomization: Gr4vyThreeDSUiCustomizationMap? = nil,
        completion: @escaping (Result<Gr4vyTokenizeResult, Error>) -> Void
    ) {
        threeDS.tokenize(
            checkoutSessionId: checkoutSessionId,
            cardData: cardData,
            viewController: viewController,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes,
            authenticate: authenticate,
            uiCustomization: uiCustomization,
            completion: completion
        )
    }

    /// Securely tokenizes payment method data with 3D Secure authentication support using completion callbacks.
    ///
    /// This convenience method automatically resolves the topmost view controller for presenting
    /// the 3DS challenge screen. Use the explicit view controller variant if you need more control.
    ///
    /// - Parameters:
    ///   - checkoutSessionId: Unique identifier for the checkout session from Gr4vy
    ///   - cardData: Payment method data to be securely tokenized
    ///   - sdkMaxTimeoutMinutes: Maximum time for 3DS authentication in minutes (default: 5)
    ///   - authenticate: This controls if we should attempt to authenticate the card data (default: false)
    ///   - uiCustomization: Optional UI customization for the 3DS challenge screen
    ///   - completion: Result callback with tokenization result or error. May return `Gr4vyError.uiContextError` if unable to resolve a presenting view controller
    /// - SeeAlso: `tokenize(checkoutSessionId:cardData:viewController:sdkMaxTimeoutMinutes:authenticate:uiCustomization:completion:)` for explicit view controller control
    public func tokenize(
        checkoutSessionId: String,
        cardData: Gr4vyCardData,
        sdkMaxTimeoutMinutes: Int = 5,
        authenticate: Bool = false,
        uiCustomization: Gr4vyThreeDSUiCustomizationMap? = nil,
        completion: @escaping (Result<Gr4vyTokenizeResult, Error>) -> Void
    ) {
        Task { @MainActor in
            guard let presenter = UIContext.defaultPresenter() else {
                completion(.failure(Gr4vyError.uiContextError("Unable to resolve presenting view controller")))
                return
            }
            tokenize(
                checkoutSessionId: checkoutSessionId,
                cardData: cardData,
                viewController: presenter,
                sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes,
                authenticate: authenticate,
                uiCustomization: uiCustomization,
                completion: completion
            )
        }
    }
}

// MARK: - Server Configuration

/// Gr4vy server environment configuration for API endpoints.
///
/// This enum defines the available server environments for the Gr4vy SDK.
/// Choose the appropriate environment based on your development phase and requirements.
///
/// ## Environment Selection Guide
/// - Use `.sandbox` for development, testing, and integration
/// - Use `.production` only for live transactions
///
/// - SeeAlso: `Gr4vy.init(gr4vyId:token:merchantId:server:timeout:debugMode:)`
public enum Gr4vyServer: String, Codable {
    // MARK: - Cases
    case sandbox
    case production
}

// MARK: - Error Types

/// SDK-specific error types.
public enum Gr4vyError: Error, LocalizedError, Equatable {
    // MARK: - Cases
    
    /// Invalid or empty Gr4vy merchant identifier.
    /// 
    /// This error occurs when the SDK is initialized with an empty `gr4vyId`.
    /// Ensure you provide a valid Gr4vy merchant identifier from your account.
    case invalidGr4vyId
    
    /// Invalid URL construction or malformed endpoint.
    /// 
    /// This error indicates an issue with URL construction, typically due to
    /// invalid characters in the Gr4vy ID or configuration parameters.
    /// 
    /// - Parameter url: The problematic URL string for debugging
    case badURL(String)
    
    /// HTTP API error response from the Gr4vy servers.
    /// 
    /// This error occurs when the API returns an error status code (400-599).
    /// The associated data can help with debugging API issues.
    /// 
    /// - Parameters:
    ///   - statusCode: HTTP status code (e.g., 400, 401, 500)
    ///   - responseData: Raw response body data for detailed error analysis
    ///   - message: Human-readable error message from the API (if available)
    case httpError(statusCode: Int, responseData: Data?, message: String?)
    
    /// Network connectivity or communication error.
    /// 
    /// This error occurs for network-level issues.
    ///
    /// - Parameter error: Underlying URLError with specific details
    case networkError(URLError)
    
    /// JSON response parsing or data decoding error.
    /// 
    /// This error occurs when the SDK cannot parse the API response,
    /// typically due to unexpected response format or missing fields.
    /// 
    /// - Parameter message: Detailed error description for debugging
    case decodingError(String)
    
    /// 3DS Error.
    ///
    /// This error occurs when the SDK cannot start a 3DS session from the API response,
    /// typically due to unexpected response format or missing fields.
    ///
    /// - Parameter message: Detailed error description for debugging
    case threeDSError(String)
    
    /// UI context resolution error.
    ///
    /// This error occurs when the SDK cannot resolve a presenting view controller
    /// for displaying UI components (e.g., 3DS challenge screens).
    ///
    /// - Parameter message: Detailed error description for debugging
    case uiContextError(String)

    // MARK: - Public Methods
    
    /// User-facing error descriptions for each error type.
    public var errorDescription: String? {
        switch self {
        case .invalidGr4vyId:
            return "The provided Gr4vy ID is invalid or empty. Please check your configuration."
        case .badURL(let url):
            return "Invalid URL configuration: \(url)"
        case .httpError(let statusCode, _, let message):
            return "API request failed with status \(statusCode): \(message ?? "Unknown error occurred")"
        case .networkError(let urlError):
            return "Network connectivity error: \(urlError.localizedDescription)"
        case .decodingError(let message):
            return "Failed to process server response: \(message)"
        case .threeDSError(let message):
            return "Failed to start a 3DS session: \(message)"
        case .uiContextError(let message):
            return "UI context error: \(message)"
        }
    }
}
