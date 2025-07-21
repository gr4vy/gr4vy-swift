//
//  Gr4vyCardDetailsRequestTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyCardDetailsRequestTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Initialization Tests

    func testInitializationWithAllParameters() {
        // Given
        let cardDetails = Gr4vyCardDetails(
            currency: "USD",
            amount: "100.00",
            bin: "411111",
            country: "US",
            intent: "capture",
            isSubsequentPayment: false,
            merchantInitiated: true,
            metadata: "test_metadata",
            paymentMethodId: "test_payment_method",
            paymentSource: "test_source"
        )
        let timeout: TimeInterval = 30.0

        // When
        let request = Gr4vyCardDetailsRequest(
            cardDetails: cardDetails,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(request.cardDetails.currency, "USD")
        XCTAssertEqual(request.cardDetails.amount, "100.00")
        XCTAssertEqual(request.cardDetails.bin, "411111")
        XCTAssertEqual(request.cardDetails.country, "US")
        XCTAssertEqual(request.cardDetails.intent, "capture")
        XCTAssertEqual(request.cardDetails.isSubsequentPayment, false)
        XCTAssertEqual(request.cardDetails.merchantInitiated, true)
        XCTAssertEqual(request.cardDetails.metadata, "test_metadata")
        XCTAssertEqual(request.cardDetails.paymentMethodId, "test_payment_method")
        XCTAssertEqual(request.cardDetails.paymentSource, "test_source")
        XCTAssertEqual(request.timeout, 30.0)
    }

    func testInitializationWithMinimalParameters() {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")

        // When
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        // Then
        XCTAssertEqual(request.cardDetails.currency, "USD")
        XCTAssertNil(request.cardDetails.amount)
        XCTAssertNil(request.cardDetails.bin)
        XCTAssertNil(request.cardDetails.country)
        XCTAssertNil(request.cardDetails.intent)
        XCTAssertNil(request.cardDetails.isSubsequentPayment)
        XCTAssertNil(request.cardDetails.merchantInitiated)
        XCTAssertNil(request.cardDetails.metadata)
        XCTAssertNil(request.cardDetails.paymentMethodId)
        XCTAssertNil(request.cardDetails.paymentSource)
        XCTAssertNil(request.timeout)
    }

    func testInitializationWithDefaultTimeout() {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "EUR")

        // When
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        // Then
        XCTAssertNil(request.timeout)
    }

    func testInitializationWithCustomTimeout() {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "GBP")
        let timeout: TimeInterval = 45.0

        // When
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails, timeout: timeout)

        // Then
        XCTAssertEqual(request.timeout, 45.0)
    }

    // MARK: - JSON Encoding Tests

    func testJSONEncodingWithCompleteCardDetails() throws {
        // Given
        let cardDetails = Gr4vyCardDetails(
            currency: "USD",
            amount: "100.00",
            bin: "411111",
            country: "US",
            intent: "capture",
            isSubsequentPayment: false,
            merchantInitiated: true,
            metadata: "test_metadata",
            paymentMethodId: "test_payment_method",
            paymentSource: "test_source"
        )
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails, timeout: 30.0)

        // When
        let jsonData = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        // Then
        XCTAssertNotNil(json)

        // Verify card_details is present
        XCTAssertNotNil(json?["card_details"])

        // Verify timeout is not encoded (not in CodingKeys)
        XCTAssertNil(json?["timeout"])

        // Verify card_details structure
        let cardDetailsJSON = json?["card_details"] as? [String: Any]
        XCTAssertNotNil(cardDetailsJSON)
        XCTAssertEqual(cardDetailsJSON?["currency"] as? String, "USD")
        XCTAssertEqual(cardDetailsJSON?["amount"] as? String, "100.00")
        XCTAssertEqual(cardDetailsJSON?["bin"] as? String, "411111")
        XCTAssertEqual(cardDetailsJSON?["country"] as? String, "US")
        XCTAssertEqual(cardDetailsJSON?["intent"] as? String, "capture")
        XCTAssertEqual(cardDetailsJSON?["is_subsequent_payment"] as? Bool, false)
        XCTAssertEqual(cardDetailsJSON?["merchant_initiated"] as? Bool, true)
        XCTAssertEqual(cardDetailsJSON?["metadata"] as? String, "test_metadata")
        XCTAssertEqual(cardDetailsJSON?["payment_method_id"] as? String, "test_payment_method")
        XCTAssertEqual(cardDetailsJSON?["payment_source"] as? String, "test_source")
    }

    func testJSONEncodingWithMinimalCardDetails() throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "EUR")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        // When
        let jsonData = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        // Then
        XCTAssertNotNil(json)

        // Verify card_details is present
        XCTAssertNotNil(json?["card_details"])

        // Verify timeout is not encoded (not in CodingKeys)
        XCTAssertNil(json?["timeout"])

        // Verify card_details structure
        let cardDetailsJSON = json?["card_details"] as? [String: Any]
        XCTAssertNotNil(cardDetailsJSON)
        XCTAssertEqual(cardDetailsJSON?["currency"] as? String, "EUR")

        // Verify optional fields are not present (nil values are not encoded)
        XCTAssertNil(cardDetailsJSON?["amount"])
        XCTAssertNil(cardDetailsJSON?["bin"])
        XCTAssertNil(cardDetailsJSON?["country"])
        XCTAssertNil(cardDetailsJSON?["intent"])
        XCTAssertNil(cardDetailsJSON?["is_subsequent_payment"])
        XCTAssertNil(cardDetailsJSON?["merchant_initiated"])
        XCTAssertNil(cardDetailsJSON?["metadata"])
        XCTAssertNil(cardDetailsJSON?["payment_method_id"])
        XCTAssertNil(cardDetailsJSON?["payment_source"])
    }

    func testJSONEncodingStructure() throws {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails, timeout: 30.0)

        // When
        let jsonData = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        // Then
        XCTAssertNotNil(json)

        // Verify only card_details is in the JSON (timeout is not encoded)
        XCTAssertEqual(json?.keys.count, 1)
        XCTAssertTrue(json?.keys.contains("card_details") == true)
        XCTAssertFalse(json?.keys.contains("timeout") == true)
    }

    // MARK: - Timeout Tests

    func testTimeoutDefaultValue() {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")

        // When
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        // Then
        XCTAssertNil(request.timeout)
    }

    func testTimeoutCustomValue() {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let timeout: TimeInterval = 60.0

        // When
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails, timeout: timeout)

        // Then
        XCTAssertEqual(request.timeout, 60.0)
    }

    func testTimeoutZeroValue() {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let timeout: TimeInterval = 0.0

        // When
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails, timeout: timeout)

        // Then
        XCTAssertEqual(request.timeout, 0.0)
    }

    func testTimeoutNegativeValue() {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let timeout: TimeInterval = -5.0

        // When
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails, timeout: timeout)

        // Then
        XCTAssertEqual(request.timeout, -5.0)
    }

    func testTimeoutLargeValue() {
        // Given
        let cardDetails = Gr4vyCardDetails(currency: "USD")
        let timeout: TimeInterval = 300.0 // 5 minutes

        // When
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails, timeout: timeout)

        // Then
        XCTAssertEqual(request.timeout, 300.0)
    }

    // MARK: - Edge Cases Tests

    func testCardDetailsWithEmptyValues() {
        // Given
        let cardDetails = Gr4vyCardDetails(
            currency: "USD",
            amount: "",
            bin: "",
            country: "",
            intent: "",
            metadata: "",
            paymentMethodId: "",
            paymentSource: ""
        )

        // When
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        // Then
        XCTAssertEqual(request.cardDetails.currency, "USD")
        XCTAssertEqual(request.cardDetails.amount, "")
        XCTAssertEqual(request.cardDetails.bin, "")
        XCTAssertEqual(request.cardDetails.country, "")
        XCTAssertEqual(request.cardDetails.intent, "")
        XCTAssertEqual(request.cardDetails.metadata, "")
        XCTAssertEqual(request.cardDetails.paymentMethodId, "")
        XCTAssertEqual(request.cardDetails.paymentSource, "")
    }

    func testCardDetailsWithLongValues() {
        // Given
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

        // When
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        // Then
        XCTAssertEqual(request.cardDetails.currency, "USD")
        XCTAssertEqual(request.cardDetails.amount, longString)
        XCTAssertEqual(request.cardDetails.bin, longString)
        XCTAssertEqual(request.cardDetails.country, longString)
        XCTAssertEqual(request.cardDetails.intent, longString)
        XCTAssertEqual(request.cardDetails.metadata, longString)
        XCTAssertEqual(request.cardDetails.paymentMethodId, longString)
        XCTAssertEqual(request.cardDetails.paymentSource, longString)
    }

    func testCardDetailsWithUnicodeValues() {
        // Given
        let cardDetails = Gr4vyCardDetails(
            currency: "USD",
            amount: "¥100.00",
            bin: "测试",
            country: "日本",
            intent: "캡처",
            metadata: "🎯 test metadata",
            paymentMethodId: "payment_method_🔑",
            paymentSource: "source_🌟"
        )

        // When
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        // Then
        XCTAssertEqual(request.cardDetails.currency, "USD")
        XCTAssertEqual(request.cardDetails.amount, "¥100.00")
        XCTAssertEqual(request.cardDetails.bin, "测试")
        XCTAssertEqual(request.cardDetails.country, "日本")
        XCTAssertEqual(request.cardDetails.intent, "캡처")
        XCTAssertEqual(request.cardDetails.metadata, "🎯 test metadata")
        XCTAssertEqual(request.cardDetails.paymentMethodId, "payment_method_🔑")
        XCTAssertEqual(request.cardDetails.paymentSource, "source_🌟")
    }

    func testCardDetailsWithSpecialCharacters() {
        // Given
        let cardDetails = Gr4vyCardDetails(
            currency: "USD",
            amount: "100.00",
            bin: "411111",
            country: "US",
            intent: "capture",
            metadata: "test\"metadata'with<>special&chars",
            paymentMethodId: "payment_method_id!@#$%^&*()",
            paymentSource: "source_[]{}|\\:;\"'<>,.?/~`"
        )

        // When
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        // Then
        XCTAssertEqual(request.cardDetails.currency, "USD")
        XCTAssertEqual(request.cardDetails.amount, "100.00")
        XCTAssertEqual(request.cardDetails.bin, "411111")
        XCTAssertEqual(request.cardDetails.country, "US")
        XCTAssertEqual(request.cardDetails.intent, "capture")
        XCTAssertEqual(request.cardDetails.metadata, "test\"metadata'with<>special&chars")
        XCTAssertEqual(request.cardDetails.paymentMethodId, "payment_method_id!@#$%^&*()")
        XCTAssertEqual(request.cardDetails.paymentSource, "source_[]{}|\\:;\"'<>,.?/~`")
    }

    func testJSONEncodingWithEmptyStringValues() throws {
        // Given
        let cardDetails = Gr4vyCardDetails(
            currency: "USD",
            amount: "",
            bin: "",
            country: "",
            intent: "",
            metadata: "",
            paymentMethodId: "",
            paymentSource: ""
        )
        let request = Gr4vyCardDetailsRequest(cardDetails: cardDetails)

        // When
        let jsonData = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        // Then
        XCTAssertNotNil(json)

        let cardDetailsJSON = json?["card_details"] as? [String: Any]
        XCTAssertNotNil(cardDetailsJSON)
        XCTAssertEqual(cardDetailsJSON?["currency"] as? String, "USD")
        XCTAssertEqual(cardDetailsJSON?["amount"] as? String, "")
        XCTAssertEqual(cardDetailsJSON?["bin"] as? String, "")
        XCTAssertEqual(cardDetailsJSON?["country"] as? String, "")
        XCTAssertEqual(cardDetailsJSON?["intent"] as? String, "")
        XCTAssertEqual(cardDetailsJSON?["metadata"] as? String, "")
        XCTAssertEqual(cardDetailsJSON?["payment_method_id"] as? String, "")
        XCTAssertEqual(cardDetailsJSON?["payment_source"] as? String, "")
    }
}
