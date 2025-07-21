//
//  Gr4vy.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

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

    // MARK: - Initializer
    
    /// Initialize the Gr4vy SDK with required configuration.
    /// - Parameters:
    ///   - gr4vyId: Your  Gr4vy merchant identifier (cannot be empty)
    ///   - token: JWT authentication token for API requests (can be nil and updated later)
    ///   - merchantId: Optional merchant account ID
    ///   - server: Target server environment (use `.sandbox` for testing, `.production` for live)
    ///   - timeout: Request timeout interval in seconds (default: 30)
    ///   - debugMode: Enable detailed debug logging (default: false)
    /// - Note: Debug mode should be disabled in production builds
    /// - SeeAlso: `updateToken(_:)` for updating authentication tokens
    public init(
        gr4vyId: String,
        token: String?,
        merchantId: String? = nil,
        server: Gr4vyServer,
        timeout: TimeInterval = 30,
        debugMode: Bool = false
    ) throws {
        guard !gr4vyId.isEmpty else { throw Gr4vyError.invalidGr4vyId }

        let setup = Gr4vySetup(gr4vyId: gr4vyId, token: token, merchantId: merchantId, server: server, timeout: timeout)
        self.setup = setup
        self.debugMode = debugMode
        self.paymentOptions = Gr4vyPaymentOptionsService(setup: setup, debugMode: debugMode)
        self.checkoutSession = Gr4vyCheckoutSessionService(setup: setup, debugMode: debugMode)
        self.cardDetails = Gr4vyCardDetailsService(setup: setup, debugMode: debugMode)
        self.paymentMethods = Gr4vyBuyersPaymentMethodsService(setup: setup, debugMode: debugMode)

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
        }
    }
}
