//
//  Gr4vyBuyersPaymentMethodsResponseTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyBuyersPaymentMethodsResponseTests: XCTestCase {
    // MARK: - Helpers
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private func decode(_ json: String) throws -> Gr4vyBuyersPaymentMethodsResponse {
        try decoder.decode(Gr4vyBuyersPaymentMethodsResponse.self, from: Data(json.utf8))
    }

    private func encode(_ response: Gr4vyBuyersPaymentMethodsResponse) throws -> String {
        let data = try encoder.encode(response)
        return String(data: data, encoding: .utf8) ?? ""
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - JSON Decoding Tests

    func testDecodingWithCompletePaymentMethod() throws {
        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "pm_123456789",
                    "approval_url": "https://gr4vy.app/redirect/12345",
                    "country": "US",
                    "currency": "USD",
                    "details": {
                        "bin": "424242",
                        "card_type": "credit",
                        "card_issuer_name": "Chase Bank"
                    },
                    "expiration_date": "12/30",
                    "fingerprint": "fp_abc123",
                    "label": "****4242",
                    "last_replaced_at": "2024-01-15T10:30:00Z",
                    "method": "card",
                    "mode": "card",
                    "scheme": "visa",
                    "merchant_account_id": "ma_987654321",
                    "additional_schemes": ["visa", "electron"],
                    "cit_last_used_at": "2024-02-01T14:20:00Z",
                    "cit_usage_count": 5,
                    "has_replacement": false,
                    "last_used_at": "2024-02-15T09:45:00Z",
                    "usage_count": 12
                }
            ]
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.items.count, 1)

        let paymentMethod = response.items[0]
        XCTAssertEqual(paymentMethod.type, "payment-method")
        XCTAssertEqual(paymentMethod.id, "pm_123456789")
        XCTAssertEqual(paymentMethod.approvalURL?.absoluteString, "https://gr4vy.app/redirect/12345")
        XCTAssertEqual(paymentMethod.country, "US")
        XCTAssertEqual(paymentMethod.currency, "USD")
        XCTAssertEqual(paymentMethod.expirationDate, "12/30")
        XCTAssertEqual(paymentMethod.fingerprint, "fp_abc123")
        XCTAssertEqual(paymentMethod.label, "****4242")
        XCTAssertEqual(paymentMethod.lastReplacedAt, "2024-01-15T10:30:00Z")
        XCTAssertEqual(paymentMethod.method, "card")
        XCTAssertEqual(paymentMethod.mode, "card")
        XCTAssertEqual(paymentMethod.scheme, "visa")
        XCTAssertEqual(paymentMethod.merchantAccountId, "ma_987654321")
        XCTAssertEqual(paymentMethod.additionalSchemes, ["visa", "electron"])
        XCTAssertEqual(paymentMethod.citLastUsedAt, "2024-02-01T14:20:00Z")
        XCTAssertEqual(paymentMethod.citUsageCount, 5)
        XCTAssertEqual(paymentMethod.hasReplacement, false)
        XCTAssertEqual(paymentMethod.lastUsedAt, "2024-02-15T09:45:00Z")
        XCTAssertEqual(paymentMethod.usageCount, 12)

        // Test details
        let details = try XCTUnwrap(paymentMethod.details)
        XCTAssertEqual(details.bin, "424242")
        XCTAssertEqual(details.cardType, "credit")
        XCTAssertEqual(details.cardIssuerName, "Chase Bank")
    }

    func testDecodingWithMinimalPaymentMethod() throws {
        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "pm_minimal"
                }
            ]
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.items.count, 1)

        let paymentMethod = response.items[0]
        XCTAssertEqual(paymentMethod.type, "payment-method")
        XCTAssertEqual(paymentMethod.id, "pm_minimal")
        XCTAssertNil(paymentMethod.approvalURL)
        XCTAssertNil(paymentMethod.country)
        XCTAssertNil(paymentMethod.currency)
        XCTAssertNil(paymentMethod.details)
        XCTAssertNil(paymentMethod.expirationDate)
        XCTAssertNil(paymentMethod.fingerprint)
        XCTAssertNil(paymentMethod.label)
        XCTAssertNil(paymentMethod.lastReplacedAt)
        XCTAssertNil(paymentMethod.method)
        XCTAssertNil(paymentMethod.mode)
        XCTAssertNil(paymentMethod.scheme)
        XCTAssertNil(paymentMethod.merchantAccountId)
        XCTAssertNil(paymentMethod.additionalSchemes)
        XCTAssertNil(paymentMethod.citLastUsedAt)
        XCTAssertNil(paymentMethod.citUsageCount)
        XCTAssertNil(paymentMethod.hasReplacement)
        XCTAssertNil(paymentMethod.lastUsedAt)
        XCTAssertNil(paymentMethod.usageCount)
    }

    func testDecodingWithEmptyItems() throws {
        let json = """
        {
            "items": []
        }
        """

        let response = try decode(json)
        XCTAssertEqual(response.items.count, 0)
    }

    func testDecodingWithMultiplePaymentMethods() throws {
        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "pm_first",
                    "method": "card",
                    "scheme": "visa"
                },
                {
                    "type": "payment-method",
                    "id": "pm_second",
                    "method": "card",
                    "scheme": "mastercard"
                }
            ]
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.items.count, 2)
        XCTAssertEqual(response.items[0].id, "pm_first")
        XCTAssertEqual(response.items[0].scheme, "visa")
        XCTAssertEqual(response.items[1].id, "pm_second")
        XCTAssertEqual(response.items[1].scheme, "mastercard")
    }

    func testDecodingWithPartialDetails() throws {
        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "pm_partial_details",
                    "details": {
                        "bin": "424242"
                    }
                }
            ]
        }
        """

        let response = try decode(json)

        let paymentMethod = response.items[0]
        let details = try XCTUnwrap(paymentMethod.details)
        XCTAssertEqual(details.bin, "424242")
        XCTAssertNil(details.cardType)
        XCTAssertNil(details.cardIssuerName)
    }

    func testDecodingWithNullValues() throws {
        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "pm_null_test",
                    "approval_url": null,
                    "country": null,
                    "currency": null,
                    "details": null,
                    "expiration_date": null,
                    "fingerprint": null,
                    "label": null,
                    "last_replaced_at": null,
                    "method": null,
                    "mode": null,
                    "scheme": null,
                    "merchant_account_id": null,
                    "additional_schemes": null,
                    "cit_last_used_at": null,
                    "cit_usage_count": null,
                    "has_replacement": null,
                    "last_used_at": null,
                    "usage_count": null
                }
            ]
        }
        """

        let response = try decode(json)

        let paymentMethod = response.items[0]
        XCTAssertEqual(paymentMethod.type, "payment-method")
        XCTAssertEqual(paymentMethod.id, "pm_null_test")
        XCTAssertNil(paymentMethod.approvalURL)
        XCTAssertNil(paymentMethod.country)
        XCTAssertNil(paymentMethod.currency)
        XCTAssertNil(paymentMethod.details)
        XCTAssertNil(paymentMethod.expirationDate)
        XCTAssertNil(paymentMethod.fingerprint)
        XCTAssertNil(paymentMethod.label)
        XCTAssertNil(paymentMethod.lastReplacedAt)
        XCTAssertNil(paymentMethod.method)
        XCTAssertNil(paymentMethod.mode)
        XCTAssertNil(paymentMethod.scheme)
        XCTAssertNil(paymentMethod.merchantAccountId)
        XCTAssertNil(paymentMethod.additionalSchemes)
        XCTAssertNil(paymentMethod.citLastUsedAt)
        XCTAssertNil(paymentMethod.citUsageCount)
        XCTAssertNil(paymentMethod.hasReplacement)
        XCTAssertNil(paymentMethod.lastUsedAt)
        XCTAssertNil(paymentMethod.usageCount)
    }

    func testDecodingFailsWithMissingRequiredFields() {
        let invalidJsons = [
            // Missing items (only items is required)
            """
            {}
            """,
        ]

        for invalidJson in invalidJsons {
            XCTAssertThrowsError(try decode(invalidJson), "Should throw error for missing required field")
        }
    }
    
    func testDecodingWithMissingTypeAndId() throws {
        // type and id are optional, so missing them should succeed
        let json = """
        {
            "items": [
                {}
            ]
        }
        """
        
        let response = try decode(json)
        XCTAssertEqual(response.items.count, 1)
        let paymentMethod = response.items[0]
        XCTAssertNil(paymentMethod.type)
        XCTAssertNil(paymentMethod.id)
    }

    func testDecodingFailsWithInvalidDataTypes() {
        let invalidJsons = [
            // Invalid items type
            """
            {
                "items": "not_an_array"
            }
            """,
            // Invalid usage count type
            """
            {
                "items": [
                    {
                        "type": "payment-method",
                        "id": "pm_123",
                        "usage_count": "not_a_number"
                    }
                ]
            }
            """,
            // Invalid boolean type
            """
            {
                "items": [
                    {
                        "type": "payment-method",
                        "id": "pm_123",
                        "has_replacement": "not_a_boolean"
                    }
                ]
            }
            """,
        ]

        for invalidJson in invalidJsons {
            XCTAssertThrowsError(try decode(invalidJson), "Should throw error for invalid data type")
        }
    }

    // MARK: - JSON Encoding Tests

    func testEncodingWithCompletePaymentMethod() throws {
        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "pm_encode_test",
                    "approval_url": "https://gr4vy.app/redirect/12345",
                    "country": "US",
                    "currency": "USD",
                    "details": {
                        "bin": "424242",
                        "card_type": "credit",
                        "card_issuer_name": "Chase Bank"
                    },
                    "expiration_date": "12/30",
                    "fingerprint": "fp_abc123",
                    "label": "****4242",
                    "last_replaced_at": "2024-01-15T10:30:00Z",
                    "method": "card",
                    "mode": "card",
                    "scheme": "visa",
                    "merchant_account_id": "ma_987654321",
                    "additional_schemes": ["visa", "electron"],
                    "cit_last_used_at": "2024-02-01T14:20:00Z",
                    "cit_usage_count": 5,
                    "has_replacement": false,
                    "last_used_at": "2024-02-15T09:45:00Z",
                    "usage_count": 12
                }
            ]
        }
        """

        let originalResponse = try decode(json)
        let encodedJson = try encode(originalResponse)
        let decodedResponse = try decode(encodedJson)

        // Verify round-trip encoding/decoding
        XCTAssertEqual(originalResponse.items.count, decodedResponse.items.count)

        let originalPM = originalResponse.items[0]
        let decodedPM = decodedResponse.items[0]

        XCTAssertEqual(originalPM.type, decodedPM.type)
        XCTAssertEqual(originalPM.id, decodedPM.id)
        XCTAssertEqual(originalPM.approvalURL, decodedPM.approvalURL)
        XCTAssertEqual(originalPM.country, decodedPM.country)
        XCTAssertEqual(originalPM.currency, decodedPM.currency)
        XCTAssertEqual(originalPM.expirationDate, decodedPM.expirationDate)
        XCTAssertEqual(originalPM.fingerprint, decodedPM.fingerprint)
        XCTAssertEqual(originalPM.label, decodedPM.label)
        XCTAssertEqual(originalPM.lastReplacedAt, decodedPM.lastReplacedAt)
        XCTAssertEqual(originalPM.method, decodedPM.method)
        XCTAssertEqual(originalPM.mode, decodedPM.mode)
        XCTAssertEqual(originalPM.scheme, decodedPM.scheme)
        XCTAssertEqual(originalPM.merchantAccountId, decodedPM.merchantAccountId)
        XCTAssertEqual(originalPM.additionalSchemes, decodedPM.additionalSchemes)
        XCTAssertEqual(originalPM.citLastUsedAt, decodedPM.citLastUsedAt)
        XCTAssertEqual(originalPM.citUsageCount, decodedPM.citUsageCount)
        XCTAssertEqual(originalPM.hasReplacement, decodedPM.hasReplacement)
        XCTAssertEqual(originalPM.lastUsedAt, decodedPM.lastUsedAt)
        XCTAssertEqual(originalPM.usageCount, decodedPM.usageCount)

        // Verify details
        let originalDetails = originalPM.details
        let decodedDetails = decodedPM.details
        XCTAssertEqual(originalDetails?.bin, decodedDetails?.bin)
        XCTAssertEqual(originalDetails?.cardType, decodedDetails?.cardType)
        XCTAssertEqual(originalDetails?.cardIssuerName, decodedDetails?.cardIssuerName)
    }

    func testEncodingWithMinimalPaymentMethod() throws {
        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "pm_minimal"
                }
            ]
        }
        """

        let originalResponse = try decode(json)
        let encodedJson = try encode(originalResponse)
        let decodedResponse = try decode(encodedJson)

        XCTAssertEqual(originalResponse.items.count, decodedResponse.items.count)
        XCTAssertEqual(originalResponse.items[0].type, decodedResponse.items[0].type)
        XCTAssertEqual(originalResponse.items[0].id, decodedResponse.items[0].id)
        XCTAssertNil(decodedResponse.items[0].approvalURL)
        XCTAssertNil(decodedResponse.items[0].country)
        XCTAssertNil(decodedResponse.items[0].details)
    }

    func testEncodingUsesCorrectCodingKeys() throws {
        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "pm_coding_keys",
                    "approval_url": "https://example.com",
                    "expiration_date": "12/25",
                    "last_replaced_at": "2024-01-01T00:00:00Z",
                    "merchant_account_id": "ma_123",
                    "additional_schemes": ["visa"],
                    "cit_last_used_at": "2024-01-01T00:00:00Z",
                    "cit_usage_count": 1,
                    "has_replacement": true,
                    "last_used_at": "2024-01-01T00:00:00Z",
                    "usage_count": 5,
                    "details": {
                        "card_type": "credit",
                        "card_issuer_name": "Bank"
                    }
                }
            ]
        }
        """

        let response = try decode(json)
        let encodedJson = try encode(response)

        // Verify that the encoded JSON uses snake_case keys
        XCTAssertTrue(encodedJson.contains("\"approval_url\""))
        XCTAssertTrue(encodedJson.contains("\"expiration_date\""))
        XCTAssertTrue(encodedJson.contains("\"last_replaced_at\""))
        XCTAssertTrue(encodedJson.contains("\"merchant_account_id\""))
        XCTAssertTrue(encodedJson.contains("\"additional_schemes\""))
        XCTAssertTrue(encodedJson.contains("\"cit_last_used_at\""))
        XCTAssertTrue(encodedJson.contains("\"cit_usage_count\""))
        XCTAssertTrue(encodedJson.contains("\"has_replacement\""))
        XCTAssertTrue(encodedJson.contains("\"last_used_at\""))
        XCTAssertTrue(encodedJson.contains("\"usage_count\""))
        XCTAssertTrue(encodedJson.contains("\"card_type\""))
        XCTAssertTrue(encodedJson.contains("\"card_issuer_name\""))

        // Verify that camelCase keys are NOT used
        XCTAssertFalse(encodedJson.contains("\"approvalURL\""))
        XCTAssertFalse(encodedJson.contains("\"expirationDate\""))
        XCTAssertFalse(encodedJson.contains("\"lastReplacedAt\""))
        XCTAssertFalse(encodedJson.contains("\"merchantAccountId\""))
        XCTAssertFalse(encodedJson.contains("\"additionalSchemes\""))
        XCTAssertFalse(encodedJson.contains("\"citLastUsedAt\""))
        XCTAssertFalse(encodedJson.contains("\"citUsageCount\""))
        XCTAssertFalse(encodedJson.contains("\"hasReplacement\""))
        XCTAssertFalse(encodedJson.contains("\"lastUsedAt\""))
        XCTAssertFalse(encodedJson.contains("\"usageCount\""))
        XCTAssertFalse(encodedJson.contains("\"cardType\""))
        XCTAssertFalse(encodedJson.contains("\"cardIssuerName\""))
    }

    // MARK: - Edge Cases Tests

    func testDecodingWithEmptyStrings() throws {
        let json = """
        {
            "items": [
                {
                    "type": "",
                    "id": "",
                    "country": "",
                    "currency": "",
                    "expiration_date": "",
                    "fingerprint": "",
                    "label": "",
                    "last_replaced_at": "",
                    "method": "",
                    "mode": "",
                    "scheme": "",
                    "merchant_account_id": "",
                    "cit_last_used_at": "",
                    "last_used_at": "",
                    "details": {
                        "bin": "",
                        "card_type": "",
                        "card_issuer_name": ""
                    }
                }
            ]
        }
        """

        let response = try decode(json)

        let paymentMethod = response.items[0]
        XCTAssertEqual(paymentMethod.type, "")
        XCTAssertEqual(paymentMethod.id, "")
        XCTAssertEqual(paymentMethod.country, "")
        XCTAssertEqual(paymentMethod.currency, "")
        XCTAssertEqual(paymentMethod.expirationDate, "")
        XCTAssertEqual(paymentMethod.fingerprint, "")
        XCTAssertEqual(paymentMethod.label, "")
        XCTAssertEqual(paymentMethod.lastReplacedAt, "")
        XCTAssertEqual(paymentMethod.method, "")
        XCTAssertEqual(paymentMethod.mode, "")
        XCTAssertEqual(paymentMethod.scheme, "")
        XCTAssertEqual(paymentMethod.merchantAccountId, "")
        XCTAssertEqual(paymentMethod.citLastUsedAt, "")
        XCTAssertEqual(paymentMethod.lastUsedAt, "")

        let details = try XCTUnwrap(paymentMethod.details)
        XCTAssertEqual(details.bin, "")
        XCTAssertEqual(details.cardType, "")
        XCTAssertEqual(details.cardIssuerName, "")
    }

    func testDecodingWithSpecialCharacters() throws {
        let json = """
        {
            "items": [
                {
                    "type": "payment-method/v2",
                    "id": "pm_test-123_456",
                    "country": "US/CA",
                    "currency": "USD+EUR",
                    "label": "****4242 (Primary)",
                    "method": "card+digital",
                    "scheme": "visa/electron"
                }
            ]
        }
        """

        let response = try decode(json)

        let paymentMethod = response.items[0]
        XCTAssertEqual(paymentMethod.type, "payment-method/v2")
        XCTAssertEqual(paymentMethod.id, "pm_test-123_456")
        XCTAssertEqual(paymentMethod.country, "US/CA")
        XCTAssertEqual(paymentMethod.currency, "USD+EUR")
        XCTAssertEqual(paymentMethod.label, "****4242 (Primary)")
        XCTAssertEqual(paymentMethod.method, "card+digital")
        XCTAssertEqual(paymentMethod.scheme, "visa/electron")
    }

    func testDecodingWithUnicodeCharacters() throws {
        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "pm_测试",
                    "country": "🇺🇸",
                    "currency": "USD",
                    "label": "****4242 カード",
                    "details": {
                        "card_issuer_name": "Chase Bank™"
                    }
                }
            ]
        }
        """

        let response = try decode(json)

        let paymentMethod = response.items[0]
        XCTAssertEqual(paymentMethod.type, "payment-method")
        XCTAssertEqual(paymentMethod.id, "pm_测试")
        XCTAssertEqual(paymentMethod.country, "🇺🇸")
        XCTAssertEqual(paymentMethod.currency, "USD")
        XCTAssertEqual(paymentMethod.label, "****4242 カード")
        XCTAssertEqual(paymentMethod.details?.cardIssuerName, "Chase Bank™")
    }

    func testDecodingWithVeryLongStrings() throws {
        let longString = String(repeating: "a", count: 1_000)
        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "\(longString)",
                    "label": "\(longString)",
                    "fingerprint": "\(longString)"
                }
            ]
        }
        """

        let response = try decode(json)

        let paymentMethod = response.items[0]
        XCTAssertEqual(paymentMethod.type, "payment-method")
        XCTAssertEqual(paymentMethod.id, longString)
        XCTAssertEqual(paymentMethod.label, longString)
        XCTAssertEqual(paymentMethod.fingerprint, longString)
    }

    func testDecodingWithVariousURLFormats() throws {
        let validURLTestCases = [
            "https://gr4vy.app/redirect/12345",
            "http://example.com/approval",
            "https://secure.payment.com/redirect?token=abc123",
        ]

        for urlString in validURLTestCases {
            let json = """
            {
                "items": [
                    {
                        "type": "payment-method",
                        "id": "pm_url_test",
                        "approval_url": "\(urlString)"
                    }
                ]
            }
            """

            let response = try decode(json)
            let paymentMethod = response.items[0]
            XCTAssertNotNil(paymentMethod.approvalURL, "URL should be valid: \(urlString)")
            XCTAssertEqual(paymentMethod.approvalURL?.absoluteString, urlString)
        }
    }

    func testDecodingWithExtremeNumericValues() throws {
        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "pm_extreme_values",
                    "cit_usage_count": 0,
                    "usage_count": 999999
                }
            ]
        }
        """

        let response = try decode(json)

        let paymentMethod = response.items[0]
        XCTAssertEqual(paymentMethod.citUsageCount, 0)
        XCTAssertEqual(paymentMethod.usageCount, 999_999)
    }

    func testDecodingWithBooleanValues() throws {
        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "pm_boolean_test",
                    "has_replacement": true
                },
                {
                    "type": "payment-method",
                    "id": "pm_boolean_test2",
                    "has_replacement": false
                }
            ]
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.items[0].hasReplacement, true)
        XCTAssertEqual(response.items[1].hasReplacement, false)
    }

    func testDecodingWithEmptyArrays() throws {
        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "pm_empty_arrays",
                    "additional_schemes": []
                }
            ]
        }
        """

        let response = try decode(json)

        let paymentMethod = response.items[0]
        XCTAssertEqual(paymentMethod.additionalSchemes, [])
    }

    func testDecodingWithLargeArrays() throws {
        let schemes = Array(repeating: "visa", count: 100)
        let schemesJson = schemes.map { "\"\($0)\"" }.joined(separator: ", ")

        let json = """
        {
            "items": [
                {
                    "type": "payment-method",
                    "id": "pm_large_arrays",
                    "additional_schemes": [\(schemesJson)]
                }
            ]
        }
        """

        let response = try decode(json)

        let paymentMethod = response.items[0]
        XCTAssertEqual(paymentMethod.additionalSchemes?.count, 100)
        XCTAssertEqual(paymentMethod.additionalSchemes?.first, "visa")
    }

    // MARK: - Complex Scenarios Tests

    func testRoundTripEncodingDecodingWithVariousCombinations() throws {
        let testCases: [(String, String)] = [
            ("empty_items", """
            {
                "items": []
            }
            """),
            ("minimal_payment_method", """
            {
                "items": [
                    {
                        "type": "payment-method",
                        "id": "pm_minimal"
                    }
                ]
            }
            """),
            ("with_details_only", """
            {
                "items": [
                    {
                        "type": "payment-method",
                        "id": "pm_details",
                        "details": {
                            "bin": "424242",
                            "card_type": "credit"
                        }
                    }
                ]
            }
            """),
            ("with_url_and_dates", """
            {
                "items": [
                    {
                        "type": "payment-method",
                        "id": "pm_url_dates",
                        "approval_url": "https://example.com",
                        "expiration_date": "12/25",
                        "last_replaced_at": "2024-01-01T00:00:00Z",
                        "cit_last_used_at": "2024-01-01T00:00:00Z",
                        "last_used_at": "2024-01-01T00:00:00Z"
                    }
                ]
            }
            """),
            ("with_numbers_and_booleans", """
            {
                "items": [
                    {
                        "type": "payment-method",
                        "id": "pm_numbers_booleans",
                        "cit_usage_count": 10,
                        "usage_count": 25,
                        "has_replacement": true
                    }
                ]
            }
            """),
            ("with_arrays", """
            {
                "items": [
                    {
                        "type": "payment-method",
                        "id": "pm_arrays",
                        "additional_schemes": ["visa", "mastercard", "amex"]
                    }
                ]
            }
            """),
            ("complete_payment_method", """
            {
                "items": [
                    {
                        "type": "payment-method",
                        "id": "pm_complete",
                        "approval_url": "https://gr4vy.app/redirect/12345",
                        "country": "US",
                        "currency": "USD",
                        "details": {
                            "bin": "424242",
                            "card_type": "credit",
                            "card_issuer_name": "Chase Bank"
                        },
                        "expiration_date": "12/30",
                        "fingerprint": "fp_abc123",
                        "label": "****4242",
                        "last_replaced_at": "2024-01-15T10:30:00Z",
                        "method": "card",
                        "mode": "card",
                        "scheme": "visa",
                        "merchant_account_id": "ma_987654321",
                        "additional_schemes": ["visa", "electron"],
                        "cit_last_used_at": "2024-02-01T14:20:00Z",
                        "cit_usage_count": 5,
                        "has_replacement": false,
                        "last_used_at": "2024-02-15T09:45:00Z",
                        "usage_count": 12
                    }
                ]
            }
            """),
        ]

        for (testName, jsonString) in testCases {
            let originalResponse = try decode(jsonString)
            let encodedJson = try encode(originalResponse)
            let decodedResponse = try decode(encodedJson)

            XCTAssertEqual(originalResponse.items.count, decodedResponse.items.count, "Failed for test case: \(testName)")

            for (index, (originalPM, decodedPM)) in zip(originalResponse.items, decodedResponse.items).enumerated() {
                XCTAssertEqual(originalPM.type, decodedPM.type, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.id, decodedPM.id, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.approvalURL, decodedPM.approvalURL, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.country, decodedPM.country, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.currency, decodedPM.currency, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.expirationDate, decodedPM.expirationDate, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.fingerprint, decodedPM.fingerprint, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.label, decodedPM.label, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.lastReplacedAt, decodedPM.lastReplacedAt, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.method, decodedPM.method, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.mode, decodedPM.mode, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.scheme, decodedPM.scheme, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.merchantAccountId, decodedPM.merchantAccountId, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.additionalSchemes, decodedPM.additionalSchemes, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.citLastUsedAt, decodedPM.citLastUsedAt, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.citUsageCount, decodedPM.citUsageCount, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.hasReplacement, decodedPM.hasReplacement, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.lastUsedAt, decodedPM.lastUsedAt, "Failed for test case: \(testName), item \(index)")
                XCTAssertEqual(originalPM.usageCount, decodedPM.usageCount, "Failed for test case: \(testName), item \(index)")

                // Compare details if present
                if let originalDetails = originalPM.details,
                   let decodedDetails = decodedPM.details {
                    XCTAssertEqual(originalDetails.bin, decodedDetails.bin, "Failed for test case: \(testName), item \(index)")
                    XCTAssertEqual(originalDetails.cardType, decodedDetails.cardType, "Failed for test case: \(testName), item \(index)")
                    XCTAssertEqual(originalDetails.cardIssuerName, decodedDetails.cardIssuerName, "Failed for test case: \(testName), item \(index)")
                } else {
                    XCTAssertNil(originalPM.details, "Failed for test case: \(testName), item \(index)")
                    XCTAssertNil(decodedPM.details, "Failed for test case: \(testName), item \(index)")
                }
            }
        }
    }

    func testInvalidJSONStructures() {
        let invalidJsons = [
            "invalid json",
            "[]",
            "null",
            "{\"items\": null}",
            "{\"items\": \"not_an_array\"}",
            "{\"items\": [\"not_an_object\"]}",
            // Note: {"items": [{"type": null}]} is now valid since type is optional
            "{\"items\": [{\"id\": 123}]}",
            "{\"items\": [{\"type\": \"payment-method\", \"id\": \"pm_123\", \"details\": \"not_an_object\"}]}",
        ]

        for invalidJson in invalidJsons {
            XCTAssertThrowsError(try decode(invalidJson), "Should throw error for: \(invalidJson)")
        }
    }
}
