//
//  Gr4vyPaymentOption.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vyPaymentOption: Codable {
    // MARK: - Properties
    public let method: String
    public let mode: String
    public let canStorePaymentMethod: Bool
    public let canDelayCapture: Bool
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
        self.method = try container.decode(String.self, forKey: .method)
        self.mode = try container.decode(String.self, forKey: .mode)
        self.canStorePaymentMethod = try container.decode(Bool.self, forKey: .canStorePaymentMethod)
        self.canDelayCapture = try container.decode(Bool.self, forKey: .canDelayCapture)
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
        let merchantName: String
        let supportedSchemes: [String]

        // MARK: - CodingKeys
        enum CodingKeys: String, CodingKey {
            case merchantName = "merchant_name"
            case supportedSchemes = "supported_schemes"
        }
    }

    public struct Gr4vyGoogleContext: Codable {
        // MARK: - Properties
        let merchantName: String
        let supportedSchemes: [String]
        let gateway: String
        let gatewayMerchantId: String

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
        let redirectRequiresPopup: Bool
        let requiresTokenizedRedirectPopup: Bool
        let approvalUI: Gr4vyApprovalUI?
        let requiredFields: [String: Bool]?

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
    }
}

public struct PaymentOptionsWrapper: Decodable {
    // MARK: - Properties
    let items: [Gr4vyPaymentOption]
}
