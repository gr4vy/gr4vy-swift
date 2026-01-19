//
//  Gr4vyBuyersPaymentMethodsResponse.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vyBuyersPaymentMethodsResponse: Codable {
    // MARK: - Properties
    public let items: [Gr4vyBuyersPaymentMethod]
}

public struct Gr4vyBuyersPaymentMethod: Codable {
    // MARK: - Properties
    public let type: String?
    public let approvalURL: URL?
    public let country: String?
    public let currency: String?
    public let details: Gr4vyBuyersPaymentMethodDetails?
    public let expirationDate: String?
    public let fingerprint: String?
    public let label: String?
    public let lastReplacedAt: String?
    public let method: String?
    public let mode: String?
    public let scheme: String?
    public let id: String?
    public let merchantAccountId: String?
    public let additionalSchemes: [String]?
    public let citLastUsedAt: String?
    public let citUsageCount: Int?
    public let hasReplacement: Bool?
    public let lastUsedAt: String?
    public let usageCount: Int?

    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case type
        case approvalURL = "approval_url"
        case country
        case currency
        case details
        case expirationDate = "expiration_date"
        case fingerprint
        case label
        case lastReplacedAt = "last_replaced_at"
        case method
        case mode
        case scheme
        case id
        case merchantAccountId = "merchant_account_id"
        case additionalSchemes = "additional_schemes"
        case citLastUsedAt = "cit_last_used_at"
        case citUsageCount = "cit_usage_count"
        case hasReplacement = "has_replacement"
        case lastUsedAt = "last_used_at"
        case usageCount = "usage_count"
    }

    public struct Gr4vyBuyersPaymentMethodDetails: Codable {
        // MARK: - Properties
        public let bin: String?
        public let cardType: String?
        public let cardIssuerName: String?

        // MARK: - CodingKeys
        private enum CodingKeys: String, CodingKey {
            case bin
            case cardType = "card_type"
            case cardIssuerName = "card_issuer_name"
        }
    }
}
