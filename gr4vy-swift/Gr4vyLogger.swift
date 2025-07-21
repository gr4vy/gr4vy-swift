//
//  Gr4vyLogger.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vyLogger {
    // MARK: - Properties
    private static var isEnabled = false

    // MARK: - Configuration
    
    public static func enable() {
        isEnabled = true
    }
    
    public static func disable() {
        isEnabled = false
    }

    // MARK: - Logging Methods
    
    public static func log(_ message: String) {
        guard isEnabled else { return }
        print("🔍 [Gr4vy] \(maskSensitiveInfo(message))")
    }
    
    public static func error(_ message: String) {
        guard isEnabled else { return }
        print("❌ [Gr4vy] \(maskSensitiveInfo(message))")
    }
    
    public static func network(_ message: String) {
        guard isEnabled else { return }
        print("🌐 [Gr4vy] \(maskSensitiveInfo(message))")
    }
    
    public static func debug(_ object: Any) {
        guard isEnabled else { return }
        print("🔍 [Gr4vy] Debug:")

        // Handle Data objects specially to avoid logging sensitive request bodies
        if let data = object as? Data {
            if let jsonString = String(data: data, encoding: .utf8) {
                let maskedJson = maskSensitiveInfo(jsonString)
                print(maskedJson)
            } else {
                print("Binary data (\(data.count) bytes)")
            }
        } else {
            let objectString = String(describing: object)
            print(maskSensitiveInfo(objectString))
        }
    }

    // MARK: - Private Methods
    private static func maskSensitiveInfo(_ message: String) -> String {
        var maskedMessage = message

        // Mask Bearer tokens
        let bearerPattern = "Bearer\\s+([A-Za-z0-9._-]+)"
        maskedMessage = maskedMessage.replacingOccurrences(
            of: bearerPattern,
            with: "Bearer ***MASKED***",
            options: .regularExpression
        )

        // Mask tokens in JSON
        let tokenPattern = "\"token\"\\s*:\\s*\"([^\"]+)\""
        maskedMessage = maskedMessage.replacingOccurrences(
            of: tokenPattern,
            with: "\"token\": \"***MASKED***\"",
            options: .regularExpression
        )

        // Mask card numbers (basic pattern)
        let cardNumberPattern = "\"number\"\\s*:\\s*\"([0-9]{13,19})\""
        maskedMessage = maskedMessage.replacingOccurrences(
            of: cardNumberPattern,
            with: "\"number\": \"****-****-****-****\"",
            options: .regularExpression
        )

        // Mask security codes
        let securityCodePattern = "\"security_code\"\\s*:\\s*\"([0-9]{3,4})\""
        maskedMessage = maskedMessage.replacingOccurrences(
            of: securityCodePattern,
            with: "\"security_code\": \"***\"",
            options: .regularExpression
        )

        return maskedMessage
    }
}
