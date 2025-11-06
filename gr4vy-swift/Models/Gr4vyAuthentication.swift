//
//  Gr4vyAuthentication.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

// MARK: - Authentication Result

/// Information about a 3D Secure authentication attempt.
///
/// - SeeAlso: `Gr4vyTokenizeResult` for the complete tokenization result
public struct Gr4vyAuthentication {
    /// Indicates whether 3D Secure authentication was attempted.
    public let attempted: Bool
    
    /// Type of authentication performed.
    public let type: String?
    
    /// Transaction status code from the authentication process.
    public let transactionStatus: String?
    
    /// Indicates whether the user cancelled the authentication challenge.
    public let hasCancelled: Bool
    
    /// Indicates whether the authentication process timed out.
    public let hasTimedOut: Bool
    
    /// Additional information provided about the cardholder.
    public let cardholderInfo: String?
    
    public init(
        attempted: Bool,
        type: String?,
        transactionStatus: String?,
        hasCancelled: Bool = false,
        hasTimedOut: Bool = false,
        cardholderInfo: String?
    ) {
        self.attempted = attempted
        self.type = type
        self.transactionStatus = transactionStatus
        self.hasCancelled = hasCancelled
        self.hasTimedOut = hasTimedOut
        self.cardholderInfo = cardholderInfo
    }
}

enum Gr4vyAuthenticationType: String {
    case frictionless
    case challenge
    case error
}
