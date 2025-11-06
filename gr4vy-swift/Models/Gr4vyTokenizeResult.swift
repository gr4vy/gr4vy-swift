//
//  Gr4vyTokenizeResult.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

// MARK: - Tokenize Result

/// Result returned after tokenizing a payment method with optional 3D Secure authentication.
///
/// - SeeAlso: `Gr4vyAuthentication` for authentication details
public struct Gr4vyTokenizeResult {
    /// Indicates whether the payment method was successfully tokenized.
    public let tokenized: Bool
    
    /// Authentication information if 3D Secure authentication was attempted.
    public let authentication: Gr4vyAuthentication?
    
    public init(
        tokenized: Bool,
        authentication: Gr4vyAuthentication? = nil
    ) {
        self.tokenized = tokenized
        self.authentication = authentication
    }
}
