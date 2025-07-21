//
//  Gr4vyPaymentOptionRequest.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vyPaymentOptionRequest: Encodable {
    // MARK: - Properties
    let merchantId: String?
    let timeout: TimeInterval?
    let metadata: [String: String]
    let country: String?
    let currency: String?
    let amount: Int?
    let locale: String
    let cartItems: [Gr4vyPaymentOptionCartItem]?

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case metadata
        case country
        case currency
        case amount
        case locale
        case cartItems = "cart_items"
    }
    
    // MARK: - Initializer
    public init(
        merchantId: String? = nil,
        metadata: [String: String],
        country: String?,
        currency: String?,
        amount: Int?,
        locale: String,
        cartItems: [Gr4vyPaymentOptionCartItem]?,
        timeout: TimeInterval? = nil
    ) {
        self.merchantId = merchantId
        self.metadata = metadata
        self.country = country
        self.currency = currency
        self.amount = amount
        self.locale = locale
        self.cartItems = cartItems
        self.timeout = timeout
    }
}

public struct Gr4vyPaymentOptionCartItem: Encodable {
    // MARK: - Properties
    let name: String
    let quantity: Int
    let unitAmount: Int
    let discountAmount: Int?
    let taxAmount: Int?
    let externalIdentifier: String?
    let sku: String?
    let productUrl: String?
    let imageUrl: String?
    let categories: [String]?
    let productType: String?
    let sellerCountry: String?

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case name
        case quantity
        case unitAmount = "unit_amount"
        case discountAmount = "discount_amount"
        case taxAmount = "tax_amount"
        case externalIdentifier = "external_identifier"
        case sku
        case productUrl = "product_url"
        case imageUrl = "image_url"
        case categories
        case productType = "product_type"
        case sellerCountry = "seller_country"
    }
    
    // MARK: - Initializer
    public init(
        name: String,
        quantity: Int,
        unitAmount: Int,
        discountAmount: Int?,
        taxAmount: Int?,
        externalIdentifier: String?,
        sku: String?,
        productUrl: String?,
        imageUrl: String?,
        categories: [String]?,
        productType: String?,
        sellerCountry: String?
    ) {
        self.name = name
        self.quantity = quantity
        self.unitAmount = unitAmount
        self.discountAmount = discountAmount
        self.taxAmount = taxAmount
        self.externalIdentifier = externalIdentifier
        self.sku = sku
        self.productUrl = productUrl
        self.imageUrl = imageUrl
        self.categories = categories
        self.productType = productType
        self.sellerCountry = sellerCountry
    }
}
