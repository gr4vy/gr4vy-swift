//
//  Gr4vyCardData.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vyCardData: Codable {

    // MARK: - Properties
    public let paymentMethod: Gr4vyPaymentMethod

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case paymentMethod = "payment_method"
    }

    // MARK: - Initializer
    public init(paymentMethod: Gr4vyPaymentMethod) {
        self.paymentMethod = paymentMethod
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.paymentMethod = try container.decode(Gr4vyPaymentMethod.self, forKey: .paymentMethod)
    }
}

public struct CardPaymentMethod: Codable {
    // MARK: - Properties
    
    public let number: String
    public let expirationDate: String
    public let securityCode: String?

    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case number = "number"
        case expirationDate = "expiration_date"
        case securityCode = "security_code"
    }

    // MARK: - Initializer
    public init(number: String, expirationDate: String, securityCode: String? = nil) {
        self.number = number
        self.expirationDate = expirationDate
        self.securityCode = securityCode
    }
}

public struct ClickToPayPaymentMethod: Codable {
    // MARK: - Properties
    public let merchantTransactionId: String
    public let srcCorrelationId: String

    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case merchantTransactionId = "merchant_transaction_id"
        case srcCorrelationId = "src_correlation_id"
    }

    // MARK: - Initializer
    public init(merchantTransactionId: String, srcCorrelationId: String) {
        self.merchantTransactionId = merchantTransactionId
        self.srcCorrelationId = srcCorrelationId
    }
}

public struct IdPaymentMethod: Codable {
    // MARK: - Properties
    public let id: String
    public let securityCode: String?

    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case securityCode = "security_code"
    }

    // MARK: - Initializer
    public init(id: String, securityCode: String? = nil) {
        self.id = id
        self.securityCode = securityCode
    }
}

public enum Gr4vyPaymentMethod: Codable {
    // MARK: - Properties
    case card(CardPaymentMethod)
    case clickToPay(ClickToPayPaymentMethod)
    case id(IdPaymentMethod)

    // MARK: - CodingKeys
    // discriminator key present in every variant
    private enum DiscriminatorKeys: String, CodingKey { case method }

    // MARK: - Initializer
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DiscriminatorKeys.self)
        let methodString = try container.decode(String.self, forKey: .method)

        switch methodString {
        case "card":
            self = .card(try CardPaymentMethod(from: decoder))

        case "click_to_pay":
            self = .clickToPay(try ClickToPayPaymentMethod(from: decoder))

        case "id":
            self = .id(try IdPaymentMethod(from: decoder))

        default:
            throw DecodingError.dataCorruptedError(
                forKey: .method,
                in: container,
                debugDescription: "Unknown payment method: \(methodString)"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .card(let value):
            try encode(value, method: "card", to: encoder)
        case .clickToPay(let value):
            try encode(value, method: "click_to_pay", to: encoder)
        case .id(let value):
            try encode(value, method: "id", to: encoder)
        }
    }

    /// Helper to avoid repetition in `encode(to:)`
    private func encode<T: Encodable>(_ value: T, method: String, to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DiscriminatorKeys.self)
        try container.encode(method, forKey: .method)
        try value.encode(to: encoder)
    }
}
