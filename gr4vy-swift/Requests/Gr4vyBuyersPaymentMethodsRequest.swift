//
//  Gr4vyBuyersPaymentMethodsRequest.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vyBuyersPaymentMethodsRequest: Encodable {
    // MARK: - Properties
    public let merchantId: String?
    public let timeout: TimeInterval?
    public let paymentMethods: Gr4vyBuyersPaymentMethods

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case paymentMethods = "payment_methods"
    }
    
    // MARK: - Initializer
    public init(paymentMethods: Gr4vyBuyersPaymentMethods, merchantId: String? = nil, timeout: TimeInterval? = nil) {
        self.paymentMethods = paymentMethods
        self.merchantId = merchantId
        self.timeout = timeout
    }
}
