//
//  Gr4vyBuyersPaymentMethodsRequestTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyBuyersPaymentMethodsRequestTests: XCTestCase {
    // MARK: - Initialization Tests

    func testBuyersPaymentMethodsRequestInitializationWithAllParameters() {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: "external_456",
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: "US",
            currency: "USD"
        )
        let timeout: TimeInterval = 30.0

        // When
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(request.timeout, timeout)
        XCTAssertEqual(request.paymentMethods.buyerId, "buyer_123")
        XCTAssertEqual(request.paymentMethods.buyerExternalIdentifier, "external_456")
        XCTAssertEqual(request.paymentMethods.sortBy, .lastUsedAt)
        XCTAssertEqual(request.paymentMethods.orderBy, .desc)
        XCTAssertEqual(request.paymentMethods.country, "US")
        XCTAssertEqual(request.paymentMethods.currency, "USD")
    }

    func testBuyersPaymentMethodsRequestInitializationWithMinimalParameters() {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: nil,
            sortBy: .lastUsedAt,
            orderBy: .asc,
            country: nil,
            currency: nil
        )

        // When
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            timeout: nil
        )

        // Then
        XCTAssertNil(request.timeout)
        XCTAssertEqual(request.paymentMethods.buyerId, "buyer_123")
        XCTAssertNil(request.paymentMethods.buyerExternalIdentifier)
        XCTAssertEqual(request.paymentMethods.sortBy, .lastUsedAt)
        XCTAssertEqual(request.paymentMethods.orderBy, .asc)
        XCTAssertNil(request.paymentMethods.country)
        XCTAssertNil(request.paymentMethods.currency)
    }

    func testBuyersPaymentMethodsRequestInitializationWithDefaultTimeout() {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: "external_456",
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: "GB",
            currency: "GBP"
        )

        // When
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        // Then
        XCTAssertNil(request.timeout)
        XCTAssertEqual(request.paymentMethods.buyerId, "buyer_123")
        XCTAssertEqual(request.paymentMethods.buyerExternalIdentifier, "external_456")
        XCTAssertEqual(request.paymentMethods.country, "GB")
        XCTAssertEqual(request.paymentMethods.currency, "GBP")
    }

    func testBuyersPaymentMethodsRequestInitializationWithDifferentOrderBy() {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_789",
            buyerExternalIdentifier: "external_012",
            sortBy: .lastUsedAt,
            orderBy: .asc,
            country: "CA",
            currency: "CAD"
        )
        let timeout: TimeInterval = 60.0

        // When
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(request.timeout, timeout)
        XCTAssertEqual(request.paymentMethods.buyerId, "buyer_789")
        XCTAssertEqual(request.paymentMethods.buyerExternalIdentifier, "external_012")
        XCTAssertEqual(request.paymentMethods.orderBy, .asc)
        XCTAssertEqual(request.paymentMethods.country, "CA")
        XCTAssertEqual(request.paymentMethods.currency, "CAD")
    }

    // MARK: - Encoding Tests

    func testBuyersPaymentMethodsRequestEncodingWithAllFields() throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: "external_456",
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: "US",
            currency: "USD"
        )
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            timeout: 30.0
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["payment_methods"])

        // Verify payment methods structure
        let paymentMethodsJson = json?["payment_methods"] as? [String: Any]
        XCTAssertNotNil(paymentMethodsJson)
        XCTAssertEqual(paymentMethodsJson?["buyer_id"] as? String, "buyer_123")
        XCTAssertEqual(paymentMethodsJson?["buyer_external_identifier"] as? String, "external_456")
        XCTAssertEqual(paymentMethodsJson?["sort_by"] as? String, "last_used_at")
        XCTAssertEqual(paymentMethodsJson?["order_by"] as? String, "desc")
        XCTAssertEqual(paymentMethodsJson?["country"] as? String, "US")
        XCTAssertEqual(paymentMethodsJson?["currency"] as? String, "USD")
    }

    func testBuyersPaymentMethodsRequestEncodingWithMinimalFields() throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: nil,
            sortBy: .lastUsedAt,
            orderBy: .asc,
            country: nil,
            currency: nil
        )
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            timeout: nil
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["payment_methods"])

        // Verify payment methods structure
        let paymentMethodsJson = json?["payment_methods"] as? [String: Any]
        XCTAssertNotNil(paymentMethodsJson)
        XCTAssertEqual(paymentMethodsJson?["buyer_id"] as? String, "buyer_123")
        XCTAssertEqual(paymentMethodsJson?["sort_by"] as? String, "last_used_at")
        XCTAssertEqual(paymentMethodsJson?["order_by"] as? String, "asc")

        // Verify nil fields are not included or are null
        XCTAssertTrue(paymentMethodsJson?["buyer_external_identifier"] == nil ||
                        paymentMethodsJson?["buyer_external_identifier"] is NSNull)
        XCTAssertTrue(paymentMethodsJson?["country"] == nil ||
                        paymentMethodsJson?["country"] is NSNull)
        XCTAssertTrue(paymentMethodsJson?["currency"] == nil ||
                        paymentMethodsJson?["currency"] is NSNull)
    }

    func testBuyersPaymentMethodsRequestEncodingWithAscendingOrder() throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_789",
            buyerExternalIdentifier: "external_012",
            sortBy: .lastUsedAt,
            orderBy: .asc,
            country: "GB",
            currency: "GBP"
        )
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            timeout: 45.0
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["payment_methods"])

        // Verify payment methods structure
        let paymentMethodsJson = json?["payment_methods"] as? [String: Any]
        XCTAssertNotNil(paymentMethodsJson)
        XCTAssertEqual(paymentMethodsJson?["buyer_id"] as? String, "buyer_789")
        XCTAssertEqual(paymentMethodsJson?["buyer_external_identifier"] as? String, "external_012")
        XCTAssertEqual(paymentMethodsJson?["order_by"] as? String, "asc")
        XCTAssertEqual(paymentMethodsJson?["country"] as? String, "GB")
        XCTAssertEqual(paymentMethodsJson?["currency"] as? String, "GBP")
    }

    // MARK: - Timeout Tests

    func testBuyersPaymentMethodsRequestWithZeroTimeout() {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: "external_456",
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: "US",
            currency: "USD"
        )
        let timeout: TimeInterval = 0.0

        // When
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(request.timeout, 0.0)
    }

    func testBuyersPaymentMethodsRequestWithLargeTimeout() {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: "external_456",
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: "US",
            currency: "USD"
        )
        let timeout: TimeInterval = 9_999.0

        // When
        let request = Gr4vyBuyersPaymentMethodsRequest(
            paymentMethods: paymentMethods,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(request.timeout, 9_999.0)
    }

    // MARK: - CodingKeys Tests

    func testBuyersPaymentMethodsRequestCodingKeysMapping() throws {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: "external_456",
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: "US",
            currency: "USD"
        )
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let jsonString = String(data: data, encoding: .utf8)

        // Then
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString!.contains("payment_methods"))
        XCTAssertFalse(jsonString!.contains("paymentMethods"))
    }

    // MARK: - Edge Cases

    func testBuyersPaymentMethodsRequestWithEmptyBuyerId() {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "",
            buyerExternalIdentifier: "external_456",
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: "US",
            currency: "USD"
        )

        // When
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        // Then
        XCTAssertEqual(request.paymentMethods.buyerId, "")
        XCTAssertNotNil(request.paymentMethods)
        XCTAssertNil(request.timeout)
    }

    func testBuyersPaymentMethodsRequestWithSpecialCharacters() {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123!@#",
            buyerExternalIdentifier: "external_456$%^",
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: "US",
            currency: "USD"
        )

        // When
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

        // Then
        XCTAssertEqual(request.paymentMethods.buyerId, "buyer_123!@#")
        XCTAssertEqual(request.paymentMethods.buyerExternalIdentifier, "external_456$%^")
    }

    func testBuyersPaymentMethodsRequestEquality() {
        // Given
        let paymentMethods1 = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: "external_456",
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: "US",
            currency: "USD"
        )
        let paymentMethods2 = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: "external_456",
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: "US",
            currency: "USD"
        )

        let request1 = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods1, timeout: 30.0)
        let request2 = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods2, timeout: 30.0)

        // When/Then
        // Note: Since the struct doesn't conform to Equatable, we test property equality
        XCTAssertEqual(request1.timeout, request2.timeout)
        XCTAssertEqual(request1.paymentMethods.buyerId, request2.paymentMethods.buyerId)
        XCTAssertEqual(request1.paymentMethods.buyerExternalIdentifier, request2.paymentMethods.buyerExternalIdentifier)
        XCTAssertEqual(request1.paymentMethods.sortBy, request2.paymentMethods.sortBy)
        XCTAssertEqual(request1.paymentMethods.orderBy, request2.paymentMethods.orderBy)
        XCTAssertEqual(request1.paymentMethods.country, request2.paymentMethods.country)
        XCTAssertEqual(request1.paymentMethods.currency, request2.paymentMethods.currency)

        // Verify encoding equality
        let encoder = JSONEncoder()
        let data1 = try? encoder.encode(request1)
        let data2 = try? encoder.encode(request2)

        XCTAssertNotNil(data1)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data1, data2)
    }

    // MARK: - Different Currency and Country Tests

    func testBuyersPaymentMethodsRequestWithDifferentCurrencies() {
        // Given
        let currencies = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD"]

        for currency in currencies {
            // When
            let paymentMethods = Gr4vyBuyersPaymentMethods(
                buyerId: "buyer_123",
                buyerExternalIdentifier: "external_456",
                sortBy: .lastUsedAt,
                orderBy: .desc,
                country: "US",
                currency: currency
            )
            let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

            // Then
            XCTAssertEqual(request.paymentMethods.currency, currency)
        }
    }

    func testBuyersPaymentMethodsRequestWithDifferentCountries() {
        // Given
        let countries = ["US", "GB", "CA", "AU", "DE", "FR"]

        for country in countries {
            // When
            let paymentMethods = Gr4vyBuyersPaymentMethods(
                buyerId: "buyer_123",
                buyerExternalIdentifier: "external_456",
                sortBy: .lastUsedAt,
                orderBy: .desc,
                country: country,
                currency: "USD"
            )
            let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods)

            // Then
            XCTAssertEqual(request.paymentMethods.country, country)
        }
    }
    
    // MARK: - Nil Values Tests

    func testBuyersPaymentMethodsRequestWithAllNilOptionalFields() {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: nil,
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: nil,
            currency: nil
        )

        // When
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods, timeout: nil)

        // Then
        XCTAssertNil(request.timeout)
        XCTAssertEqual(request.paymentMethods.buyerId, "buyer_123")
        XCTAssertNil(request.paymentMethods.buyerExternalIdentifier)
        XCTAssertEqual(request.paymentMethods.sortBy, .lastUsedAt)
        XCTAssertEqual(request.paymentMethods.orderBy, .desc)
        XCTAssertNil(request.paymentMethods.country)
        XCTAssertNil(request.paymentMethods.currency)
    }

    func testBuyersPaymentMethodsRequestWithMixedNilValues() {
        // Given
        let paymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: "external_456",
            sortBy: .lastUsedAt,
            orderBy: .asc,
            country: nil,
            currency: "USD"
        )

        // When
        let request = Gr4vyBuyersPaymentMethodsRequest(paymentMethods: paymentMethods, timeout: 45.0)

        // Then
        XCTAssertEqual(request.timeout, 45.0)
        XCTAssertEqual(request.paymentMethods.buyerId, "buyer_123")
        XCTAssertEqual(request.paymentMethods.buyerExternalIdentifier, "external_456")
        XCTAssertEqual(request.paymentMethods.sortBy, .lastUsedAt)
        XCTAssertEqual(request.paymentMethods.orderBy, .asc)
        XCTAssertNil(request.paymentMethods.country)
        XCTAssertEqual(request.paymentMethods.currency, "USD")
    }
}
