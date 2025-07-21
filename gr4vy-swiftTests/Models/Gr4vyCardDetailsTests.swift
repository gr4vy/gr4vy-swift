//
//  Gr4vyCardDetailsTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyCardDetailsTests: XCTestCase {
    // MARK: - Helpers
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private func decode(_ json: String) throws -> Gr4vyCardDetails {
        try decoder.decode(Gr4vyCardDetails.self, from: Data(json.utf8))
    }

    private func encode(_ cardDetails: Gr4vyCardDetails) throws -> String {
        let data = try encoder.encode(cardDetails)
        return String(data: data, encoding: .utf8) ?? ""
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Initialization Tests

    func testInitializationWithOnlyRequiredParameter() {
        let cardDetails = Gr4vyCardDetails(currency: "USD")

        XCTAssertEqual(cardDetails.currency, "USD")
        XCTAssertNil(cardDetails.amount)
        XCTAssertNil(cardDetails.bin)
        XCTAssertNil(cardDetails.country)
        XCTAssertNil(cardDetails.intent)
        XCTAssertNil(cardDetails.isSubsequentPayment)
        XCTAssertNil(cardDetails.merchantInitiated)
        XCTAssertNil(cardDetails.metadata)
        XCTAssertNil(cardDetails.paymentMethodId)
        XCTAssertNil(cardDetails.paymentSource)
    }

    func testInitializationWithAllParameters() {
        let cardDetails = Gr4vyCardDetails(
            currency: "EUR",
            amount: "1000",
            bin: "424242",
            country: "GB",
            intent: "capture",
            isSubsequentPayment: true,
            merchantInitiated: false,
            metadata: "test-metadata",
            paymentMethodId: "pm_123",
            paymentSource: "card"
        )

        XCTAssertEqual(cardDetails.currency, "EUR")
        XCTAssertEqual(cardDetails.amount, "1000")
        XCTAssertEqual(cardDetails.bin, "424242")
        XCTAssertEqual(cardDetails.country, "GB")
        XCTAssertEqual(cardDetails.intent, "capture")
        XCTAssertEqual(cardDetails.isSubsequentPayment, true)
        XCTAssertEqual(cardDetails.merchantInitiated, false)
        XCTAssertEqual(cardDetails.metadata, "test-metadata")
        XCTAssertEqual(cardDetails.paymentMethodId, "pm_123")
        XCTAssertEqual(cardDetails.paymentSource, "card")
    }

    func testInitializationWithPartialParameters() {
        let cardDetails = Gr4vyCardDetails(
            currency: "GBP",
            amount: "500",
            country: "US",
            intent: "authorize"
        )

        XCTAssertEqual(cardDetails.currency, "GBP")
        XCTAssertEqual(cardDetails.amount, "500")
        XCTAssertNil(cardDetails.bin)
        XCTAssertEqual(cardDetails.country, "US")
        XCTAssertEqual(cardDetails.intent, "authorize")
        XCTAssertNil(cardDetails.isSubsequentPayment)
        XCTAssertNil(cardDetails.merchantInitiated)
        XCTAssertNil(cardDetails.metadata)
        XCTAssertNil(cardDetails.paymentMethodId)
        XCTAssertNil(cardDetails.paymentSource)
    }

    func testInitializationWithBooleanParameters() {
        let cardDetails1 = Gr4vyCardDetails(
            currency: "USD",
            isSubsequentPayment: true,
            merchantInitiated: true
        )

        XCTAssertEqual(cardDetails1.currency, "USD")
        XCTAssertEqual(cardDetails1.isSubsequentPayment, true)
        XCTAssertEqual(cardDetails1.merchantInitiated, true)

        let cardDetails2 = Gr4vyCardDetails(
            currency: "EUR",
            isSubsequentPayment: false,
            merchantInitiated: false
        )

        XCTAssertEqual(cardDetails2.currency, "EUR")
        XCTAssertEqual(cardDetails2.isSubsequentPayment, false)
        XCTAssertEqual(cardDetails2.merchantInitiated, false)
    }

    // MARK: - JSON Decoding Tests

    func testDecodingWithAllFields() throws {
        let json = """
        {
            "currency": "USD",
            "amount": "2000",
            "bin": "411111",
            "country": "US",
            "intent": "capture",
            "is_subsequent_payment": true,
            "merchant_initiated": false,
            "metadata": "order-123",
            "payment_method_id": "pm_456",
            "payment_source": "card"
        }
        """

        let cardDetails = try decode(json)

        XCTAssertEqual(cardDetails.currency, "USD")
        XCTAssertEqual(cardDetails.amount, "2000")
        XCTAssertEqual(cardDetails.bin, "411111")
        XCTAssertEqual(cardDetails.country, "US")
        XCTAssertEqual(cardDetails.intent, "capture")
        XCTAssertEqual(cardDetails.isSubsequentPayment, true)
        XCTAssertEqual(cardDetails.merchantInitiated, false)
        XCTAssertEqual(cardDetails.metadata, "order-123")
        XCTAssertEqual(cardDetails.paymentMethodId, "pm_456")
        XCTAssertEqual(cardDetails.paymentSource, "card")
    }

    func testDecodingWithOnlyRequiredField() throws {
        let json = """
        {
            "currency": "EUR"
        }
        """

        let cardDetails = try decode(json)

        XCTAssertEqual(cardDetails.currency, "EUR")
        XCTAssertNil(cardDetails.amount)
        XCTAssertNil(cardDetails.bin)
        XCTAssertNil(cardDetails.country)
        XCTAssertNil(cardDetails.intent)
        XCTAssertNil(cardDetails.isSubsequentPayment)
        XCTAssertNil(cardDetails.merchantInitiated)
        XCTAssertNil(cardDetails.metadata)
        XCTAssertNil(cardDetails.paymentMethodId)
        XCTAssertNil(cardDetails.paymentSource)
    }

    func testDecodingWithPartialFields() throws {
        let json = """
        {
            "currency": "GBP",
            "amount": "1500",
            "country": "GB",
            "is_subsequent_payment": false
        }
        """

        let cardDetails = try decode(json)

        XCTAssertEqual(cardDetails.currency, "GBP")
        XCTAssertEqual(cardDetails.amount, "1500")
        XCTAssertNil(cardDetails.bin)
        XCTAssertEqual(cardDetails.country, "GB")
        XCTAssertNil(cardDetails.intent)
        XCTAssertEqual(cardDetails.isSubsequentPayment, false)
        XCTAssertNil(cardDetails.merchantInitiated)
        XCTAssertNil(cardDetails.metadata)
        XCTAssertNil(cardDetails.paymentMethodId)
        XCTAssertNil(cardDetails.paymentSource)
    }

    func testDecodingWithNullValues() throws {
        let json = """
        {
            "currency": "USD",
            "amount": null,
            "bin": null,
            "country": null,
            "intent": null,
            "is_subsequent_payment": null,
            "merchant_initiated": null,
            "metadata": null,
            "payment_method_id": null,
            "payment_source": null
        }
        """

        let cardDetails = try decode(json)

        XCTAssertEqual(cardDetails.currency, "USD")
        XCTAssertNil(cardDetails.amount)
        XCTAssertNil(cardDetails.bin)
        XCTAssertNil(cardDetails.country)
        XCTAssertNil(cardDetails.intent)
        XCTAssertNil(cardDetails.isSubsequentPayment)
        XCTAssertNil(cardDetails.merchantInitiated)
        XCTAssertNil(cardDetails.metadata)
        XCTAssertNil(cardDetails.paymentMethodId)
        XCTAssertNil(cardDetails.paymentSource)
    }

    func testDecodingFailsWithMissingRequiredField() {
        let json = """
        {
            "amount": "1000",
            "country": "US"
        }
        """

        XCTAssertThrowsError(try decode(json)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testDecodingFailsWithInvalidCurrencyType() {
        let json = """
        {
            "currency": 123,
            "amount": "1000"
        }
        """

        XCTAssertThrowsError(try decode(json)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testDecodingFailsWithInvalidBooleanType() {
        let json = """
        {
            "currency": "USD",
            "is_subsequent_payment": "not_a_boolean"
        }
        """

        XCTAssertThrowsError(try decode(json)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    // MARK: - JSON Encoding Tests

    func testEncodingWithAllFields() throws {
        let cardDetails = Gr4vyCardDetails(
            currency: "USD",
            amount: "3000",
            bin: "555555",
            country: "CA",
            intent: "authorize",
            isSubsequentPayment: true,
            merchantInitiated: true,
            metadata: "test-order",
            paymentMethodId: "pm_789",
            paymentSource: "digital_wallet"
        )

        let encodedJson = try encode(cardDetails)
        let decodedCardDetails = try decode(encodedJson)

        // Verify round-trip encoding/decoding
        XCTAssertEqual(cardDetails.currency, decodedCardDetails.currency)
        XCTAssertEqual(cardDetails.amount, decodedCardDetails.amount)
        XCTAssertEqual(cardDetails.bin, decodedCardDetails.bin)
        XCTAssertEqual(cardDetails.country, decodedCardDetails.country)
        XCTAssertEqual(cardDetails.intent, decodedCardDetails.intent)
        XCTAssertEqual(cardDetails.isSubsequentPayment, decodedCardDetails.isSubsequentPayment)
        XCTAssertEqual(cardDetails.merchantInitiated, decodedCardDetails.merchantInitiated)
        XCTAssertEqual(cardDetails.metadata, decodedCardDetails.metadata)
        XCTAssertEqual(cardDetails.paymentMethodId, decodedCardDetails.paymentMethodId)
        XCTAssertEqual(cardDetails.paymentSource, decodedCardDetails.paymentSource)
    }

    func testEncodingWithOnlyRequiredField() throws {
        let cardDetails = Gr4vyCardDetails(currency: "EUR")

        let encodedJson = try encode(cardDetails)
        let decodedCardDetails = try decode(encodedJson)

        XCTAssertEqual(cardDetails.currency, decodedCardDetails.currency)
        XCTAssertEqual(cardDetails.amount, decodedCardDetails.amount)
        XCTAssertEqual(cardDetails.bin, decodedCardDetails.bin)
        XCTAssertEqual(cardDetails.country, decodedCardDetails.country)
        XCTAssertEqual(cardDetails.intent, decodedCardDetails.intent)
        XCTAssertEqual(cardDetails.isSubsequentPayment, decodedCardDetails.isSubsequentPayment)
        XCTAssertEqual(cardDetails.merchantInitiated, decodedCardDetails.merchantInitiated)
        XCTAssertEqual(cardDetails.metadata, decodedCardDetails.metadata)
        XCTAssertEqual(cardDetails.paymentMethodId, decodedCardDetails.paymentMethodId)
        XCTAssertEqual(cardDetails.paymentSource, decodedCardDetails.paymentSource)
    }

    func testEncodingWithPartialFields() throws {
        let cardDetails = Gr4vyCardDetails(
            currency: "GBP",
            amount: "750",
            country: "GB",
            isSubsequentPayment: false
        )

        let encodedJson = try encode(cardDetails)
        let decodedCardDetails = try decode(encodedJson)

        XCTAssertEqual(cardDetails.currency, decodedCardDetails.currency)
        XCTAssertEqual(cardDetails.amount, decodedCardDetails.amount)
        XCTAssertEqual(cardDetails.country, decodedCardDetails.country)
        XCTAssertEqual(cardDetails.isSubsequentPayment, decodedCardDetails.isSubsequentPayment)
        XCTAssertNil(decodedCardDetails.bin)
        XCTAssertNil(decodedCardDetails.intent)
        XCTAssertNil(decodedCardDetails.merchantInitiated)
        XCTAssertNil(decodedCardDetails.metadata)
        XCTAssertNil(decodedCardDetails.paymentMethodId)
        XCTAssertNil(decodedCardDetails.paymentSource)
    }

    func testEncodingUsesCorrectCodingKeys() throws {
        let cardDetails = Gr4vyCardDetails(
            currency: "USD",
            isSubsequentPayment: true,
            merchantInitiated: false,
            paymentMethodId: "pm_test"
        )

        let encodedJson = try encode(cardDetails)

        // Verify that the encoded JSON uses snake_case keys
        XCTAssertTrue(encodedJson.contains("\"currency\""))
        XCTAssertTrue(encodedJson.contains("\"is_subsequent_payment\""))
        XCTAssertTrue(encodedJson.contains("\"merchant_initiated\""))
        XCTAssertTrue(encodedJson.contains("\"payment_method_id\""))

        // Verify that camelCase keys are NOT used
        XCTAssertFalse(encodedJson.contains("\"isSubsequentPayment\""))
        XCTAssertFalse(encodedJson.contains("\"merchantInitiated\""))
        XCTAssertFalse(encodedJson.contains("\"paymentMethodId\""))
    }

    // MARK: - Edge Cases Tests

    func testInitializationWithEmptyStrings() {
        let cardDetails = Gr4vyCardDetails(
            currency: "",
            amount: "",
            bin: "",
            country: "",
            intent: "",
            metadata: "",
            paymentMethodId: "",
            paymentSource: ""
        )

        XCTAssertEqual(cardDetails.currency, "")
        XCTAssertEqual(cardDetails.amount, "")
        XCTAssertEqual(cardDetails.bin, "")
        XCTAssertEqual(cardDetails.country, "")
        XCTAssertEqual(cardDetails.intent, "")
        XCTAssertEqual(cardDetails.metadata, "")
        XCTAssertEqual(cardDetails.paymentMethodId, "")
        XCTAssertEqual(cardDetails.paymentSource, "")
    }

    func testInitializationWithSpecialCharacters() {
        let cardDetails = Gr4vyCardDetails(
            currency: "USD",
            amount: "1,000.50",
            bin: "4242-4242",
            country: "US/CA",
            intent: "capture&authorize",
            metadata: "order#123 @test",
            paymentMethodId: "pm_test-123_456",
            paymentSource: "card/digital_wallet"
        )

        XCTAssertEqual(cardDetails.currency, "USD")
        XCTAssertEqual(cardDetails.amount, "1,000.50")
        XCTAssertEqual(cardDetails.bin, "4242-4242")
        XCTAssertEqual(cardDetails.country, "US/CA")
        XCTAssertEqual(cardDetails.intent, "capture&authorize")
        XCTAssertEqual(cardDetails.metadata, "order#123 @test")
        XCTAssertEqual(cardDetails.paymentMethodId, "pm_test-123_456")
        XCTAssertEqual(cardDetails.paymentSource, "card/digital_wallet")
    }

    func testInitializationWithUnicodeCharacters() {
        let cardDetails = Gr4vyCardDetails(
            currency: "€UR",
            amount: "1000€",
            country: "Deutschland",
            metadata: "测试数据 🎉",
            paymentSource: "カード"
        )

        XCTAssertEqual(cardDetails.currency, "€UR")
        XCTAssertEqual(cardDetails.amount, "1000€")
        XCTAssertEqual(cardDetails.country, "Deutschland")
        XCTAssertEqual(cardDetails.metadata, "测试数据 🎉")
        XCTAssertEqual(cardDetails.paymentSource, "カード")
    }

    func testInitializationWithVeryLongStrings() {
        let longString = String(repeating: "a", count: 1_000)
        let cardDetails = Gr4vyCardDetails(
            currency: "USD",
            amount: longString,
            bin: longString,
            country: longString,
            intent: longString,
            metadata: longString,
            paymentMethodId: longString,
            paymentSource: longString
        )

        XCTAssertEqual(cardDetails.currency, "USD")
        XCTAssertEqual(cardDetails.amount, longString)
        XCTAssertEqual(cardDetails.bin, longString)
        XCTAssertEqual(cardDetails.country, longString)
        XCTAssertEqual(cardDetails.intent, longString)
        XCTAssertEqual(cardDetails.metadata, longString)
        XCTAssertEqual(cardDetails.paymentMethodId, longString)
        XCTAssertEqual(cardDetails.paymentSource, longString)
    }

    func testDecodingWithEmptyStrings() throws {
        let json = """
        {
            "currency": "",
            "amount": "",
            "bin": "",
            "country": "",
            "intent": "",
            "metadata": "",
            "payment_method_id": "",
            "payment_source": ""
        }
        """

        let cardDetails = try decode(json)

        XCTAssertEqual(cardDetails.currency, "")
        XCTAssertEqual(cardDetails.amount, "")
        XCTAssertEqual(cardDetails.bin, "")
        XCTAssertEqual(cardDetails.country, "")
        XCTAssertEqual(cardDetails.intent, "")
        XCTAssertEqual(cardDetails.metadata, "")
        XCTAssertEqual(cardDetails.paymentMethodId, "")
        XCTAssertEqual(cardDetails.paymentSource, "")
    }

    func testDecodingWithUnicodeCharacters() throws {
        let json = """
        {
            "currency": "€UR",
            "amount": "1000€",
            "country": "Deutschland",
            "metadata": "测试数据 🎉",
            "payment_source": "カード"
        }
        """

        let cardDetails = try decode(json)

        XCTAssertEqual(cardDetails.currency, "€UR")
        XCTAssertEqual(cardDetails.amount, "1000€")
        XCTAssertEqual(cardDetails.country, "Deutschland")
        XCTAssertEqual(cardDetails.metadata, "测试数据 🎉")
        XCTAssertEqual(cardDetails.paymentSource, "カード")
    }

    // MARK: - Complex Scenarios Tests

    func testRoundTripEncodingDecodingWithAllCombinations() throws {
        let testCases: [(String, Gr4vyCardDetails)] = [
            ("minimal", Gr4vyCardDetails(currency: "USD")),
            ("with_amount", Gr4vyCardDetails(currency: "EUR", amount: "500")),
            ("with_booleans_true", Gr4vyCardDetails(currency: "GBP", isSubsequentPayment: true, merchantInitiated: true)),
            ("with_booleans_false", Gr4vyCardDetails(currency: "CAD", isSubsequentPayment: false, merchantInitiated: false)),
            ("with_all_fields", Gr4vyCardDetails(
                currency: "USD",
                amount: "1000",
                bin: "424242",
                country: "US",
                intent: "capture",
                isSubsequentPayment: true,
                merchantInitiated: false,
                metadata: "test",
                paymentMethodId: "pm_123",
                paymentSource: "card"
            )),
        ]

        for (testName, originalCardDetails) in testCases {
            let encodedJson = try encode(originalCardDetails)
            let decodedCardDetails = try decode(encodedJson)

            XCTAssertEqual(originalCardDetails.currency, decodedCardDetails.currency, "Failed for test case: \(testName)")
            XCTAssertEqual(originalCardDetails.amount, decodedCardDetails.amount, "Failed for test case: \(testName)")
            XCTAssertEqual(originalCardDetails.bin, decodedCardDetails.bin, "Failed for test case: \(testName)")
            XCTAssertEqual(originalCardDetails.country, decodedCardDetails.country, "Failed for test case: \(testName)")
            XCTAssertEqual(originalCardDetails.intent, decodedCardDetails.intent, "Failed for test case: \(testName)")
            XCTAssertEqual(originalCardDetails.isSubsequentPayment, decodedCardDetails.isSubsequentPayment, "Failed for test case: \(testName)")
            XCTAssertEqual(originalCardDetails.merchantInitiated, decodedCardDetails.merchantInitiated, "Failed for test case: \(testName)")
            XCTAssertEqual(originalCardDetails.metadata, decodedCardDetails.metadata, "Failed for test case: \(testName)")
            XCTAssertEqual(originalCardDetails.paymentMethodId, decodedCardDetails.paymentMethodId, "Failed for test case: \(testName)")
            XCTAssertEqual(originalCardDetails.paymentSource, decodedCardDetails.paymentSource, "Failed for test case: \(testName)")
        }
    }

    func testInvalidJSONStructures() {
        let invalidJsons = [
            "invalid json",
            "[]",
            "null",
            "{\"currency\": null}",
            "{\"currency\": 123}",
            "{\"amount\": 456}",
            "{\"is_subsequent_payment\": \"not_a_boolean\"}",
        ]

        for invalidJson in invalidJsons {
            XCTAssertThrowsError(try decode(invalidJson), "Should throw error for: \(invalidJson)")
        }
    }
}
