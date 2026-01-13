//
//  Gr4vyThreeDSecureResponse.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

struct Gr4vyThreeDSecureResponse: Codable {
    let indicator: String
    let challenge: Gr4vyChallengeResponse?
    let transactionStatus: String?
    let cardholderInfo: String?
    
    var isFrictionless: Bool {
        indicator == Gr4vyThreeDSConstants.indicatorFinish
    }
    
    var isChallenge: Bool {
        indicator == Gr4vyThreeDSConstants.indicatorChallenge
    }
    
    var isError: Bool {
        indicator == Gr4vyThreeDSConstants.indicatorError
    }

    enum CodingKeys: String, CodingKey {
        case indicator
        case challenge
        case transactionStatus = "transaction_status"
        case cardholderInfo = "cardholder_info"
    }
}
