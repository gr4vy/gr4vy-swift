//
//  Gr4vyBuyersPaymentMethods.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public enum Gr4vySortBy: String, CaseIterable, Codable {
    case lastUsedAt = "last_used_at"
}

public enum Gr4vyOrderBy: String, CaseIterable, Codable {
    case asc = "asc"
    case desc = "desc"
}

public struct Gr4vyBuyersPaymentMethods: Codable {
    // MARK: - Properties
    public let buyerId: String?
    public let buyerExternalIdentifier: String?
    public let sortBy: Gr4vySortBy?
    public let orderBy: Gr4vyOrderBy?
    public let country: String?
    public let currency: String?

    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case buyerId = "buyer_id"
        case buyerExternalIdentifier = "buyer_external_identifier"
        case sortBy = "sort_by"
        case orderBy = "order_by"
        case country
        case currency
    }

    // MARK: - Initializer
    public init(buyerId: String?,
                buyerExternalIdentifier: String? = nil,
                sortBy: Gr4vySortBy? = nil,
                orderBy: Gr4vyOrderBy? = .desc,
                country: String? = nil,
                currency: String? = nil) {
        self.buyerId = buyerId
        self.buyerExternalIdentifier = buyerExternalIdentifier
        self.sortBy = sortBy
        self.orderBy = orderBy
        self.country = country
        self.currency = currency
    }
}
