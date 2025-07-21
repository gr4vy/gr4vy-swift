//
//  Gr4vyCardDataTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

class Gr4vyCardDataTests: XCTestCase {
    // MARK: - CardPaymentMethod Tests
    func testCardPaymentMethodInitialization() {
        let cardMethod = CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )

        XCTAssertEqual(cardMethod.number, "4111111111111111")
        XCTAssertEqual(cardMethod.expirationDate, "12/25")
        XCTAssertEqual(cardMethod.securityCode, "123")
    }

    func testCardPaymentMethodEncoding() throws {
        let cardMethod = CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )

        let paymentMethod = Gr4vyPaymentMethod.card(cardMethod)
        let cardData = Gr4vyCardData(paymentMethod: paymentMethod)

        let encoder = JSONEncoder()
        let data = try encoder.encode(cardData)

        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let method = json["payment_method"] as! [String: Any]

        XCTAssertEqual(method["method"] as? String, "card")
        XCTAssertEqual(method["number"] as? String, "4111111111111111")
        XCTAssertEqual(method["expiration_date"] as? String, "12/25")
        XCTAssertEqual(method["security_code"] as? String, "123")
    }

    // MARK: - ClickToPayPaymentMethod Tests
    func testClickToPayPaymentMethodInitialization() {
        let clickToPay = ClickToPayPaymentMethod(
            merchantTransactionId: "txn_123",
            srcCorrelationId: "src_456"
        )

        XCTAssertEqual(clickToPay.merchantTransactionId, "txn_123")
        XCTAssertEqual(clickToPay.srcCorrelationId, "src_456")
    }

    func testClickToPayPaymentMethodEncoding() throws {
        let clickToPay = ClickToPayPaymentMethod(
            merchantTransactionId: "txn_123",
            srcCorrelationId: "src_456"
        )

        let paymentMethod = Gr4vyPaymentMethod.clickToPay(clickToPay)
        let cardData = Gr4vyCardData(paymentMethod: paymentMethod)

        let encoder = JSONEncoder()
        let data = try encoder.encode(cardData)

        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let method = json["payment_method"] as! [String: Any]

        XCTAssertEqual(method["method"] as? String, "click_to_pay")
        XCTAssertEqual(method["merchant_transaction_id"] as? String, "txn_123")
        XCTAssertEqual(method["src_correlation_id"] as? String, "src_456")
    }

    // MARK: - IdPaymentMethod Tests
    func testIdPaymentMethodInitialization() {
        let idMethod = IdPaymentMethod(
            id: "pm_123",
            securityCode: "456"
        )

        XCTAssertEqual(idMethod.id, "pm_123")
        XCTAssertEqual(idMethod.securityCode, "456")
    }

    func testIdPaymentMethodEncoding() throws {
        let idMethod = IdPaymentMethod(
            id: "pm_123",
            securityCode: "456"
        )

        let paymentMethod = Gr4vyPaymentMethod.id(idMethod)
        let cardData = Gr4vyCardData(paymentMethod: paymentMethod)

        let encoder = JSONEncoder()
        let data = try encoder.encode(cardData)

        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let method = json["payment_method"] as! [String: Any]

        XCTAssertEqual(method["method"] as? String, "id")
        XCTAssertEqual(method["id"] as? String, "pm_123")
        XCTAssertEqual(method["security_code"] as? String, "456")
    }

    // MARK: - Gr4vyCardData Tests
    func testGr4vyCardDataInitialization() {
        let cardMethod = CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )

        let paymentMethod = Gr4vyPaymentMethod.card(cardMethod)
        let cardData = Gr4vyCardData(paymentMethod: paymentMethod)

        if case .card(let card) = cardData.paymentMethod {
            XCTAssertEqual(card.number, "4111111111111111")
            XCTAssertEqual(card.expirationDate, "12/25")
            XCTAssertEqual(card.securityCode, "123")
        } else {
            XCTFail("Expected card payment method")
        }
    }

    func testGr4vyCardDataDecoding() throws {
        let json = """
        {
            "payment_method": {
                "method": "card",
                "number": "4111111111111111",
                "expiration_date": "12/25",
                "security_code": "123"
            }
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let cardData = try decoder.decode(Gr4vyCardData.self, from: data)

        if case .card(let card) = cardData.paymentMethod {
            XCTAssertEqual(card.number, "4111111111111111")
            XCTAssertEqual(card.expirationDate, "12/25")
            XCTAssertEqual(card.securityCode, "123")
        } else {
            XCTFail("Expected card payment method")
        }
    }

    func testGr4vyCardDataDecodingClickToPay() throws {
        let json = """
        {
            "payment_method": {
                "method": "click_to_pay",
                "merchant_transaction_id": "txn_123",
                "src_correlation_id": "src_456"
            }
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let cardData = try decoder.decode(Gr4vyCardData.self, from: data)

        if case .clickToPay(let clickToPay) = cardData.paymentMethod {
            XCTAssertEqual(clickToPay.merchantTransactionId, "txn_123")
            XCTAssertEqual(clickToPay.srcCorrelationId, "src_456")
        } else {
            XCTFail("Expected click to pay payment method")
        }
    }

    func testGr4vyCardDataDecodingId() throws {
        let json = """
        {
            "payment_method": {
                "method": "id",
                "id": "pm_123",
                "security_code": "456"
            }
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let cardData = try decoder.decode(Gr4vyCardData.self, from: data)

        if case .id(let idMethod) = cardData.paymentMethod {
            XCTAssertEqual(idMethod.id, "pm_123")
            XCTAssertEqual(idMethod.securityCode, "456")
        } else {
            XCTFail("Expected id payment method")
        }
    }

    func testGr4vyCardDataDecodingInvalidType() throws {
        let json = """
        {
            "payment_method": {
                "method": "invalid_type",
                "number": "4111111111111111"
            }
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(Gr4vyCardData.self, from: data)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testGr4vyCardDataEncodingDecoding() throws {
        let originalCardMethod = CardPaymentMethod(
            number: "4111111111111111",
            expirationDate: "12/25",
            securityCode: "123"
        )

        let originalPaymentMethod = Gr4vyPaymentMethod.card(originalCardMethod)
        let originalCardData = Gr4vyCardData(paymentMethod: originalPaymentMethod)

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalCardData)

        // Decode
        let decoder = JSONDecoder()
        let decodedCardData = try decoder.decode(Gr4vyCardData.self, from: data)

        // Verify
        if case .card(let decodedCard) = decodedCardData.paymentMethod {
            XCTAssertEqual(decodedCard.number, "4111111111111111")
            XCTAssertEqual(decodedCard.expirationDate, "12/25")
            XCTAssertEqual(decodedCard.securityCode, "123")
        } else {
            XCTFail("Expected card payment method")
        }
    }

    // MARK: - Edge Cases
    func testGr4vyCardDataWithMissingFields() throws {
        let json = """
        {
            "payment_method": {
                "method": "card",
                "number": "4111111111111111"
            }
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(Gr4vyCardData.self, from: data)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testGr4vyCardDataWithEmptyMethod() throws {
        let json = """
        {
            "payment_method": {}
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(Gr4vyCardData.self, from: data)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
}
