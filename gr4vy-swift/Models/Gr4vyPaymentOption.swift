//
//  Gr4vyPaymentOption.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vyPaymentOption: Codable {
    // MARK: - Properties
    public let method: String?
    public let mode: String?
    public let canStorePaymentMethod: Bool?
    public let canDelayCapture: Bool?
    public let type: String
    public let iconUrl: String?
    public let label: String?
    public let context: Gr4vyPaymentOptionContext?

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case type
        case method
        case mode
        case canStorePaymentMethod = "can_store_payment_method"
        case canDelayCapture = "can_delay_capture"
        case iconUrl = "icon_url"
        case label
        case context
    }

    // MARK: - Initializer
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.method = try container.decodeIfPresent(String.self, forKey: .method)
        self.mode = try container.decodeIfPresent(String.self, forKey: .mode)
        self.canStorePaymentMethod = try container.decodeIfPresent(Bool.self, forKey: .canStorePaymentMethod)
        self.canDelayCapture = try container.decodeIfPresent(Bool.self, forKey: .canDelayCapture)
        self.type = try container.decodeIfPresent(String.self, forKey: .type) ?? "payment-option"
        self.iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.context = try container.decodeIfPresent(Gr4vyPaymentOptionContext.self, forKey: .context)
    }
}

public enum Gr4vyPaymentOptionContext: Codable {
    // MARK: - Cases
    case wallet(Gr4vyWalletContext)
    case google(Gr4vyGoogleContext)
    case payment(Gr4vyPaymentContext)

    // MARK: - CodingKeys
    private enum ContextKey: String, CodingKey {
        case gateway, gatewayMerchantId = "gateway_merchant_id"
        case redirectRequiresPopup = "redirect_requires_popup"
    }

    // MARK: - Initializer
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContextKey.self)

        if container.contains(.redirectRequiresPopup) {
            self = .payment(try Gr4vyPaymentContext(from: decoder))
        } else if container.contains(.gateway) || container.contains(.gatewayMerchantId) {
            self = .google(try Gr4vyGoogleContext(from: decoder))
        } else {
            self = .wallet(try Gr4vyWalletContext(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .wallet(let ctx):   try ctx.encode(to: encoder)
        case .google(let ctx):   try ctx.encode(to: encoder)
        case .payment(let ctx):  try ctx.encode(to: encoder)
        }
    }

    public struct Gr4vyWalletContext: Codable {
        // MARK: - Properties
        let merchantName: String?
        let supportedSchemes: [String]?

        // MARK: - CodingKeys
        enum CodingKeys: String, CodingKey {
            case merchantName = "merchant_name"
            case supportedSchemes = "supported_schemes"
        }
    }

    public struct Gr4vyGoogleContext: Codable {
        // MARK: - Properties
        let merchantName: String?
        let supportedSchemes: [String]?
        let gateway: String?
        let gatewayMerchantId: String?

        // MARK: - CodingKeys
        enum CodingKeys: String, CodingKey {
            case merchantName = "merchant_name"
            case supportedSchemes = "supported_schemes"
            case gateway
            case gatewayMerchantId = "gateway_merchant_id"
        }
    }

    public struct Gr4vyPaymentContext: Codable {
        // MARK: - Properties
        let redirectRequiresPopup: Bool?
        let requiresTokenizedRedirectPopup: Bool?
        let approvalUI: Gr4vyApprovalUI?
        let requiredFields: Gr4vyRequiredFields?

        // MARK: - CodingKeys
        enum CodingKeys: String, CodingKey {
            case redirectRequiresPopup = "redirect_requires_popup"
            case requiresTokenizedRedirectPopup = "requires_tokenized_redirect_popup"
            case approvalUI = "approval_ui"
            case requiredFields = "required_fields"
        }

        struct Gr4vyApprovalUI: Codable {
            // MARK: - Properties
            let height: String?
            let width: String?

            // MARK: - CodingKeys
            enum CodingKeys: String, CodingKey {
                case height, width
            }
        }
        
        public struct Gr4vyRequiredFields: Codable {
            // MARK: - Properties
            public let emailAddress: Bool?
            public let taxId: Bool?
            public let firstName: Bool?
            public let lastName: Bool?
            public let address: Gr4vyAddressRequiredFields?
            // Store any additional dynamic fields
            private var additionalFields: [String: Bool] = [:]
            
            // MARK: - CodingKeys
            enum CodingKeys: String, CodingKey {
                case emailAddress = "email_address"
                case taxId = "tax_id"
                case firstName = "first_name"
                case lastName = "last_name"
                case address
            }
            
            // MARK: - Custom Decoding
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                // Decode known boolean fields
                emailAddress = try container.decodeIfPresent(Bool.self, forKey: .emailAddress)
                taxId = try container.decodeIfPresent(Bool.self, forKey: .taxId)
                firstName = try container.decodeIfPresent(Bool.self, forKey: .firstName)
                lastName = try container.decodeIfPresent(Bool.self, forKey: .lastName)
                
                // Decode address object if present
                address = try container.decodeIfPresent(Gr4vyAddressRequiredFields.self, forKey: .address)
                
                // Decode any additional dynamic fields (flat boolean fields that aren't known)
                let allKeysContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
                for key in allKeysContainer.allKeys {
                    let codingKey = CodingKeys(stringValue: key.stringValue)
                    // Skip known fields and address (already decoded)
                    if codingKey == nil {
                        // Try to decode as Bool for additional fields
                        if let boolValue = try? allKeysContainer.decode(Bool.self, forKey: key) {
                            additionalFields[key.stringValue] = boolValue
                        }
                    }
                }
            }
            
            // MARK: - Custom Encoding
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: DynamicCodingKey.self)
                
                // Encode known fields
                if let emailAddress = emailAddress {
                    try container.encode(emailAddress, forKey: DynamicCodingKey(stringValue: CodingKeys.emailAddress.rawValue))
                }
                if let taxId = taxId {
                    try container.encode(taxId, forKey: DynamicCodingKey(stringValue: CodingKeys.taxId.rawValue))
                }
                if let firstName = firstName {
                    try container.encode(firstName, forKey: DynamicCodingKey(stringValue: CodingKeys.firstName.rawValue))
                }
                if let lastName = lastName {
                    try container.encode(lastName, forKey: DynamicCodingKey(stringValue: CodingKeys.lastName.rawValue))
                }
                if let address = address {
                    try container.encode(address, forKey: DynamicCodingKey(stringValue: CodingKeys.address.rawValue))
                }
                
                // Encode additional dynamic fields
                for (key, value) in additionalFields {
                    try container.encode(value, forKey: DynamicCodingKey(stringValue: key))
                }
            }
            
            // MARK: - Accessor for dynamic fields
            public func getField(_ key: String) -> Bool? {
                return additionalFields[key]
            }
            
            // MARK: - Subscript for dictionary-like access (backward compatibility)
            public subscript(key: String) -> Bool? {
                // Check known fields first
                switch key {
                case "email_address":
                    return emailAddress
                case "tax_id":
                    return taxId
                case "first_name":
                    return firstName
                case "last_name":
                    return lastName
                default:
                    // Check additional dynamic fields
                    return additionalFields[key]
                }
            }
            
            // MARK: - Computed properties for backward compatibility
            public var isEmpty: Bool {
                return emailAddress == nil &&
                       taxId == nil &&
                       firstName == nil &&
                       lastName == nil &&
                       address == nil &&
                       additionalFields.isEmpty
            }
            
            // MARK: - Dynamic Coding Key
            private struct DynamicCodingKey: CodingKey {
                var stringValue: String
                var intValue: Int?
                
                init(stringValue: String) {
                    self.stringValue = stringValue
                }
                
                init?(intValue: Int) {
                    return nil
                }
            }
            
            public struct Gr4vyAddressRequiredFields: Codable {
                // MARK: - Properties
                public let organization: Bool?
                public let houseNumberOrName: Bool?
                public let line1: Bool?
                public let line2: Bool?
                public let postalCode: Bool?
                public let city: Bool?
                public let state: Bool?
                public let stateCode: Bool?
                public let country: Bool?
                
                // MARK: - CodingKeys
                enum CodingKeys: String, CodingKey {
                    case organization
                    case houseNumberOrName = "house_number_or_name"
                    case line1
                    case line2
                    case postalCode = "postal_code"
                    case city
                    case state
                    case stateCode = "state_code"
                    case country
                }
            }
        }
    }
}

public struct PaymentOptionsWrapper: Decodable {
    // MARK: - Properties
    let items: [Gr4vyPaymentOption]
}
