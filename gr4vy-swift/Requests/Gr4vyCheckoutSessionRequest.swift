//
//  Gr4vyCheckoutSessionRequest.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vyCheckoutSessionRequest: Encodable {
    // MARK: - Properties
    public let timeout: TimeInterval?
    public let paymentMethod: Gr4vyPaymentMethod

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case paymentMethod = "payment_method"
    }
    
    // MARK: - Initializer
    public init(paymentMethod: Gr4vyPaymentMethod, timeout: TimeInterval? = nil) {
        self.paymentMethod = paymentMethod
        self.timeout = timeout
    }
}
