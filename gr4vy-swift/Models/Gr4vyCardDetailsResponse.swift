//
//  Gr4vyCardDetailsResponse.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vyCardDetailsResponse: Codable {
    // MARK: - Properties
    public let type: String
    public let id: String
    public let cardType: String
    public let scheme: String
    public let schemeIconURL: URL?
    public let country: String?
    public let requiredFields: RequiredFields?

    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case cardType = "card_type"
        case scheme
        case schemeIconURL = "scheme_icon_url"
        case country
        case requiredFields = "required_fields"
    }

    public struct RequiredFields: Codable {
        // MARK: - Properties
        public let firstName: Bool?
        public let lastName: Bool?
        public let emailAddress: Bool?
        public let phoneNumber: Bool?
        public let address: Address?
        public let taxId: Bool?

        // MARK: - CodingKeys
        private enum CodingKeys: String, CodingKey {
            case firstName = "first_name"
            case lastName = "last_name"
            case emailAddress = "email_address"
            case phoneNumber = "phone_number"
            case address
            case taxId = "tax_id"
        }

        public struct Address: Codable {
            // MARK: - Properties
            public let city: Bool?
            public let country: Bool?
            public let postalCode: Bool?
            public let state: Bool?
            public let houseNumberOrName: Bool?
            public let line1: Bool?

            // MARK: - CodingKeys
            private enum CodingKeys: String, CodingKey {
                case city
                case country
                case postalCode = "postal_code"
                case state
                case houseNumberOrName = "house_number_or_name"
                case line1
            }
        }
    }
}
