//
//  Gr4vyBuyersPaymentMethodsTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

class Gr4vyBuyersPaymentMethodsTests: XCTestCase {
    // MARK: - SortBy Enum Tests
    func testSortByEnumValues() {
        XCTAssertEqual(Gr4vySortBy.lastUsedAt.rawValue, "last_used_at")
    }

    func testSortByEnumCaseIterable() {
        let allCases = Gr4vySortBy.allCases
        XCTAssertEqual(allCases.count, 1)
        XCTAssertTrue(allCases.contains(.lastUsedAt))
    }

    func testSortByEnumCodable() throws {
        // Test encoding
        let encoder = JSONEncoder()
        let lastUsedAtData = try encoder.encode(Gr4vySortBy.lastUsedAt)

        let lastUsedAtJson = String(data: lastUsedAtData, encoding: .utf8)!

        XCTAssertEqual(lastUsedAtJson, "\"last_used_at\"")

        // Test decoding
        let decoder = JSONDecoder()
        let decodedLastUsedAt = try decoder.decode(Gr4vySortBy.self, from: lastUsedAtData)

        XCTAssertEqual(decodedLastUsedAt, .lastUsedAt)
    }

    // MARK: - OrderBy Enum Tests
    func testOrderByEnumValues() {
        XCTAssertEqual(Gr4vyOrderBy.asc.rawValue, "asc")
        XCTAssertEqual(Gr4vyOrderBy.desc.rawValue, "desc")
    }

    func testOrderByEnumCaseIterable() {
        let allCases = Gr4vyOrderBy.allCases
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.asc))
        XCTAssertTrue(allCases.contains(.desc))
    }

    func testOrderByEnumCodable() throws {
        // Test encoding
        let encoder = JSONEncoder()
        let ascData = try encoder.encode(Gr4vyOrderBy.asc)
        let descData = try encoder.encode(Gr4vyOrderBy.desc)

        let ascJson = String(data: ascData, encoding: .utf8)!
        let descJson = String(data: descData, encoding: .utf8)!

        XCTAssertEqual(ascJson, "\"asc\"")
        XCTAssertEqual(descJson, "\"desc\"")

        // Test decoding
        let decoder = JSONDecoder()
        let decodedAsc = try decoder.decode(Gr4vyOrderBy.self, from: ascData)
        let decodedDesc = try decoder.decode(Gr4vyOrderBy.self, from: descData)

        XCTAssertEqual(decodedAsc, .asc)
        XCTAssertEqual(decodedDesc, .desc)
    }

    // MARK: - Gr4vyBuyersPaymentMethods Tests
    func testGr4vyBuyersPaymentMethodsInitialization() {
        let buyersPaymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: "ext_456",
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: "US",
            currency: "USD"
        )

        XCTAssertEqual(buyersPaymentMethods.buyerId, "buyer_123")
        XCTAssertEqual(buyersPaymentMethods.buyerExternalIdentifier, "ext_456")
        XCTAssertEqual(buyersPaymentMethods.sortBy, .lastUsedAt)
        XCTAssertEqual(buyersPaymentMethods.orderBy, .desc)
        XCTAssertEqual(buyersPaymentMethods.country, "US")
        XCTAssertEqual(buyersPaymentMethods.currency, "USD")
    }

    func testGr4vyBuyersPaymentMethodsInitializationWithNilValues() {
        let buyersPaymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: nil,
            buyerExternalIdentifier: nil,
            sortBy: nil,
            orderBy: nil,
            country: nil,
            currency: nil
        )

        XCTAssertNil(buyersPaymentMethods.buyerId)
        XCTAssertNil(buyersPaymentMethods.buyerExternalIdentifier)
        XCTAssertNil(buyersPaymentMethods.sortBy)
        XCTAssertNil(buyersPaymentMethods.orderBy)
        XCTAssertNil(buyersPaymentMethods.country)
        XCTAssertNil(buyersPaymentMethods.currency)
    }

    func testGr4vyBuyersPaymentMethodsInitializationPartialValues() {
        let buyersPaymentMethods = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: nil,
            sortBy: .lastUsedAt,
            orderBy: .asc,
            country: "CA",
            currency: nil
        )

        XCTAssertEqual(buyersPaymentMethods.buyerId, "buyer_123")
        XCTAssertNil(buyersPaymentMethods.buyerExternalIdentifier)
        XCTAssertEqual(buyersPaymentMethods.sortBy, .lastUsedAt)
        XCTAssertEqual(buyersPaymentMethods.orderBy, .asc)
        XCTAssertEqual(buyersPaymentMethods.country, "CA")
        XCTAssertNil(buyersPaymentMethods.currency)
    }

    func testGr4vyBuyersPaymentMethodsDefaultValues() {
        let buyersPaymentMethods = Gr4vyBuyersPaymentMethods(buyerId: "buyer_123")

        XCTAssertEqual(buyersPaymentMethods.buyerId, "buyer_123")
        XCTAssertNil(buyersPaymentMethods.buyerExternalIdentifier)
        XCTAssertNil(buyersPaymentMethods.sortBy)
        XCTAssertEqual(buyersPaymentMethods.orderBy, .desc) // Default value
        XCTAssertNil(buyersPaymentMethods.country)
        XCTAssertNil(buyersPaymentMethods.currency)
    }

    func testGr4vyBuyersPaymentMethodsCodable() throws {
        let original = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            buyerExternalIdentifier: "ext_456",
            sortBy: .lastUsedAt,
            orderBy: .desc,
            country: "US",
            currency: "USD"
        )

        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        // Verify JSON structure
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(json["buyer_id"] as? String, "buyer_123")
        XCTAssertEqual(json["buyer_external_identifier"] as? String, "ext_456")
        XCTAssertEqual(json["sort_by"] as? String, "last_used_at")
        XCTAssertEqual(json["order_by"] as? String, "desc")
        XCTAssertEqual(json["country"] as? String, "US")
        XCTAssertEqual(json["currency"] as? String, "USD")

        // Test decoding
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Gr4vyBuyersPaymentMethods.self, from: data)

        XCTAssertEqual(decoded.buyerId, original.buyerId)
        XCTAssertEqual(decoded.buyerExternalIdentifier, original.buyerExternalIdentifier)
        XCTAssertEqual(decoded.sortBy, original.sortBy)
        XCTAssertEqual(decoded.orderBy, original.orderBy)
        XCTAssertEqual(decoded.country, original.country)
        XCTAssertEqual(decoded.currency, original.currency)
    }

    func testGr4vyBuyersPaymentMethodsCodableWithNilValues() throws {
        let original = Gr4vyBuyersPaymentMethods(
            buyerId: nil,
            buyerExternalIdentifier: nil,
            sortBy: nil,
            orderBy: nil,
            country: nil,
            currency: nil
        )

        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        // Test decoding
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Gr4vyBuyersPaymentMethods.self, from: data)

        XCTAssertNil(decoded.buyerId)
        XCTAssertNil(decoded.buyerExternalIdentifier)
        XCTAssertNil(decoded.sortBy)
        XCTAssertNil(decoded.orderBy)
        XCTAssertNil(decoded.country)
        XCTAssertNil(decoded.currency)
    }

    func testGr4vyBuyersPaymentMethodsDecodingFromJSON() throws {
        let json = """
        {
            "buyer_id": "buyer_789",
            "buyer_external_identifier": "ext_101",
            "sort_by": "last_used_at",
            "order_by": "asc",
            "country": "GB",
            "currency": "GBP"
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Gr4vyBuyersPaymentMethods.self, from: data)

        XCTAssertEqual(decoded.buyerId, "buyer_789")
        XCTAssertEqual(decoded.buyerExternalIdentifier, "ext_101")
        XCTAssertEqual(decoded.sortBy, .lastUsedAt)
        XCTAssertEqual(decoded.orderBy, .asc)
        XCTAssertEqual(decoded.country, "GB")
        XCTAssertEqual(decoded.currency, "GBP")
    }

    func testGr4vyBuyersPaymentMethodsDecodingPartialJSON() throws {
        let json = """
        {
            "buyer_id": "buyer_partial",
            "sort_by": "last_used_at"
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Gr4vyBuyersPaymentMethods.self, from: data)

        XCTAssertEqual(decoded.buyerId, "buyer_partial")
        XCTAssertNil(decoded.buyerExternalIdentifier)
        XCTAssertEqual(decoded.sortBy, .lastUsedAt)
        XCTAssertNil(decoded.orderBy)
        XCTAssertNil(decoded.country)
        XCTAssertNil(decoded.currency)
    }

    func testGr4vyBuyersPaymentMethodsDecodingInvalidSortBy() throws {
        let json = """
        {
            "buyer_id": "buyer_123",
            "sort_by": "invalid_sort"
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(Gr4vyBuyersPaymentMethods.self, from: data)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testGr4vyBuyersPaymentMethodsDecodingInvalidOrderBy() throws {
        let json = """
        {
            "buyer_id": "buyer_123",
            "order_by": "invalid_order"
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(Gr4vyBuyersPaymentMethods.self, from: data)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    // MARK: - Edge Cases
    func testGr4vyBuyersPaymentMethodsWithAllOrderByValues() {
        let ascMethod = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            orderBy: .asc
        )
        XCTAssertEqual(ascMethod.orderBy, .asc)

        let descMethod = Gr4vyBuyersPaymentMethods(
            buyerId: "buyer_123",
            orderBy: .desc
        )
        XCTAssertEqual(descMethod.orderBy, .desc)
    }

    func testGr4vyBuyersPaymentMethodsEncodingDecoding() throws {
        let testCases: [(Gr4vySortBy?, Gr4vyOrderBy?)] = [
            (.lastUsedAt, .asc),
            (.lastUsedAt, .desc),
            (nil, .asc),
            (nil, .desc),
            (.lastUsedAt, nil),
            (nil, nil),
        ]

        for (sortBy, orderBy) in testCases {
            let original = Gr4vyBuyersPaymentMethods(
                buyerId: "test_buyer",
                sortBy: sortBy,
                orderBy: orderBy
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(original)

            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Gr4vyBuyersPaymentMethods.self, from: data)

            XCTAssertEqual(decoded.sortBy, original.sortBy)
            XCTAssertEqual(decoded.orderBy, original.orderBy)
        }
    }

    func testOrderByEnumEquality() {
        XCTAssertEqual(Gr4vyOrderBy.asc, Gr4vyOrderBy.asc)
        XCTAssertEqual(Gr4vyOrderBy.desc, Gr4vyOrderBy.desc)
        XCTAssertNotEqual(Gr4vyOrderBy.asc, Gr4vyOrderBy.desc)
    }

    func testOrderByEnumHashable() {
        let ascSet: Set<Gr4vyOrderBy> = [.asc, .asc]
        let descSet: Set<Gr4vyOrderBy> = [.desc, .desc]
        let mixedSet: Set<Gr4vyOrderBy> = [.asc, .desc]

        XCTAssertEqual(ascSet.count, 1)
        XCTAssertEqual(descSet.count, 1)
        XCTAssertEqual(mixedSet.count, 2)
    }
}
