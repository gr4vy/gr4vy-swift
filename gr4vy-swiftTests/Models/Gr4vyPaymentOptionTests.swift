//
//  Gr4vyPaymentOptionTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyPaymentOptionTests: XCTestCase {
    // MARK: - Helpers
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private func decode(_ json: String) throws -> Gr4vyPaymentOption {
        try decoder.decode(Gr4vyPaymentOption.self, from: Data(json.utf8))
    }

    private func encode(_ paymentOption: Gr4vyPaymentOption) throws -> String {
        let data = try encoder.encode(paymentOption)
        return String(data: data, encoding: .utf8) ?? ""
    }

    // MARK: - Root "happy-path" test 

    func testDecodeValidPaymentOptionWithAllFields() throws {
        let json = #"""
            {
            "type": "payment-option",
            "method": "card",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "icon_url": "https://example.com/icon.png",
            "label": "Visa or Mastercard",
            "context": {
            "merchant_name": "Full Example Merchant",
            "supported_schemes": ["visa","mastercard"]
            }
            }
        """#

        let option = try decode(json)

        XCTAssertEqual(option.type, "payment-option")
        XCTAssertEqual(option.method, "card")
        XCTAssertEqual(option.mode, "test")
        XCTAssertTrue(option.canStorePaymentMethod)
        XCTAssertFalse(option.canDelayCapture)
        XCTAssertEqual(option.iconUrl, "https://example.com/icon.png")
        XCTAssertEqual(option.label, "Visa or Mastercard")

        guard case .wallet(let ctx) = option.context else {
            return XCTFail("Expected WalletContext, got \(String(describing: option.context))")
        }
        XCTAssertEqual(ctx.merchantName, "Full Example Merchant")
        XCTAssertEqual(ctx.supportedSchemes, ["visa", "mastercard"])
    }

    // MARK: - Encoding Tests 

    func testEncodePaymentOptionWithWalletContext() throws {
        let json = #"""
            {
            "type": "payment-option",
            "method": "card",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "icon_url": "https://example.com/icon.png",
            "label": "Visa or Mastercard",
            "context": {
            "merchant_name": "Test Merchant",
            "supported_schemes": ["visa","mastercard"]
            }
            }
        """#

        let originalOption = try decode(json)
        let encodedJson = try encode(originalOption)
        let decodedOption = try decoder.decode(Gr4vyPaymentOption.self, from: Data(encodedJson.utf8))

        // Verify round-trip encoding/decoding
        XCTAssertEqual(originalOption.type, decodedOption.type)
        XCTAssertEqual(originalOption.method, decodedOption.method)
        XCTAssertEqual(originalOption.mode, decodedOption.mode)
        XCTAssertEqual(originalOption.canStorePaymentMethod, decodedOption.canStorePaymentMethod)
        XCTAssertEqual(originalOption.canDelayCapture, decodedOption.canDelayCapture)
        XCTAssertEqual(originalOption.iconUrl, decodedOption.iconUrl)
        XCTAssertEqual(originalOption.label, decodedOption.label)

        // Verify context encoding
        guard case .wallet(let originalCtx) = originalOption.context,
              case .wallet(let decodedCtx) = decodedOption.context else {
            return XCTFail("Expected WalletContext in both options")
        }
        XCTAssertEqual(originalCtx.merchantName, decodedCtx.merchantName)
        XCTAssertEqual(originalCtx.supportedSchemes, decodedCtx.supportedSchemes)
    }

    func testEncodePaymentOptionWithGoogleContext() throws {
        let json = #"""
            {
            "method": "card",
            "mode": "live",
            "can_store_payment_method": true,
            "can_delay_capture": true,
            "context": {
            "merchant_name": "GPay Merchant",
            "supported_schemes": ["visa"],
            "gateway": "gr4vy",
            "gateway_merchant_id": "123"
            }
            }
        """#

        let originalOption = try decode(json)
        let encodedJson = try encode(originalOption)
        let decodedOption = try decoder.decode(Gr4vyPaymentOption.self, from: Data(encodedJson.utf8))

        // Verify context encoding
        guard case .google(let originalCtx) = originalOption.context,
              case .google(let decodedCtx) = decodedOption.context else {
            return XCTFail("Expected GoogleContext in both options")
        }
        XCTAssertEqual(originalCtx.gateway, decodedCtx.gateway)
        XCTAssertEqual(originalCtx.gatewayMerchantId, decodedCtx.gatewayMerchantId)
        XCTAssertEqual(originalCtx.merchantName, decodedCtx.merchantName)
        XCTAssertEqual(originalCtx.supportedSchemes, decodedCtx.supportedSchemes)
    }

    func testEncodePaymentOptionWithPaymentContext() throws {
        let json = #"""
            {
            "method": "bank_redirect",
            "mode": "test",
            "can_store_payment_method": false,
            "can_delay_capture": true,
            "context": {
            "redirect_requires_popup": true,
            "requires_tokenized_redirect_popup": false,
            "approval_ui": {
            "height": "600px",
            "width": "400px"
            },
            "required_fields": {
            "account_number": true,
            "postal_code": false
            }
            }
            }
        """#

        let originalOption = try decode(json)
        let encodedJson = try encode(originalOption)
        let decodedOption = try decoder.decode(Gr4vyPaymentOption.self, from: Data(encodedJson.utf8))

        // Verify context encoding
        guard case .payment(let originalCtx) = originalOption.context,
              case .payment(let decodedCtx) = decodedOption.context else {
            return XCTFail("Expected PaymentContext in both options")
        }
        XCTAssertEqual(originalCtx.redirectRequiresPopup, decodedCtx.redirectRequiresPopup)
        XCTAssertEqual(originalCtx.requiresTokenizedRedirectPopup, decodedCtx.requiresTokenizedRedirectPopup)
        XCTAssertEqual(originalCtx.approvalUI?.height, decodedCtx.approvalUI?.height)
        XCTAssertEqual(originalCtx.approvalUI?.width, decodedCtx.approvalUI?.width)
        XCTAssertEqual(originalCtx.requiredFields?["account_number"], decodedCtx.requiredFields?["account_number"])
        XCTAssertEqual(originalCtx.requiredFields?["postal_code"], decodedCtx.requiredFields?["postal_code"])
    }

    func testEncodePaymentOptionWithNilOptionalFields() throws {
        let json = """
        {
            "method": "card",
            "mode": "live",
            "can_store_payment_method": false,
            "can_delay_capture": true
        }
        """

        let originalOption = try decode(json)
        let encodedJson = try encode(originalOption)
        let decodedOption = try decoder.decode(Gr4vyPaymentOption.self, from: Data(encodedJson.utf8))

        // Verify nil fields are handled correctly
        XCTAssertEqual(originalOption.type, decodedOption.type)
        XCTAssertEqual(originalOption.method, decodedOption.method)
        XCTAssertEqual(originalOption.mode, decodedOption.mode)
        XCTAssertNil(decodedOption.iconUrl)
        XCTAssertNil(decodedOption.label)
        XCTAssertNil(decodedOption.context)
    }

    // MARK: - PaymentOptionsWrapper Tests 

    func testPaymentOptionsWrapperDecoding() throws {
        let json = #"""
            {
            "items": [
            {
            "type": "payment-option",
            "method": "card",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "context": {
            "merchant_name": "Test Merchant",
            "supported_schemes": ["visa"]
            }
            },
            {
            "method": "bank_redirect",
            "mode": "live",
            "can_store_payment_method": false,
            "can_delay_capture": true,
            "context": {
            "redirect_requires_popup": true,
            "requires_tokenized_redirect_popup": false
            }
            }
            ]
            }
        """#

        let wrapper = try decoder.decode(PaymentOptionsWrapper.self, from: Data(json.utf8))

        XCTAssertEqual(wrapper.items.count, 2)

        // First item
        let firstItem = wrapper.items[0]
        XCTAssertEqual(firstItem.type, "payment-option")
        XCTAssertEqual(firstItem.method, "card")
        XCTAssertEqual(firstItem.mode, "test")
        XCTAssertTrue(firstItem.canStorePaymentMethod)
        XCTAssertFalse(firstItem.canDelayCapture)

        guard case .wallet(let ctx1) = firstItem.context else {
            return XCTFail("Expected WalletContext for first item")
        }
        XCTAssertEqual(ctx1.merchantName, "Test Merchant")
        XCTAssertEqual(ctx1.supportedSchemes, ["visa"])

        // Second item
        let secondItem = wrapper.items[1]
        XCTAssertEqual(secondItem.type, "payment-option") // Default value
        XCTAssertEqual(secondItem.method, "bank_redirect")
        XCTAssertEqual(secondItem.mode, "live")
        XCTAssertFalse(secondItem.canStorePaymentMethod)
        XCTAssertTrue(secondItem.canDelayCapture)

        guard case .payment(let ctx2) = secondItem.context else {
            return XCTFail("Expected PaymentContext for second item")
        }
        XCTAssertTrue(ctx2.redirectRequiresPopup)
        XCTAssertFalse(ctx2.requiresTokenizedRedirectPopup)
    }

    func testPaymentOptionsWrapperWithEmptyItems() throws {
        let json = """
        {
          "items": []
        }
        """

        let wrapper = try decoder.decode(PaymentOptionsWrapper.self, from: Data(json.utf8))
        XCTAssertEqual(wrapper.items.count, 0)
        XCTAssertTrue(wrapper.items.isEmpty)
    }

    func testPaymentOptionsWrapperFailsWithMissingItems() {
        let json = """
        {
          "other_field": "value"
        }
        """

        XCTAssertThrowsError(try decoder.decode(PaymentOptionsWrapper.self, from: Data(json.utf8)))
    }

    // MARK: - Context Enum Edge Cases 

    func testContextEnumWithAmbiguousFields() throws {
        // Test case where context could match multiple types
        let json = #"""
            {
            "method": "card",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "context": {
            "merchant_name": "Ambiguous Merchant",
            "supported_schemes": ["visa"],
            "gateway": "test_gateway",
            "gateway_merchant_id": "test_123",
            "redirect_requires_popup": false,
            "requires_tokenized_redirect_popup": true
            }
            }
        """#

        let option = try decode(json)

        // Should prioritize PaymentContext due to redirect_requires_popup presence
        guard case .payment(let ctx) = option.context else {
            return XCTFail("Expected PaymentContext due to redirect_requires_popup field")
        }
        XCTAssertFalse(ctx.redirectRequiresPopup)
        XCTAssertTrue(ctx.requiresTokenizedRedirectPopup)
    }

    func testContextEnumWithGatewayFieldsOnly() throws {
        let json = #"""
            {
            "method": "card",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "context": {
            "merchant_name": "Gateway Merchant",
            "supported_schemes": ["visa"],
            "gateway": "stripe",
            "gateway_merchant_id": "stripe_123"
            }
            }
        """#

        let option = try decode(json)

        // Should be GoogleContext due to gateway field presence
        guard case .google(let ctx) = option.context else {
            return XCTFail("Expected GoogleContext due to gateway field")
        }
        XCTAssertEqual(ctx.gateway, "stripe")
        XCTAssertEqual(ctx.gatewayMerchantId, "stripe_123")
        XCTAssertEqual(ctx.merchantName, "Gateway Merchant")
    }

    func testContextEnumWithGatewayMerchantIdOnly() throws {
        let json = #"""
            {
            "method": "card",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "context": {
            "merchant_name": "Gateway Merchant",
            "supported_schemes": ["visa"],
            "gateway": "paypal",
            "gateway_merchant_id": "gw_123"
            }
            }
        """#

        let option = try decode(json)

        // Should be GoogleContext due to gateway_merchant_id field presence
        guard case .google(let ctx) = option.context else {
            return XCTFail("Expected GoogleContext due to gateway_merchant_id field")
        }
        XCTAssertEqual(ctx.gateway, "paypal")
        XCTAssertEqual(ctx.gatewayMerchantId, "gw_123")
    }

    // MARK: - Complex Scenarios 

    func testComplexPaymentOptionsArray() throws {
        let json = #"""
            {
            "items": [
            {
            "type": "payment-option",
            "method": "card",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "icon_url": "https://example.com/card.png",
            "label": "Credit Card",
            "context": {
            "merchant_name": "Card Merchant",
            "supported_schemes": ["visa","mastercard","amex"]
            }
            },
            {
            "method": "google_pay",
            "mode": "live",
            "can_store_payment_method": true,
            "can_delay_capture": true,
            "icon_url": "https://example.com/gpay.png",
            "label": "Google Pay",
            "context": {
            "merchant_name": "GPay Merchant",
            "supported_schemes": ["visa","mastercard"],
            "gateway": "gr4vy",
            "gateway_merchant_id": "gw_123456"
            }
            },
            {
            "method": "bank_redirect",
            "mode": "test",
            "can_store_payment_method": false,
            "can_delay_capture": true,
            "icon_url": "https://example.com/bank.png",
            "label": "Bank Transfer",
            "context": {
            "redirect_requires_popup": true,
            "requires_tokenized_redirect_popup": false,
            "approval_ui": {
            "height": "800px",
            "width": "600px"
            },
            "required_fields": {
            "account_number": true,
            "routing_number": true,
            "account_type": false
            }
            }
            }
            ]
            }
        """#

        let wrapper = try decoder.decode(PaymentOptionsWrapper.self, from: Data(json.utf8))

        XCTAssertEqual(wrapper.items.count, 3)

        // Verify each item type
        guard case .wallet = wrapper.items[0].context else {
            XCTFail("First item should have WalletContext")
            return
        }

        guard case .google(let googleCtx) = wrapper.items[1].context else {
            XCTFail("Second item should have GoogleContext")
            return
        }
        XCTAssertEqual(googleCtx.gateway, "gr4vy")
        XCTAssertEqual(googleCtx.gatewayMerchantId, "gw_123456")

        guard case .payment(let paymentCtx) = wrapper.items[2].context else {
            XCTFail("Third item should have PaymentContext")
            return
        }
        XCTAssertTrue(paymentCtx.redirectRequiresPopup)
        XCTAssertEqual(paymentCtx.approvalUI?.height, "800px")
        XCTAssertEqual(paymentCtx.requiredFields?["account_number"], true)
        XCTAssertEqual(paymentCtx.requiredFields?["account_type"], false)
    }

    // MARK: - Error Handling Tests 

    func testInvalidJSONStructure() {
        let invalidJsons = [
            "invalid json",
            "[]",
            "null",
            "{\"method\": null}",
            "{\"method\": 123}",
            "{\"can_store_payment_method\": \"not_a_boolean\"}",
        ]

        for invalidJson in invalidJsons {
            XCTAssertThrowsError(try decode(invalidJson), "Should throw error for: \(invalidJson)")
        }
    }

    func testMalformedContexts() {
        let malformedContexts = [
            // Invalid wallet context
            #"""
                {
                "method": "card",
                "mode": "test",
                "can_store_payment_method": true,
                "can_delay_capture": false,
                "context": {
                "merchant_name": 123,
                "supported_schemes": ["visa"]
                }
                }
            """#,
            // Invalid google context
            #"""
                {
                "method": "card",
                "mode": "test",
                "can_store_payment_method": true,
                "can_delay_capture": false,
                "context": {
                "merchant_name": "Test",
                "supported_schemes": "not_an_array",
                "gateway": "test"
                }
                }
            """#,
            // Invalid payment context
            #"""
                {
                "method": "bank_redirect",
                "mode": "test",
                "can_store_payment_method": false,
                "can_delay_capture": true,
                "context": {
                "redirect_requires_popup": "not_a_boolean",
                "requires_tokenized_redirect_popup": true
                }
                }
            """#,
        ]

        for malformedJson in malformedContexts {
            XCTAssertThrowsError(try decode(malformedJson), "Should throw error for malformed context")
        }
    }

    // MARK: - Original Tests 

    func testDecodePaymentOptionWithMissingOptionalFields() throws {
        let json = """
        {
            "type": "payment-option",
            "method": "card",
            "mode": "live",
            "can_store_payment_method": false,
            "can_delay_capture": true
        }
        """

        let option = try decode(json)

        XCTAssertEqual(option.type, "payment-option")
        XCTAssertEqual(option.method, "card")
        XCTAssertEqual(option.mode, "live")
        XCTAssertFalse(option.canStorePaymentMethod)
        XCTAssertTrue(option.canDelayCapture)
        XCTAssertNil(option.iconUrl)
        XCTAssertNil(option.label)
        // context defaults to WalletContext with required fields missing, so decode should throw.
        // If model guarantees nil instead, adjust accordingly.
    }

    func testDecodeFailsWithMissingRequiredFields() {
        let json = """
        {
            "type": "payment-option",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false
        }
        """
        XCTAssertThrowsError(try decode(json))
    }

    func testDecodeDefaultsTypeToPaymentOption() throws {
        let json = """
        {
            "method": "card",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": true,
            "context": {
              "merchant_name": "Wallet Merchant",
              "supported_schemes": ["visa","mastercard"]
            }
        }
        """

        let option = try decode(json)
        XCTAssertEqual(option.type, "payment-option")
    }

    // ------------------------------
    // WalletContext
    // ------------------------------

    func testWalletContextDecodesSuccessfully() throws {
        let json = #"""
            {
            "method": "card",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "context": {
            "merchant_name": "Wallet Merchant",
            "supported_schemes": ["visa","mastercard"]
            }
            }
        """#
        let option = try decode(json)
        guard case .wallet(let ctx) = option.context else {
            return XCTFail("Expected WalletContext")
        }
        XCTAssertEqual(ctx.merchantName, "Wallet Merchant")
        XCTAssertEqual(ctx.supportedSchemes, ["visa", "mastercard"])
    }

    func testWalletContextFailsWhenMissingRequiredFields() {
        let json = #"""
            {
            "method": "card",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "context": {
            "merchant_name": "No Schemes"
            }
            }
        """#
        XCTAssertThrowsError(try decode(json))
    }

    // ------------------------------
    // GoogleContext
    // ------------------------------

    func testGoogleContextDecodesSuccessfully() throws {
        let json = #"""
            {
            "method": "card",
            "mode": "live",
            "can_store_payment_method": true,
            "can_delay_capture": true,
            "context": {
            "merchant_name": "GPay Merchant",
            "supported_schemes": ["visa"],
            "gateway": "gr4vy",
            "gateway_merchant_id": "123"
            }
            }
        """#
        let option = try decode(json)
        guard case .google(let ctx) = option.context else {
            return XCTFail("Expected GoogleContext")
        }
        XCTAssertEqual(ctx.gateway, "gr4vy")
        XCTAssertEqual(ctx.gatewayMerchantId, "123")
        XCTAssertEqual(ctx.supportedSchemes, ["visa"])
    }

    func testGoogleContextFailsWhenMissingRequiredFields() {
        let json = #"""
            {
            "method": "card",
            "mode": "live",
            "can_store_payment_method": true,
            "can_delay_capture": true,
            "context": {
            "merchant_name": "Bad GPay",
            "supported_schemes": ["visa"],
            "gateway": "gr4vy"
            }
            }
        """#
        XCTAssertThrowsError(try decode(json))
    }

    // ------------------------------
    // PaymentContext
    // ------------------------------

    func testPaymentContextDecodesWithOnlyRequiredFields() throws {
        let json = #"""
            {
            "method": "bank_redirect",
            "mode": "test",
            "can_store_payment_method": false,
            "can_delay_capture": true,
            "context": {
            "redirect_requires_popup": false,
            "requires_tokenized_redirect_popup": true
            }
            }
        """#
        let option = try decode(json)
        guard case .payment(let ctx) = option.context else {
            return XCTFail("Expected PaymentContext")
        }
        XCTAssertFalse(ctx.redirectRequiresPopup)
        XCTAssertTrue(ctx.requiresTokenizedRedirectPopup)
        XCTAssertNil(ctx.approvalUI)
        XCTAssertNil(ctx.requiredFields)
    }

    func testPaymentContextDecodesWithOptionalChildren() throws {
        let json = #"""
            {
            "method": "bank_redirect",
            "mode": "live",
            "can_store_payment_method": false,
            "can_delay_capture": true,
            "context": {
            "redirect_requires_popup": true,
            "requires_tokenized_redirect_popup": false,
            "approval_ui": {
            "height": "600px",
            "width": "400px"
            },
            "required_fields": {
            "account_number": true,
            "postal_code": false
            }
            }
            }
        """#
        let option = try decode(json)
        guard case .payment(let ctx) = option.context else {
            return XCTFail("Expected PaymentContext")
        }
        XCTAssertEqual(ctx.approvalUI?.height, "600px")
        XCTAssertEqual(ctx.requiredFields?["account_number"], true)
        XCTAssertEqual(ctx.requiredFields?["postal_code"], false)
    }

    func testPaymentContextFailsWhenMissingRequiredFields() {
        let json = #"""
            {
            "method": "bank_redirect",
            "mode": "test",
            "can_store_payment_method": false,
            "can_delay_capture": true,
            "context": {
            }
            }
        """#
        XCTAssertThrowsError(try decode(json))
    }

    // ------------------------------
    // Additional edge-cases for PaymentContext
    // ------------------------------

    func testPaymentContextWithEmptyRequiredFields() throws {
        let json = #"""
            {
            "method": "bank_redirect",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "context": {
            "redirect_requires_popup": true,
            "requires_tokenized_redirect_popup": true,
            "required_fields": {}
            }
            }
        """#
        let option = try decode(json)
        guard case .payment(let ctx) = option.context else {
            return XCTFail("Expected PaymentContext")
        }
        XCTAssertNotNil(ctx.requiredFields)
        XCTAssertTrue(ctx.requiredFields!.isEmpty)
    }

    func testPaymentContextWithNullApprovalUI() throws {
        let json = #"""
            {
            "method": "bank_redirect",
            "mode": "live",
            "can_store_payment_method": true,
            "can_delay_capture": false,
            "context": {
            "redirect_requires_popup": true,
            "requires_tokenized_redirect_popup": true,
            "approval_ui": {
            "height": null,
            "width": null
            }
            }
            }
        """#
        let option = try decode(json)
        guard case .payment(let ctx) = option.context else {
            return XCTFail("Expected PaymentContext")
        }
        XCTAssertNotNil(ctx.approvalUI)
        XCTAssertNil(ctx.approvalUI?.height)
        XCTAssertNil(ctx.approvalUI?.width)
    }

    func testPaymentContextWithDynamicRequiredFieldKeys() throws {
        let json = #"""
            {
            "method": "bank_redirect",
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": true,
            "context": {
            "redirect_requires_popup": false,
            "requires_tokenized_redirect_popup": true,
            "required_fields": {
            "custom_flag_1": true,
            "enable_fraud_check": false
            }
            }
            }
        """#
        let option = try decode(json)
        guard case .payment(let ctx) = option.context else {
            return XCTFail("Expected PaymentContext")
        }
        XCTAssertEqual(ctx.requiredFields?["custom_flag_1"], true)
        XCTAssertEqual(ctx.requiredFields?["enable_fraud_check"], false)
    }

    // ------------------------------
    // Root model guard
    // ------------------------------

    func testPaymentOptionFailsWhenRootRequiredFieldsMissing() {
        let json = #"""
            {
            "mode": "test",
            "can_store_payment_method": true,
            "can_delay_capture": true,
            "context": {
            "merchant_name": "Wallet Merchant",
            "supported_schemes": ["visa"]
            }
            }
        """#
        XCTAssertThrowsError(try decode(json))
    }
}
