//
//  Gr4vyCardDetailsRequest.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vyCardDetailsRequest: Encodable {
    // MARK: - Properties
    public let timeout: TimeInterval?
    public let cardDetails: Gr4vyCardDetails

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case cardDetails = "card_details"
    }
    
    // MARK: - Initializer
    public init(cardDetails: Gr4vyCardDetails, timeout: TimeInterval? = nil) {
        self.cardDetails = cardDetails
        self.timeout = timeout
    }
}
