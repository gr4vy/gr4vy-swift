//
//  Gr4vyUtility.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vyUtility {
    // MARK: - Private Methods
    
    private static func urlEncodedPathComponent(_ string: String) -> String? {
        string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)
    }
    
    private static func validateGr4vyId(_ gr4vyId: String) throws -> String {
        guard !gr4vyId.isEmpty else {
            throw Gr4vyError.badURL("Gr4vy ID is empty")
        }

        // Check for invalid characters that could be used in hostname attacks
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        guard gr4vyId.rangeOfCharacter(from: allowedCharacters.inverted) == nil else {
            throw Gr4vyError.badURL("Gr4vy ID contains invalid characters")
        }

        // Check for suspicious patterns
        guard !gr4vyId.contains("..") && !gr4vyId.hasPrefix("-") && !gr4vyId.hasSuffix("-") else {
            throw Gr4vyError.badURL("Gr4vy ID contains suspicious patterns")
        }

        return gr4vyId
    }

    // MARK: - Public Methods
    
    public static func paymentOptionsURL(from setup: Gr4vySetup) throws -> URL {
        let validatedGr4vyId = try validateGr4vyId(setup.gr4vyId)
        let subdomainPrefix = setup.server == .sandbox ? "sandbox." : ""

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.\(subdomainPrefix)\(validatedGr4vyId).gr4vy.app"
        components.path = "/payment-options"

        guard let url = components.url else {
            throw Gr4vyError.badURL("Failed to construct payment options URL")
        }

        return url
    }
    
    public static func checkoutSessionFieldsURL(from setup: Gr4vySetup, checkoutSessionId: String) throws -> URL {
        let validatedGr4vyId = try validateGr4vyId(setup.gr4vyId)

        guard !checkoutSessionId.isEmpty else {
            throw Gr4vyError.badURL("Checkout session ID is empty")
        }

        // URL-encode the checkout session ID to prevent injection attacks
        guard let encodedSessionId = urlEncodedPathComponent(checkoutSessionId) else {
            throw Gr4vyError.badURL("Failed to URL-encode checkout session ID")
        }

        let subdomainPrefix = setup.server == .sandbox ? "sandbox." : ""

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.\(subdomainPrefix)\(validatedGr4vyId).gr4vy.app"
        components.path = "/checkout/sessions/\(encodedSessionId)/fields"

        guard let url = components.url else {
            throw Gr4vyError.badURL("Failed to construct checkout session fields URL")
        }

        return url
    }
    
    public static func cardDetailsURL(from setup: Gr4vySetup) throws -> URL {
        let validatedGr4vyId = try validateGr4vyId(setup.gr4vyId)
        let subdomainPrefix = setup.server == .sandbox ? "sandbox." : ""

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.\(subdomainPrefix)\(validatedGr4vyId).gr4vy.app"
        components.path = "/card-details"

        guard let url = components.url else {
            throw Gr4vyError.badURL("Failed to construct card details URL")
        }

        return url
    }
    
    public static func buyersPaymentMethodsURL(from setup: Gr4vySetup) throws -> URL {
        let validatedGr4vyId = try validateGr4vyId(setup.gr4vyId)
        let subdomainPrefix = setup.server == .sandbox ? "sandbox." : ""

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.\(subdomainPrefix)\(validatedGr4vyId).gr4vy.app"
        components.path = "/buyers/payment-methods"

        guard let url = components.url else {
            throw Gr4vyError.badURL("Failed to construct buyer payment methods URL")
        }

        return url
    }
}
