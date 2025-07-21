//
//  Gr4vyCheckoutSessionRequestTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyCheckoutSessionRequestTests: XCTestCase {
    // MARK: - Initialization Tests

    func testCheckoutSessionRequestInitializationWithCardPayment() {
        // Given
        let cardPayment = Gr4vyPaymentMethod.card(
            CardPaymentMethod(
                number: "4111111111111111",
                expirationDate: "12/25",
                securityCode: "123"
            )
        )
        let timeout: TimeInterval = 30.0

        // When
        let request = Gr4vyCheckoutSessionRequest(
            paymentMethod: cardPayment,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(request.timeout, timeout)

        // Verify payment method
        switch request.paymentMethod {
        case .card(let cardMethod):
            XCTAssertEqual(cardMethod.number, "4111111111111111")
            XCTAssertEqual(cardMethod.expirationDate, "12/25")
            XCTAssertEqual(cardMethod.securityCode, "123")
        default:
            XCTFail("Expected card payment method")
        }
    }

    func testCheckoutSessionRequestInitializationWithClickToPay() {
        // Given
        let clickToPayPayment = Gr4vyPaymentMethod.clickToPay(
            ClickToPayPaymentMethod(
                merchantTransactionId: "txn_123",
                srcCorrelationId: "src_456"
            )
        )

        // When
        let request = Gr4vyCheckoutSessionRequest(
            paymentMethod: clickToPayPayment,
            timeout: nil
        )

        // Then
        XCTAssertNil(request.timeout)

        // Verify payment method
        switch request.paymentMethod {
        case .clickToPay(let clickToPayMethod):
            XCTAssertEqual(clickToPayMethod.merchantTransactionId, "txn_123")
            XCTAssertEqual(clickToPayMethod.srcCorrelationId, "src_456")
        default:
            XCTFail("Expected click to pay payment method")
        }
    }

    func testCheckoutSessionRequestInitializationWithIdPayment() {
        // Given
        let idPayment = Gr4vyPaymentMethod.id(
            IdPaymentMethod(
                id: "pm_123",
                securityCode: "456"
            )
        )
        let timeout: TimeInterval = 60.0

        // When
        let request = Gr4vyCheckoutSessionRequest(
            paymentMethod: idPayment,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(request.timeout, timeout)

        // Verify payment method
        switch request.paymentMethod {
        case .id(let idMethod):
            XCTAssertEqual(idMethod.id, "pm_123")
            XCTAssertEqual(idMethod.securityCode, "456")
        default:
            XCTFail("Expected id payment method")
        }
    }

    func testCheckoutSessionRequestInitializationWithDefaultTimeout() {
        // Given
        let cardPayment = Gr4vyPaymentMethod.card(
            CardPaymentMethod(
                number: "4111111111111111",
                expirationDate: "12/25",
                securityCode: "123"
            )
        )

        // When
        let request = Gr4vyCheckoutSessionRequest(paymentMethod: cardPayment)

        // Then
        XCTAssertNil(request.timeout)
    }

    // MARK: - Encoding Tests

    func testCheckoutSessionRequestEncodingWithCardPayment() throws {
        // Given
        let cardPayment = Gr4vyPaymentMethod.card(
            CardPaymentMethod(
                number: "4111111111111111",
                expirationDate: "12/25",
                securityCode: "123"
            )
        )
        let request = Gr4vyCheckoutSessionRequest(
            paymentMethod: cardPayment,
            timeout: 30.0
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["payment_method"])

        // Verify payment method structure
        let paymentMethodJson = json?["payment_method"] as? [String: Any]
        XCTAssertNotNil(paymentMethodJson)
        XCTAssertEqual(paymentMethodJson?["method"] as? String, "card")
        XCTAssertEqual(paymentMethodJson?["number"] as? String, "4111111111111111")
        XCTAssertEqual(paymentMethodJson?["expiration_date"] as? String, "12/25")
        XCTAssertEqual(paymentMethodJson?["security_code"] as? String, "123")
    }

    func testCheckoutSessionRequestEncodingWithClickToPay() throws {
        // Given
        let clickToPayPayment = Gr4vyPaymentMethod.clickToPay(
            ClickToPayPaymentMethod(
                merchantTransactionId: "txn_123",
                srcCorrelationId: "src_456"
            )
        )
        let request = Gr4vyCheckoutSessionRequest(
            paymentMethod: clickToPayPayment,
            timeout: nil
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["payment_method"])

        // Verify payment method structure
        let paymentMethodJson = json?["payment_method"] as? [String: Any]
        XCTAssertNotNil(paymentMethodJson)
        XCTAssertEqual(paymentMethodJson?["method"] as? String, "click_to_pay")
        XCTAssertEqual(paymentMethodJson?["merchant_transaction_id"] as? String, "txn_123")
        XCTAssertEqual(paymentMethodJson?["src_correlation_id"] as? String, "src_456")
    }

    func testCheckoutSessionRequestEncodingWithIdPayment() throws {
        // Given
        let idPayment = Gr4vyPaymentMethod.id(
            IdPaymentMethod(
                id: "pm_123",
                securityCode: "456"
            )
        )
        let request = Gr4vyCheckoutSessionRequest(
            paymentMethod: idPayment,
            timeout: 45.0
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["payment_method"])

        // Verify payment method structure
        let paymentMethodJson = json?["payment_method"] as? [String: Any]
        XCTAssertNotNil(paymentMethodJson)
        XCTAssertEqual(paymentMethodJson?["method"] as? String, "id")
        XCTAssertEqual(paymentMethodJson?["id"] as? String, "pm_123")
        XCTAssertEqual(paymentMethodJson?["security_code"] as? String, "456")
    }

    // MARK: - Timeout Tests

    func testCheckoutSessionRequestWithZeroTimeout() {
        // Given
        let cardPayment = Gr4vyPaymentMethod.card(
            CardPaymentMethod(
                number: "4111111111111111",
                expirationDate: "12/25",
                securityCode: "123"
            )
        )
        let timeout: TimeInterval = 0.0

        // When
        let request = Gr4vyCheckoutSessionRequest(
            paymentMethod: cardPayment,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(request.timeout, 0.0)
    }

    func testCheckoutSessionRequestWithLargeTimeout() {
        // Given
        let cardPayment = Gr4vyPaymentMethod.card(
            CardPaymentMethod(
                number: "4111111111111111",
                expirationDate: "12/25",
                securityCode: "123"
            )
        )
        let timeout: TimeInterval = 9_999.0

        // When
        let request = Gr4vyCheckoutSessionRequest(
            paymentMethod: cardPayment,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(request.timeout, 9_999.0)
    }

    // MARK: - CodingKeys Tests

    func testCheckoutSessionRequestCodingKeysMapping() throws {
        // Given
        let cardPayment = Gr4vyPaymentMethod.card(
            CardPaymentMethod(
                number: "4111111111111111",
                expirationDate: "12/25",
                securityCode: "123"
            )
        )
        let request = Gr4vyCheckoutSessionRequest(paymentMethod: cardPayment)

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let jsonString = String(data: data, encoding: .utf8)

        // Then
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString!.contains("payment_method"))
        XCTAssertFalse(jsonString!.contains("paymentMethod"))
    }

    // MARK: - Edge Cases

    func testCheckoutSessionRequestWithMinimalCardData() {
        // Given
        let cardPayment = Gr4vyPaymentMethod.card(
            CardPaymentMethod(
                number: "4111111111111111",
                expirationDate: "12/25",
                securityCode: "123"
            )
        )

        // When
        let request = Gr4vyCheckoutSessionRequest(paymentMethod: cardPayment)

        // Then
        XCTAssertNotNil(request.paymentMethod)
        XCTAssertNil(request.timeout)
    }

    func testCheckoutSessionRequestEquality() {
        // Given
        let cardPayment1 = Gr4vyPaymentMethod.card(
            CardPaymentMethod(
                number: "4111111111111111",
                expirationDate: "12/25",
                securityCode: "123"
            )
        )
        let cardPayment2 = Gr4vyPaymentMethod.card(
            CardPaymentMethod(
                number: "4111111111111111",
                expirationDate: "12/25",
                securityCode: "123"
            )
        )

        let request1 = Gr4vyCheckoutSessionRequest(paymentMethod: cardPayment1, timeout: 30.0)
        let request2 = Gr4vyCheckoutSessionRequest(paymentMethod: cardPayment2, timeout: 30.0)

        // When/Then
        // Note: Since the struct doesn't conform to Equatable, we test property equality
        XCTAssertEqual(request1.timeout, request2.timeout)

        // Verify payment method equality by encoding both
        let encoder = JSONEncoder()
        let data1 = try? encoder.encode(request1)
        let data2 = try? encoder.encode(request2)

        XCTAssertNotNil(data1)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data1, data2)
    }
}
