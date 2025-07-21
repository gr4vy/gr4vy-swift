//
//  Gr4vyCardDetails.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vyCardDetails: Codable {
    // MARK: - Properties
    public let currency: String
    public let amount: String?
    public let bin: String?
    public let country: String?
    public let intent: String?
    public let isSubsequentPayment: Bool?
    public let merchantInitiated: Bool?
    public let metadata: String?
    public let paymentMethodId: String?
    public let paymentSource: String?

    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case currency
        case amount
        case bin
        case country
        case intent
        case isSubsequentPayment = "is_subsequent_payment"
        case merchantInitiated = "merchant_initiated"
        case metadata
        case paymentMethodId = "payment_method_id"
        case paymentSource = "payment_source"
    }

    // MARK: - Initializer
    public init(currency: String,
                amount: String? = nil,
                bin: String? = nil,
                country: String? = nil,
                intent: String? = nil,
                isSubsequentPayment: Bool? = nil,
                merchantInitiated: Bool? = nil,
                metadata: String? = nil,
                paymentMethodId: String? = nil,
                paymentSource: String? = nil) {
        self.currency = currency
        self.amount = amount
        self.bin = bin
        self.country = country
        self.intent = intent
        self.isSubsequentPayment = isSubsequentPayment
        self.merchantInitiated = merchantInitiated
        self.metadata = metadata
        self.paymentMethodId = paymentMethodId
        self.paymentSource = paymentSource
    }
}
