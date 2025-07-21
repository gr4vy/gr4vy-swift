//
//  Gr4vyPaymentOptionRequestTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyPaymentOptionRequestTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Initialization Tests

    func testInitializationWithAllParameters() {
        // Given
        let merchantId = "test-merchant-123"
        let metadata = ["key1": "value1", "key2": "value2"]
        let country = "US"
        let currency = "USD"
        let amount = 1_000
        let locale = "en-US"
        let cartItems = [createTestCartItem()]
        let timeout: TimeInterval = 30.0

        // When
        let request = Gr4vyPaymentOptionRequest(
            merchantId: merchantId,
            metadata: metadata,
            country: country,
            currency: currency,
            amount: amount,
            locale: locale,
            cartItems: cartItems,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(request.merchantId, merchantId)
        XCTAssertEqual(request.metadata, metadata)
        XCTAssertEqual(request.country, country)
        XCTAssertEqual(request.currency, currency)
        XCTAssertEqual(request.amount, amount)
        XCTAssertEqual(request.locale, locale)
        XCTAssertEqual(request.cartItems?.count, 1)
        XCTAssertEqual(request.timeout, timeout)
    }

    func testInitializationWithRequiredParametersOnly() {
        // Given
        let metadata = ["session": "abc123"]
        let locale = "en-GB"

        // When
        let request = Gr4vyPaymentOptionRequest(
            metadata: metadata,
            country: nil,
            currency: nil,
            amount: nil,
            locale: locale,
            cartItems: nil
        )

        // Then
        XCTAssertNil(request.merchantId)
        XCTAssertEqual(request.metadata, metadata)
        XCTAssertNil(request.country)
        XCTAssertNil(request.currency)
        XCTAssertNil(request.amount)
        XCTAssertEqual(request.locale, locale)
        XCTAssertNil(request.cartItems)
        XCTAssertNil(request.timeout)
    }

    func testInitializationWithDefaultMerchantId() {
        // Given
        let metadata = ["test": "value"]
        let locale = "fr-FR"

        // When
        let request = Gr4vyPaymentOptionRequest(
            metadata: metadata,
            country: "FR",
            currency: "EUR",
            amount: 500,
            locale: locale,
            cartItems: nil
        )

        // Then
        XCTAssertNil(request.merchantId) // Should be nil by default
    }

    func testInitializationWithEmptyCartItems() {
        // Given
        let metadata = ["empty": "cart"]
        let locale = "de-DE"
        let emptyCartItems: [Gr4vyPaymentOptionCartItem] = []

        // When
        let request = Gr4vyPaymentOptionRequest(
            metadata: metadata,
            country: "DE",
            currency: "EUR",
            amount: 0,
            locale: locale,
            cartItems: emptyCartItems
        )

        // Then
        XCTAssertEqual(request.cartItems?.count, 0)
    }

    // MARK: - JSON Encoding Tests

    func testJSONEncodingWithAllFields() throws {
        // Given
        let request = Gr4vyPaymentOptionRequest(
            merchantId: "test-merchant",
            metadata: ["session_id": "abc123", "user_id": "user456"],
            country: "CA",
            currency: "CAD",
            amount: 2_500,
            locale: "en-CA",
            cartItems: [createTestCartItem()],
            timeout: 45.0
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["metadata"] as? [String: String], ["session_id": "abc123", "user_id": "user456"])
        XCTAssertEqual(json?["country"] as? String, "CA")
        XCTAssertEqual(json?["currency"] as? String, "CAD")
        XCTAssertEqual(json?["amount"] as? Int, 2_500)
        XCTAssertEqual(json?["locale"] as? String, "en-CA")

        // Verify cart_items (snake_case) key
        XCTAssertNotNil(json?["cart_items"] as? [[String: Any]])

        // Verify merchantId and timeout are not encoded (not in CodingKeys)
        XCTAssertNil(json?["merchantId"])
        XCTAssertNil(json?["timeout"])
    }

    func testJSONEncodingWithMinimalFields() throws {
        // Given
        let request = Gr4vyPaymentOptionRequest(
            metadata: ["minimal": "test"],
            country: nil,
            currency: nil,
            amount: nil,
            locale: "ja-JP",
            cartItems: nil
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["metadata"] as? [String: String], ["minimal": "test"])
        XCTAssertEqual(json?["locale"] as? String, "ja-JP")

        // Optional fields should be null or absent
        if let country = json?["country"] {
            XCTAssertTrue(country is NSNull)
        }
        if let currency = json?["currency"] {
            XCTAssertTrue(currency is NSNull)
        }
        if let amount = json?["amount"] {
            XCTAssertTrue(amount is NSNull)
        }
        if let cartItems = json?["cart_items"] {
            XCTAssertTrue(cartItems is NSNull)
        }
    }

    func testJSONEncodingCartItemsSnakeCase() throws {
        // Given
        let cartItem = createTestCartItem()
        let request = Gr4vyPaymentOptionRequest(
            metadata: ["test": "snake_case"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: [cartItem]
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        let cartItems = json?["cart_items"] as? [[String: Any]]
        XCTAssertNotNil(cartItems)
        XCTAssertEqual(cartItems?.count, 1)

        let encodedCartItem = cartItems?.first
        XCTAssertEqual(encodedCartItem?["name"] as? String, "Test Product")
        XCTAssertEqual(encodedCartItem?["unit_amount"] as? Int, 1_000)
        XCTAssertEqual(encodedCartItem?["external_identifier"] as? String, "ext-123")
        XCTAssertEqual(encodedCartItem?["product_url"] as? String, "https://example.com/product")
        XCTAssertEqual(encodedCartItem?["image_url"] as? String, "https://example.com/image.jpg")
        XCTAssertEqual(encodedCartItem?["product_type"] as? String, "physical")
        XCTAssertEqual(encodedCartItem?["seller_country"] as? String, "US")
    }

    // MARK: - Cart Items Tests

    func testCartItemInitializationWithAllFields() {
        // Given
        let name = "Premium Widget"
        let quantity = 3
        let unitAmount = 1_500
        let discountAmount = 150
        let taxAmount = 120
        let externalIdentifier = "widget-001"
        let sku = "WIDGET-PREM"
        let productUrl = "https://shop.example.com/widget"
        let imageUrl = "https://cdn.example.com/widget.png"
        let categories = ["electronics", "widgets"]
        let productType = "digital"
        let sellerCountry = "GB"

        // When
        let cartItem = Gr4vyPaymentOptionCartItem(
            name: name,
            quantity: quantity,
            unitAmount: unitAmount,
            discountAmount: discountAmount,
            taxAmount: taxAmount,
            externalIdentifier: externalIdentifier,
            sku: sku,
            productUrl: productUrl,
            imageUrl: imageUrl,
            categories: categories,
            productType: productType,
            sellerCountry: sellerCountry
        )

        // Then
        XCTAssertEqual(cartItem.name, name)
        XCTAssertEqual(cartItem.quantity, quantity)
        XCTAssertEqual(cartItem.unitAmount, unitAmount)
        XCTAssertEqual(cartItem.discountAmount, discountAmount)
        XCTAssertEqual(cartItem.taxAmount, taxAmount)
        XCTAssertEqual(cartItem.externalIdentifier, externalIdentifier)
        XCTAssertEqual(cartItem.sku, sku)
        XCTAssertEqual(cartItem.productUrl, productUrl)
        XCTAssertEqual(cartItem.imageUrl, imageUrl)
        XCTAssertEqual(cartItem.categories, categories)
        XCTAssertEqual(cartItem.productType, productType)
        XCTAssertEqual(cartItem.sellerCountry, sellerCountry)
    }

    func testCartItemInitializationWithRequiredFieldsOnly() {
        // Given
        let name = "Basic Item"
        let quantity = 1
        let unitAmount = 500

        // When
        let cartItem = Gr4vyPaymentOptionCartItem(
            name: name,
            quantity: quantity,
            unitAmount: unitAmount,
            discountAmount: nil,
            taxAmount: nil,
            externalIdentifier: nil,
            sku: nil,
            productUrl: nil,
            imageUrl: nil,
            categories: nil,
            productType: nil,
            sellerCountry: nil
        )

        // Then
        XCTAssertEqual(cartItem.name, name)
        XCTAssertEqual(cartItem.quantity, quantity)
        XCTAssertEqual(cartItem.unitAmount, unitAmount)
        XCTAssertNil(cartItem.discountAmount)
        XCTAssertNil(cartItem.taxAmount)
        XCTAssertNil(cartItem.externalIdentifier)
        XCTAssertNil(cartItem.sku)
        XCTAssertNil(cartItem.productUrl)
        XCTAssertNil(cartItem.imageUrl)
        XCTAssertNil(cartItem.categories)
        XCTAssertNil(cartItem.productType)
        XCTAssertNil(cartItem.sellerCountry)
    }

    func testMultipleCartItems() {
        // Given
        let item1 = Gr4vyPaymentOptionCartItem(
            name: "Item 1",
            quantity: 2,
            unitAmount: 1_000,
            discountAmount: nil,
            taxAmount: nil,
            externalIdentifier: nil,
            sku: "ITEM001",
            productUrl: nil,
            imageUrl: nil,
            categories: ["category1"],
            productType: nil,
            sellerCountry: nil
        )

        let item2 = Gr4vyPaymentOptionCartItem(
            name: "Item 2",
            quantity: 1,
            unitAmount: 2_500,
            discountAmount: 250,
            taxAmount: 200,
            externalIdentifier: "ext-002",
            sku: "ITEM002",
            productUrl: "https://example.com/item2",
            imageUrl: "https://example.com/item2.jpg",
            categories: ["category2", "category3"],
            productType: "physical",
            sellerCountry: "FR"
        )

        let cartItems = [item1, item2]

        // When
        let request = Gr4vyPaymentOptionRequest(
            metadata: ["cart": "multiple_items"],
            country: "US",
            currency: "USD",
            amount: 4_500, // (2 * 1000) + (1 * 2500) = 4500
            locale: "en-US",
            cartItems: cartItems
        )

        // Then
        XCTAssertEqual(request.cartItems?.count, 2)
        XCTAssertEqual(request.cartItems?[0].name, "Item 1")
        XCTAssertEqual(request.cartItems?[1].name, "Item 2")
    }

    // MARK: - MerchantId Tests

    func testMerchantIdHandling() {
        // Test nil merchantId
        let requestWithoutMerchant = Gr4vyPaymentOptionRequest(
            metadata: ["test": "no_merchant"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )
        XCTAssertNil(requestWithoutMerchant.merchantId)

        // Test with merchantId
        let requestWithMerchant = Gr4vyPaymentOptionRequest(
            merchantId: "merchant-abc123",
            metadata: ["test": "with_merchant"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )
        XCTAssertEqual(requestWithMerchant.merchantId, "merchant-abc123")

        // Test empty merchantId
        let requestWithEmptyMerchant = Gr4vyPaymentOptionRequest(
            merchantId: "",
            metadata: ["test": "empty_merchant"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )
        XCTAssertEqual(requestWithEmptyMerchant.merchantId, "")
    }

    // MARK: - Validation Tests

    func testCurrencyAndAmountConsistency() {
        // Test with both currency and amount
        let requestWithBoth = Gr4vyPaymentOptionRequest(
            metadata: ["test": "both"],
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )
        XCTAssertEqual(requestWithBoth.currency, "USD")
        XCTAssertEqual(requestWithBoth.amount, 1_000)

        // Test with currency but no amount
        let requestCurrencyOnly = Gr4vyPaymentOptionRequest(
            metadata: ["test": "currency_only"],
            country: "US",
            currency: "USD",
            amount: nil,
            locale: "en-US",
            cartItems: nil
        )
        XCTAssertEqual(requestCurrencyOnly.currency, "USD")
        XCTAssertNil(requestCurrencyOnly.amount)

        // Test with amount but no currency
        let requestAmountOnly = Gr4vyPaymentOptionRequest(
            metadata: ["test": "amount_only"],
            country: "US",
            currency: nil,
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )
        XCTAssertNil(requestAmountOnly.currency)
        XCTAssertEqual(requestAmountOnly.amount, 1_000)
    }

    func testLocaleFormats() {
        let locales = [
            "en-US",
            "en-GB",
            "fr-FR",
            "de-DE",
            "ja-JP",
            "zh-CN",
            "es-ES",
            "pt-BR",
        ]

        for locale in locales {
            let request = Gr4vyPaymentOptionRequest(
                metadata: ["locale_test": locale],
                country: nil,
                currency: nil,
                amount: nil,
                locale: locale,
                cartItems: nil
            )
            XCTAssertEqual(request.locale, locale)
        }
    }

    // MARK: - Edge Cases Tests

    func testZeroAmount() {
        // Given
        let request = Gr4vyPaymentOptionRequest(
            metadata: ["amount": "zero"],
            country: "US",
            currency: "USD",
            amount: 0,
            locale: "en-US",
            cartItems: nil
        )

        // Then
        XCTAssertEqual(request.amount, 0)
    }

    func testNegativeAmount() {
        // Given (this might represent a refund or credit)
        let request = Gr4vyPaymentOptionRequest(
            metadata: ["amount": "negative"],
            country: "US",
            currency: "USD",
            amount: -1_000,
            locale: "en-US",
            cartItems: nil
        )

        // Then
        XCTAssertEqual(request.amount, -1_000)
    }

    func testLargeAmount() {
        // Given
        let largeAmount = Int.max
        let request = Gr4vyPaymentOptionRequest(
            metadata: ["amount": "large"],
            country: "US",
            currency: "USD",
            amount: largeAmount,
            locale: "en-US",
            cartItems: nil
        )

        // Then
        XCTAssertEqual(request.amount, largeAmount)
    }

    func testEmptyMetadata() {
        // Given
        let emptyMetadata: [String: String] = [:]
        let request = Gr4vyPaymentOptionRequest(
            metadata: emptyMetadata,
            country: "US",
            currency: "USD",
            amount: 1_000,
            locale: "en-US",
            cartItems: nil
        )

        // Then
        XCTAssertEqual(request.metadata.count, 0)
        XCTAssertTrue(request.metadata.isEmpty)
    }

    func testSpecialCharactersInMetadata() {
        // Given
        let specialMetadata = [
            "unicode": "测试🚀",
            "special_chars": "!@#$%^&*()_+-={}[]|\\:;\"'<>?,./",
            "empty_value": "",
            "spaces": "value with spaces",
        ]

        let request = Gr4vyPaymentOptionRequest(
            metadata: specialMetadata,
            country: "CN",
            currency: "CNY",
            amount: 1_000,
            locale: "zh-CN",
            cartItems: nil
        )

        // Then
        XCTAssertEqual(request.metadata, specialMetadata)
    }

    func testCartItemWithZeroQuantity() {
        // Given
        let cartItem = Gr4vyPaymentOptionCartItem(
            name: "Zero Quantity Item",
            quantity: 0,
            unitAmount: 1_000,
            discountAmount: nil,
            taxAmount: nil,
            externalIdentifier: nil,
            sku: nil,
            productUrl: nil,
            imageUrl: nil,
            categories: nil,
            productType: nil,
            sellerCountry: nil
        )

        // Then
        XCTAssertEqual(cartItem.quantity, 0)
    }

    func testCartItemWithLongName() {
        // Given
        let longName = String(repeating: "A", count: 1_000)
        let cartItem = Gr4vyPaymentOptionCartItem(
            name: longName,
            quantity: 1,
            unitAmount: 1_000,
            discountAmount: nil,
            taxAmount: nil,
            externalIdentifier: nil,
            sku: nil,
            productUrl: nil,
            imageUrl: nil,
            categories: nil,
            productType: nil,
            sellerCountry: nil
        )

        // Then
        XCTAssertEqual(cartItem.name.count, 1_000)
        XCTAssertEqual(cartItem.name, longName)
    }

    func testTimeoutHandling() {
        // Test various timeout values
        let timeouts: [TimeInterval?] = [nil, 0, 15.5, 30, 60, 120, 300]

        for timeout in timeouts {
            let request = Gr4vyPaymentOptionRequest(
                metadata: ["timeout_test": "\(timeout ?? -1)"],
                country: "US",
                currency: "USD",
                amount: 1_000,
                locale: "en-US",
                cartItems: nil,
                timeout: timeout
            )
            XCTAssertEqual(request.timeout, timeout)
        }
    }

    // MARK: - Helper Methods

    private func createTestCartItem() -> Gr4vyPaymentOptionCartItem {
        Gr4vyPaymentOptionCartItem(
            name: "Test Product",
            quantity: 2,
            unitAmount: 1_000,
            discountAmount: 100,
            taxAmount: 80,
            externalIdentifier: "ext-123",
            sku: "TEST-SKU",
            productUrl: "https://example.com/product",
            imageUrl: "https://example.com/image.jpg",
            categories: ["electronics", "test"],
            productType: "physical",
            sellerCountry: "US"
        )
    }
}
