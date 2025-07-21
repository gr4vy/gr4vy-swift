//
//  Gr4vyCardDetailsResponseTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyCardDetailsResponseTests: XCTestCase {
    // MARK: - Helpers
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private func decode(_ json: String) throws -> Gr4vyCardDetailsResponse {
        try decoder.decode(Gr4vyCardDetailsResponse.self, from: Data(json.utf8))
    }

    private func encode(_ response: Gr4vyCardDetailsResponse) throws -> String {
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

    func testDecodingWithAllFields() throws {
        let json = """
        {
            "type": "card_details",
            "id": "cd_123456789",
            "card_type": "credit",
            "scheme": "visa",
            "scheme_icon_url": "https://example.com/visa.png",
            "country": "US",
            "required_fields": {
                "first_name": true,
                "last_name": true,
                "email_address": false,
                "phone_number": true,
                "tax_id": false,
                "address": {
                    "city": true,
                    "country": false,
                    "postal_code": true,
                    "state": true,
                    "house_number_or_name": false,
                    "line1": true
                }
            }
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.type, "card_details")
        XCTAssertEqual(response.id, "cd_123456789")
        XCTAssertEqual(response.cardType, "credit")
        XCTAssertEqual(response.scheme, "visa")
        XCTAssertEqual(response.schemeIconURL?.absoluteString, "https://example.com/visa.png")
        XCTAssertEqual(response.country, "US")

        // Test required fields
        let requiredFields = try XCTUnwrap(response.requiredFields)
        XCTAssertEqual(requiredFields.firstName, true)
        XCTAssertEqual(requiredFields.lastName, true)
        XCTAssertEqual(requiredFields.emailAddress, false)
        XCTAssertEqual(requiredFields.phoneNumber, true)
        XCTAssertEqual(requiredFields.taxId, false)

        // Test address
        let address = try XCTUnwrap(requiredFields.address)
        XCTAssertEqual(address.city, true)
        XCTAssertEqual(address.country, false)
        XCTAssertEqual(address.postalCode, true)
        XCTAssertEqual(address.state, true)
        XCTAssertEqual(address.houseNumberOrName, false)
        XCTAssertEqual(address.line1, true)
    }

    func testDecodingWithOnlyRequiredFields() throws {
        let json = """
        {
            "type": "card_details",
            "id": "cd_987654321",
            "card_type": "debit",
            "scheme": "mastercard"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.type, "card_details")
        XCTAssertEqual(response.id, "cd_987654321")
        XCTAssertEqual(response.cardType, "debit")
        XCTAssertEqual(response.scheme, "mastercard")
        XCTAssertNil(response.schemeIconURL)
        XCTAssertNil(response.country)
        XCTAssertNil(response.requiredFields)
    }

    func testDecodingWithPartialRequiredFields() throws {
        let json = """
        {
            "type": "card_details",
            "id": "cd_555666777",
            "card_type": "credit",
            "scheme": "amex",
            "country": "GB",
            "required_fields": {
                "first_name": true,
                "email_address": false
            }
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.type, "card_details")
        XCTAssertEqual(response.id, "cd_555666777")
        XCTAssertEqual(response.cardType, "credit")
        XCTAssertEqual(response.scheme, "amex")
        XCTAssertNil(response.schemeIconURL)
        XCTAssertEqual(response.country, "GB")

        let requiredFields = try XCTUnwrap(response.requiredFields)
        XCTAssertEqual(requiredFields.firstName, true)
        XCTAssertNil(requiredFields.lastName)
        XCTAssertEqual(requiredFields.emailAddress, false)
        XCTAssertNil(requiredFields.phoneNumber)
        XCTAssertNil(requiredFields.address)
        XCTAssertNil(requiredFields.taxId)
    }

    func testDecodingWithPartialAddressFields() throws {
        let json = """
        {
            "type": "card_details",
            "id": "cd_111222333",
            "card_type": "prepaid",
            "scheme": "discover",
            "required_fields": {
                "address": {
                    "city": true,
                    "postal_code": false,
                    "line1": true
                }
            }
        }
        """

        let response = try decode(json)

        let requiredFields = try XCTUnwrap(response.requiredFields)
        let address = try XCTUnwrap(requiredFields.address)

        XCTAssertEqual(address.city, true)
        XCTAssertNil(address.country)
        XCTAssertEqual(address.postalCode, false)
        XCTAssertNil(address.state)
        XCTAssertNil(address.houseNumberOrName)
        XCTAssertEqual(address.line1, true)
    }

    func testDecodingWithNullValues() throws {
        let json = """
        {
            "type": "card_details",
            "id": "cd_null_test",
            "card_type": "credit",
            "scheme": "visa",
            "scheme_icon_url": null,
            "country": null,
            "required_fields": null
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.type, "card_details")
        XCTAssertEqual(response.id, "cd_null_test")
        XCTAssertEqual(response.cardType, "credit")
        XCTAssertEqual(response.scheme, "visa")
        XCTAssertNil(response.schemeIconURL)
        XCTAssertNil(response.country)
        XCTAssertNil(response.requiredFields)
    }

    func testDecodingFailsWithMissingRequiredFields() {
        let invalidJsons = [
            // Missing type
            """
            {
                "id": "cd_123",
                "card_type": "credit",
                "scheme": "visa"
            }
            """,
            // Missing id
            """
            {
                "type": "card_details",
                "card_type": "credit",
                "scheme": "visa"
            }
            """,
            // Missing card_type
            """
            {
                "type": "card_details",
                "id": "cd_123",
                "scheme": "visa"
            }
            """,
            // Missing scheme
            """
            {
                "type": "card_details",
                "id": "cd_123",
                "card_type": "credit"
            }
            """,
        ]

        for invalidJson in invalidJsons {
            XCTAssertThrowsError(try decode(invalidJson), "Should throw error for missing required field")
        }
    }

    func testDecodingFailsWithInvalidDataTypes() {
        let invalidJsons = [
            // Invalid type (number instead of string)
            """
            {
                "type": 123,
                "id": "cd_123",
                "card_type": "credit",
                "scheme": "visa"
            }
            """,
            // Invalid boolean in required fields
            """
            {
                "type": "card_details",
                "id": "cd_123",
                "card_type": "credit",
                "scheme": "visa",
                "required_fields": {
                    "first_name": "not_a_boolean"
                }
            }
            """,
            // Invalid boolean in address
            """
            {
                "type": "card_details",
                "id": "cd_123",
                "card_type": "credit",
                "scheme": "visa",
                "required_fields": {
                    "address": {
                        "city": "not_a_boolean"
                    }
                }
            }
            """,
        ]

        for invalidJson in invalidJsons {
            XCTAssertThrowsError(try decode(invalidJson), "Should throw error for invalid data type")
        }
    }

    // MARK: - JSON Encoding Tests

    func testEncodingWithAllFields() throws {
        // Since Gr4vyCardDetailsResponse doesn't have a public initializer,
        // we need to test encoding through round-trip decoding first
        let json = """
        {
            "type": "card_details",
            "id": "cd_encode_test",
            "card_type": "credit",
            "scheme": "visa",
            "scheme_icon_url": "https://example.com/visa.png",
            "country": "US",
            "required_fields": {
                "first_name": true,
                "last_name": true,
                "email_address": false,
                "phone_number": true,
                "tax_id": false,
                "address": {
                    "city": true,
                    "country": false,
                    "postal_code": true,
                    "state": true,
                    "house_number_or_name": false,
                    "line1": true
                }
            }
        }
        """

        let originalResponse = try decode(json)
        let encodedJson = try encode(originalResponse)
        let decodedResponse = try decode(encodedJson)

        // Verify round-trip encoding/decoding
        XCTAssertEqual(originalResponse.type, decodedResponse.type)
        XCTAssertEqual(originalResponse.id, decodedResponse.id)
        XCTAssertEqual(originalResponse.cardType, decodedResponse.cardType)
        XCTAssertEqual(originalResponse.scheme, decodedResponse.scheme)
        XCTAssertEqual(originalResponse.schemeIconURL, decodedResponse.schemeIconURL)
        XCTAssertEqual(originalResponse.country, decodedResponse.country)

        // Verify required fields
        let originalReqFields = originalResponse.requiredFields
        let decodedReqFields = decodedResponse.requiredFields
        XCTAssertEqual(originalReqFields?.firstName, decodedReqFields?.firstName)
        XCTAssertEqual(originalReqFields?.lastName, decodedReqFields?.lastName)
        XCTAssertEqual(originalReqFields?.emailAddress, decodedReqFields?.emailAddress)
        XCTAssertEqual(originalReqFields?.phoneNumber, decodedReqFields?.phoneNumber)
        XCTAssertEqual(originalReqFields?.taxId, decodedReqFields?.taxId)

        // Verify address
        let originalAddress = originalReqFields?.address
        let decodedAddress = decodedReqFields?.address
        XCTAssertEqual(originalAddress?.city, decodedAddress?.city)
        XCTAssertEqual(originalAddress?.country, decodedAddress?.country)
        XCTAssertEqual(originalAddress?.postalCode, decodedAddress?.postalCode)
        XCTAssertEqual(originalAddress?.state, decodedAddress?.state)
        XCTAssertEqual(originalAddress?.houseNumberOrName, decodedAddress?.houseNumberOrName)
        XCTAssertEqual(originalAddress?.line1, decodedAddress?.line1)
    }

    func testEncodingWithOnlyRequiredFields() throws {
        let json = """
        {
            "type": "card_details",
            "id": "cd_minimal",
            "card_type": "debit",
            "scheme": "mastercard"
        }
        """

        let originalResponse = try decode(json)
        let encodedJson = try encode(originalResponse)
        let decodedResponse = try decode(encodedJson)

        XCTAssertEqual(originalResponse.type, decodedResponse.type)
        XCTAssertEqual(originalResponse.id, decodedResponse.id)
        XCTAssertEqual(originalResponse.cardType, decodedResponse.cardType)
        XCTAssertEqual(originalResponse.scheme, decodedResponse.scheme)
        XCTAssertNil(decodedResponse.schemeIconURL)
        XCTAssertNil(decodedResponse.country)
        XCTAssertNil(decodedResponse.requiredFields)
    }

    func testEncodingUsesCorrectCodingKeys() throws {
        let json = """
        {
            "type": "card_details",
            "id": "cd_coding_keys",
            "card_type": "credit",
            "scheme": "visa",
            "scheme_icon_url": "https://example.com/icon.png",
            "required_fields": {
                "first_name": true,
                "email_address": false,
                "address": {
                    "postal_code": true,
                    "house_number_or_name": false
                }
            }
        }
        """

        let response = try decode(json)
        let encodedJson = try encode(response)

        // Verify that the encoded JSON uses snake_case keys
        XCTAssertTrue(encodedJson.contains("\"card_type\""))
        XCTAssertTrue(encodedJson.contains("\"scheme_icon_url\""))
        XCTAssertTrue(encodedJson.contains("\"required_fields\""))
        XCTAssertTrue(encodedJson.contains("\"first_name\""))
        XCTAssertTrue(encodedJson.contains("\"email_address\""))
        XCTAssertTrue(encodedJson.contains("\"postal_code\""))
        XCTAssertTrue(encodedJson.contains("\"house_number_or_name\""))

        // Verify that camelCase keys are NOT used
        XCTAssertFalse(encodedJson.contains("\"cardType\""))
        XCTAssertFalse(encodedJson.contains("\"schemeIconURL\""))
        XCTAssertFalse(encodedJson.contains("\"requiredFields\""))
        XCTAssertFalse(encodedJson.contains("\"firstName\""))
        XCTAssertFalse(encodedJson.contains("\"emailAddress\""))
        XCTAssertFalse(encodedJson.contains("\"postalCode\""))
        XCTAssertFalse(encodedJson.contains("\"houseNumberOrName\""))
    }

    // MARK: - Edge Cases Tests

    func testDecodingWithEmptyStrings() throws {
        let json = """
        {
            "type": "",
            "id": "",
            "card_type": "",
            "scheme": "",
            "country": ""
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.type, "")
        XCTAssertEqual(response.id, "")
        XCTAssertEqual(response.cardType, "")
        XCTAssertEqual(response.scheme, "")
        XCTAssertEqual(response.country, "")
    }

    func testDecodingWithSpecialCharacters() throws {
        let json = """
        {
            "type": "card-details/v1",
            "id": "cd_test-123_456",
            "card_type": "credit+premium",
            "scheme": "visa/electron",
            "country": "US/CA"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.type, "card-details/v1")
        XCTAssertEqual(response.id, "cd_test-123_456")
        XCTAssertEqual(response.cardType, "credit+premium")
        XCTAssertEqual(response.scheme, "visa/electron")
        XCTAssertEqual(response.country, "US/CA")
    }

    func testDecodingWithUnicodeCharacters() throws {
        let json = """
        {
            "type": "card_details",
            "id": "cd_测试",
            "card_type": "クレジット",
            "scheme": "visa",
            "country": "🇺🇸"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.type, "card_details")
        XCTAssertEqual(response.id, "cd_测试")
        XCTAssertEqual(response.cardType, "クレジット")
        XCTAssertEqual(response.scheme, "visa")
        XCTAssertEqual(response.country, "🇺🇸")
    }

    func testDecodingWithVeryLongStrings() throws {
        let longString = String(repeating: "a", count: 1_000)
        let json = """
        {
            "type": "card_details",
            "id": "\(longString)",
            "card_type": "credit",
            "scheme": "visa"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.type, "card_details")
        XCTAssertEqual(response.id, longString)
        XCTAssertEqual(response.cardType, "credit")
        XCTAssertEqual(response.scheme, "visa")
    }

    func testDecodingWithVariousURLFormats() throws {
        // Test valid URLs
        let validURLTestCases = [
            "https://example.com/icon.png",
            "http://example.com/icon.png",
            "ftp://example.com/icon.png",
        ]

        for urlString in validURLTestCases {
            let json = """
            {
                "type": "card_details",
                "id": "cd_url_test",
                "card_type": "credit",
                "scheme": "visa",
                "scheme_icon_url": "\(urlString)"
            }
            """

            let response = try decode(json)
            XCTAssertNotNil(response.schemeIconURL, "URL should be valid: \(urlString)")
            XCTAssertEqual(response.schemeIconURL?.absoluteString, urlString)
        }
    }

    func testDecodingWithComplexNestedStructure() throws {
        let json = """
        {
            "type": "card_details",
            "id": "cd_complex_test",
            "card_type": "credit",
            "scheme": "visa",
            "scheme_icon_url": "https://example.com/visa.png",
            "country": "US",
            "required_fields": {
                "first_name": true,
                "last_name": false,
                "email_address": true,
                "phone_number": false,
                "tax_id": true,
                "address": {
                    "city": false,
                    "country": true,
                    "postal_code": false,
                    "state": true,
                    "house_number_or_name": true,
                    "line1": false
                }
            }
        }
        """

        let response = try decode(json)

        // Test all levels of nesting
        XCTAssertEqual(response.type, "card_details")
        XCTAssertEqual(response.id, "cd_complex_test")

        let reqFields = try XCTUnwrap(response.requiredFields)
        XCTAssertEqual(reqFields.firstName, true)
        XCTAssertEqual(reqFields.lastName, false)
        XCTAssertEqual(reqFields.emailAddress, true)
        XCTAssertEqual(reqFields.phoneNumber, false)
        XCTAssertEqual(reqFields.taxId, true)

        let address = try XCTUnwrap(reqFields.address)
        XCTAssertEqual(address.city, false)
        XCTAssertEqual(address.country, true)
        XCTAssertEqual(address.postalCode, false)
        XCTAssertEqual(address.state, true)
        XCTAssertEqual(address.houseNumberOrName, true)
        XCTAssertEqual(address.line1, false)
    }

    // MARK: - Complex Scenarios Tests

    func testRoundTripEncodingDecodingWithVariousCombinations() throws {
        let testCases: [(String, String)] = [
            ("minimal", """
            {
                "type": "card_details",
                "id": "cd_minimal",
                "card_type": "debit",
                "scheme": "mastercard"
            }
            """),
            ("with_optional_fields", """
            {
                "type": "card_details",
                "id": "cd_optional",
                "card_type": "credit",
                "scheme": "visa",
                "country": "GB"
            }
            """),
            ("with_url", """
            {
                "type": "card_details",
                "id": "cd_url",
                "card_type": "credit",
                "scheme": "amex",
                "scheme_icon_url": "https://example.com/amex.png"
            }
            """),
            ("with_required_fields_only", """
            {
                "type": "card_details",
                "id": "cd_req_fields",
                "card_type": "prepaid",
                "scheme": "discover",
                "required_fields": {
                    "first_name": true,
                    "email_address": false
                }
            }
            """),
            ("with_address_only", """
            {
                "type": "card_details",
                "id": "cd_address",
                "card_type": "credit",
                "scheme": "visa",
                "required_fields": {
                    "address": {
                        "city": true,
                        "postal_code": false
                    }
                }
            }
            """),
            ("complete", """
            {
                "type": "card_details",
                "id": "cd_complete",
                "card_type": "credit",
                "scheme": "visa",
                "scheme_icon_url": "https://example.com/visa.png",
                "country": "US",
                "required_fields": {
                    "first_name": true,
                    "last_name": false,
                    "email_address": true,
                    "phone_number": false,
                    "tax_id": true,
                    "address": {
                        "city": false,
                        "country": true,
                        "postal_code": false,
                        "state": true,
                        "house_number_or_name": true,
                        "line1": false
                    }
                }
            }
            """),
        ]

        for (testName, jsonString) in testCases {
            let originalResponse = try decode(jsonString)
            let encodedJson = try encode(originalResponse)
            let decodedResponse = try decode(encodedJson)

            XCTAssertEqual(originalResponse.type, decodedResponse.type, "Failed for test case: \(testName)")
            XCTAssertEqual(originalResponse.id, decodedResponse.id, "Failed for test case: \(testName)")
            XCTAssertEqual(originalResponse.cardType, decodedResponse.cardType, "Failed for test case: \(testName)")
            XCTAssertEqual(originalResponse.scheme, decodedResponse.scheme, "Failed for test case: \(testName)")
            XCTAssertEqual(originalResponse.schemeIconURL, decodedResponse.schemeIconURL, "Failed for test case: \(testName)")
            XCTAssertEqual(originalResponse.country, decodedResponse.country, "Failed for test case: \(testName)")

            // Compare required fields if present
            if let originalReqFields = originalResponse.requiredFields,
               let decodedReqFields = decodedResponse.requiredFields {
                XCTAssertEqual(originalReqFields.firstName, decodedReqFields.firstName, "Failed for test case: \(testName)")
                XCTAssertEqual(originalReqFields.lastName, decodedReqFields.lastName, "Failed for test case: \(testName)")
                XCTAssertEqual(originalReqFields.emailAddress, decodedReqFields.emailAddress, "Failed for test case: \(testName)")
                XCTAssertEqual(originalReqFields.phoneNumber, decodedReqFields.phoneNumber, "Failed for test case: \(testName)")
                XCTAssertEqual(originalReqFields.taxId, decodedReqFields.taxId, "Failed for test case: \(testName)")

                // Compare address if present
                if let originalAddress = originalReqFields.address,
                   let decodedAddress = decodedReqFields.address {
                    XCTAssertEqual(originalAddress.city, decodedAddress.city, "Failed for test case: \(testName)")
                    XCTAssertEqual(originalAddress.country, decodedAddress.country, "Failed for test case: \(testName)")
                    XCTAssertEqual(originalAddress.postalCode, decodedAddress.postalCode, "Failed for test case: \(testName)")
                    XCTAssertEqual(originalAddress.state, decodedAddress.state, "Failed for test case: \(testName)")
                    XCTAssertEqual(originalAddress.houseNumberOrName, decodedAddress.houseNumberOrName, "Failed for test case: \(testName)")
                    XCTAssertEqual(originalAddress.line1, decodedAddress.line1, "Failed for test case: \(testName)")
                } else {
                    XCTAssertNil(originalReqFields.address, "Failed for test case: \(testName)")
                    XCTAssertNil(decodedReqFields.address, "Failed for test case: \(testName)")
                }
            } else {
                XCTAssertNil(originalResponse.requiredFields, "Failed for test case: \(testName)")
                XCTAssertNil(decodedResponse.requiredFields, "Failed for test case: \(testName)")
            }
        }
    }

    func testInvalidJSONStructures() {
        let invalidJsons = [
            "invalid json",
            "[]",
            "null",
            "{\"type\": null}",
            "{\"type\": 123}",
            "{\"id\": 456}",
            "{\"card_type\": true}",
            "{\"scheme\": []}",
            "{\"required_fields\": \"not_an_object\"}",
        ]

        for invalidJson in invalidJsons {
            XCTAssertThrowsError(try decode(invalidJson), "Should throw error for: \(invalidJson)")
        }
    }
}
