//
//  Gr4vyThreeDSModels.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

/// SDK configuration type information for 3D Secure authentication
struct DefaultSdkType: Codable {
    // MARK: - Properties
    
    /// Indicates if the SDK is wrapped or native
    let wrappedInd: String
    
    /// SDK variant identifier
    let sdkVariant: String
    
    // MARK: - CodingKeys
    
    enum CodingKeys: String, CodingKey {
        case wrappedInd
        case sdkVariant
    }
}

/// Device rendering options for 3D Secure UI configuration
struct DeviceRenderOptions: Codable {
    // MARK: - Properties
    
    /// SDK interface type (e.g., "01" for native, "02" for HTML)
    let sdkInterface: String
    
    /// Array of supported UI types for the challenge flow
    let sdkUiType: [String]
    
    // MARK: - CodingKeys
    
    enum CodingKeys: String, CodingKey {
        case sdkInterface
        case sdkUiType
    }
}

/// SDK ephemeral public key for secure communication during 3D Secure authentication
struct SdkEphemeralPubKey: Codable {
    // MARK: - Properties
    
    /// Y coordinate of the elliptic curve public key
    let y: String
    
    /// X coordinate of the elliptic curve public key
    let x: String
    
    /// Key type identifier (typically "EC" for elliptic curve)
    let kty: String
    
    /// Curve type identifier (typically "P-256")
    let crv: String
}
