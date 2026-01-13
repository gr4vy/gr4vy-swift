//
//  Gr4vyTestCertificateConfiguration.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation
import ThreeDS_SDK

// MARK: - Constants

private enum CertificateConstants {
    static let rootCertificate = "acq-root-certeq-prev-environment-new.crt"
    static let encryptionCertificateVisa = "acq-encryption-visa-sign-certeq-rsa-ncaDS.crt"
    static let encryptionCertificateAmex = "acq-encryption-amex-sign-certeq-rsa-ncaDS.crt"
    static let encryptionCertificateDiners = "acq-encryption-diners-sign-certeq-rsa-ncaDS.crt"
    static let encryptionCertificateJCB = "acq-encryption-jcb-sign-certeq-rsa-ncaDS.crt"
    static let encryptionCertificateMastercard = "acq-encryption-mc-sign-certeq-rsa-ncaDS.crt"
    static let pemBeginMarker = "-----BEGIN CERTIFICATE-----"
    static let pemEndMarker = "-----END CERTIFICATE-----"
    static let appURLScheme = "gr4vy://3ds"
}

// MARK: - Certificate Configuration Helpers

/// Extracts Base64 content from PEM certificate (removes headers and footers)
/// - Parameter pemContent: PEM certificate content as string
/// - Returns: Base64 encoded certificate content without PEM headers/footers
private func extractBase64FromPEM(_ pemContent: String) -> String {
    let lines = pemContent.components(separatedBy: .newlines)
    let base64Lines = lines.filter { line in
        !line.contains(CertificateConstants.pemBeginMarker) &&
        !line.contains(CertificateConstants.pemEndMarker) &&
        !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    return base64Lines.joined()
}

/// Extracts Base64 contents for each PEM certificate block (handles certificate chains)
/// - Parameter pemContent: PEM certificate content that may contain multiple certificates
/// - Returns: Array of Base64 encoded certificate blocks
private func extractPEMBlocks(_ pemContent: String) -> [String] {
    let begin = CertificateConstants.pemBeginMarker
    let end = CertificateConstants.pemEndMarker
    var blocks: [String] = []
    var searchRange = pemContent.startIndex..<pemContent.endIndex
    
    while let beginRange = pemContent.range(of: begin, options: [], range: searchRange),
          let endRange = pemContent.range(of: end, options: [], range: beginRange.upperBound..<pemContent.endIndex) {
        let certBodyRange = beginRange.upperBound..<endRange.lowerBound
        let certBody = String(pemContent[certBodyRange])
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined()
        
        if !certBody.isEmpty { 
            blocks.append(certBody) 
        }
        searchRange = endRange.upperBound..<pemContent.endIndex
    }
    return blocks
}

/// Loads certificate file from the SDK bundle and returns the file path
/// - Parameter fileName: Name of the certificate file to load
/// - Returns: Full file path to the certificate
/// - Throws: Gr4vyError.decodingError if certificate is not found or cannot be read
private func loadCertificateFromSDKBundle(named fileName: String) throws -> String {
    Gr4vyLogger.debug("Looking for certificate: \(fileName)")
    
    // Get SDK bundle - works for both SPM and Xcode framework builds
    let sdkBundle: Bundle
    #if SWIFT_PACKAGE
    sdkBundle = Bundle.module
    #else
    sdkBundle = Bundle(for: Gr4vy.self)
    #endif
    
    guard let url = sdkBundle.url(forResource: fileName, withExtension: nil) else {
        let errorMessage = "Certificate not found in package resources: \(fileName)"
        Gr4vyLogger.error(errorMessage)
        throw Gr4vyError.decodingError(errorMessage)
    }
    
    let certPath = url.path
    Gr4vyLogger.debug("Found certificate at path: \(certPath)")
    
    // Validate certificate file existence and format
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: certPath) else {
        let errorMessage = "Certificate file does not exist at path: \(certPath)"
        Gr4vyLogger.error(errorMessage)
        throw Gr4vyError.decodingError(errorMessage)
    }
    
    do {
        let certContent = try String(contentsOfFile: certPath, encoding: .utf8)
        let fileSize = certContent.count
        
        Gr4vyLogger.debug("Certificate loaded - Size: \(fileSize) characters")
        
        // Validate PEM format
        let isValidPEM = certContent.contains(CertificateConstants.pemBeginMarker) && 
                         certContent.contains(CertificateConstants.pemEndMarker)
        
        if isValidPEM {
            Gr4vyLogger.debug("Certificate appears to be in valid PEM format")
        } else {
            Gr4vyLogger.error("Certificate does not appear to be in standard PEM format")
        }
    } catch {
        let errorMessage = "Error reading certificate file: \(error.localizedDescription)"
        Gr4vyLogger.error(errorMessage)
        throw Gr4vyError.decodingError(errorMessage)
    }
    
    return certPath
}

// MARK: - Test Certificate Configuration

/// Configures the 3DS SDK with certificates from SDK bundle resources
/// - Parameter configBuilder: ConfigurationBuilder to configure with certificates
/// - Throws: Gr4vyError.decodingError if certificates cannot be loaded or configured
/// - Note: This function is for testing purposes only and should be removed before production
func configureTestSDKCertificates(_ configBuilder: ConfigurationBuilder) throws {
    Gr4vyLogger.debug("Configuring 3DS SDK with certificates from bundle")
    
    // Load root certificate (shared across all schemes)
    let rootCertPath = try loadCertificateFromSDKBundle(named: CertificateConstants.rootCertificate)
    let rootCertContent = try String(contentsOfFile: rootCertPath, encoding: .utf8)
    
    // Process root certificate into proper format
    let cleanRootCert = rootCertContent.trimmingCharacters(in: .whitespacesAndNewlines)
    let rootBlocks = extractPEMBlocks(cleanRootCert)
    let base64RootCert = extractBase64FromPEM(cleanRootCert)
    let rootsArray = !rootBlocks.isEmpty ? rootBlocks : [base64RootCert]
    
    Gr4vyLogger.debug("Root certificate processed - blocks: \(rootBlocks.count)")
    
    // Helper function to configure a scheme with its encryption certificate
    func configureScheme(_ scheme: Scheme, encryptionCertFile: String, schemeName: String) throws {
        let encryptionCertPath = try loadCertificateFromSDKBundle(named: encryptionCertFile)
        let encryptionCertContent = try String(contentsOfFile: encryptionCertPath, encoding: .utf8)
        
        let cleanEncryptionCert = encryptionCertContent.trimmingCharacters(in: .whitespacesAndNewlines)
        let base64EncryptionCert = extractBase64FromPEM(cleanEncryptionCert)
        let encryptionBlocks = extractPEMBlocks(cleanEncryptionCert)
        let encryptionLeaf = encryptionBlocks.first ?? base64EncryptionCert
        
        // Per Netcetera documentation: use Base64 (ASN.1 DER/PEM) strings
        scheme.encryptionKeyValue = encryptionLeaf
        scheme.rootCertificateValues = rootsArray
        
        try configBuilder.add(scheme)
        Gr4vyLogger.debug("Successfully configured \(schemeName) scheme")
    }
    
    // Configure all card schemes with their respective certificates
    try configureScheme(Scheme.visa(), encryptionCertFile: CertificateConstants.encryptionCertificateVisa, schemeName: "Visa")
    try configureScheme(Scheme.mastercard(), encryptionCertFile: CertificateConstants.encryptionCertificateMastercard, schemeName: "Mastercard")
    try configureScheme(Scheme.amex(), encryptionCertFile: CertificateConstants.encryptionCertificateAmex, schemeName: "Amex")
    try configureScheme(Scheme.diners(), encryptionCertFile: CertificateConstants.encryptionCertificateDiners, schemeName: "Diners")
    try configureScheme(Scheme.jcb(), encryptionCertFile: CertificateConstants.encryptionCertificateJCB, schemeName: "JCB")
    
    Gr4vyLogger.debug("Successfully configured all card schemes with \(rootsArray.count) root certificates")
}
