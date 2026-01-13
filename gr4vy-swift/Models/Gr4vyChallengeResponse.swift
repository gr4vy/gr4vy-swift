//
//  Gr4vyChallengeResponse.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

/// Challenge information received from the 3D Secure authentication response
struct Gr4vyChallengeResponse: Codable {
    // MARK: - Properties
    
    /// 3DS Server transaction identifier
    let serverTransactionId: String
    
    /// ACS (Access Control Server) transaction identifier
    let acsTransactionId: String
    
    /// ACS reference number for the transaction
    let acsReferenceNumber: String
    
    /// ACS rendering type configuration for challenge UI
    let acsRenderingType: Gr4vyACSRenderingType
    
    /// ACS signed content for authentication
    let acsSignedContent: String
    
    // MARK: - CodingKeys
    
    enum CodingKeys: String, CodingKey {
        case serverTransactionId = "server_transaction_id"
        case acsTransactionId = "acs_transaction_id"
        case acsReferenceNumber = "acs_reference_number"
        case acsRenderingType = "acs_rendering_type"
        case acsSignedContent = "acs_signed_content"
    }
}
