//
//  Gr4vySetupTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vySetupTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Initialization Tests

    func testGr4vySetupInitializationWithAllParameters() {
        // Given
        let gr4vyId = "test_merchant_123"
        let token = "test_token_456"
        let merchantId = "merchant_789"
        let server = Gr4vyServer.production
        let timeout: TimeInterval = 45.0

        // When
        let setup = Gr4vySetup(
            gr4vyId: gr4vyId,
            token: token,
            merchantId: merchantId,
            server: server,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(setup.gr4vyId, gr4vyId)
        XCTAssertEqual(setup.token, token)
        XCTAssertEqual(setup.merchantId, merchantId)
        XCTAssertEqual(setup.server, server)
        XCTAssertEqual(setup.timeout, timeout)
    }

    func testGr4vySetupInitializationWithoutMerchantId() {
        // Given
        let gr4vyId = "test_merchant_123"
        let token = "test_token_456"
        let server = Gr4vyServer.production
        let timeout: TimeInterval = 45.0

        // When
        let setup = Gr4vySetup(
            gr4vyId: gr4vyId,
            token: token,
            merchantId: nil,
            server: server,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(setup.gr4vyId, gr4vyId)
        XCTAssertEqual(setup.token, token)
        XCTAssertNil(setup.merchantId)
        XCTAssertEqual(setup.server, server)
        XCTAssertEqual(setup.timeout, timeout)
    }

    func testGr4vySetupInitializationWithDefaultTimeout() {
        // Given
        let gr4vyId = "test_merchant_456"
        let token = "test_token_789"
        let merchantId = "merchant_default_timeout"
        let server = Gr4vyServer.sandbox

        // When
        let setup = Gr4vySetup(
            gr4vyId: gr4vyId,
            token: token,
            merchantId: merchantId,
            server: server
        )

        // Then
        XCTAssertEqual(setup.gr4vyId, gr4vyId)
        XCTAssertEqual(setup.token, token)
        XCTAssertEqual(setup.merchantId, merchantId)
        XCTAssertEqual(setup.server, server)
        XCTAssertEqual(setup.timeout, 30.0) // Default timeout
    }

    func testGr4vySetupInitializationWithSandboxServer() {
        // Given
        let gr4vyId = "sandbox_merchant"
        let token = "sandbox_token"
        let merchantId = "sandbox_merchant_id"
        let server = Gr4vyServer.sandbox
        let timeout: TimeInterval = 60.0

        // When
        let setup = Gr4vySetup(
            gr4vyId: gr4vyId,
            token: token,
            merchantId: merchantId,
            server: server,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(setup.gr4vyId, gr4vyId)
        XCTAssertEqual(setup.token, token)
        XCTAssertEqual(setup.merchantId, merchantId)
        XCTAssertEqual(setup.server, .sandbox)
        XCTAssertEqual(setup.timeout, timeout)
    }

    func testGr4vySetupInitializationWithProductionServer() {
        // Given
        let gr4vyId = "prod_merchant"
        let token = "prod_token"
        let merchantId = "prod_merchant_id"
        let server = Gr4vyServer.production
        let timeout: TimeInterval = 15.0

        // When
        let setup = Gr4vySetup(
            gr4vyId: gr4vyId,
            token: token,
            merchantId: merchantId,
            server: server,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(setup.gr4vyId, gr4vyId)
        XCTAssertEqual(setup.token, token)
        XCTAssertEqual(setup.merchantId, merchantId)
        XCTAssertEqual(setup.server, .production)
        XCTAssertEqual(setup.timeout, timeout)
    }

    // MARK: - Instance Property Tests

    func testInstancePropertyWithProductionServer() {
        // Given
        let gr4vyId = "merchant_prod_123"
        let setup = Gr4vySetup(
            gr4vyId: gr4vyId,
            token: "token",
            merchantId: "prod_merchant",
            server: .production
        )

        // When
        let instance = setup.instance

        // Then
        XCTAssertEqual(instance, gr4vyId)
    }

    func testInstancePropertyWithSandboxServer() {
        // Given
        let gr4vyId = "merchant_sandbox_456"
        let setup = Gr4vySetup(
            gr4vyId: gr4vyId,
            token: "token",
            merchantId: "sandbox_merchant",
            server: .sandbox
        )

        // When
        let instance = setup.instance

        // Then
        XCTAssertEqual(instance, "sandbox.\(gr4vyId)")
    }

    func testInstancePropertyWithDifferentGr4vyIds() {
        // Test with various gr4vyId formats
        let testCases: [(String, Gr4vyServer, String)] = [
            ("simple", .production, "simple"),
            ("simple", .sandbox, "sandbox.simple"),
            ("test-merchant-123", .production, "test-merchant-123"),
            ("test-merchant-123", .sandbox, "sandbox.test-merchant-123"),
            ("merchant_with_underscores", .production, "merchant_with_underscores"),
            ("merchant_with_underscores", .sandbox, "sandbox.merchant_with_underscores"),
        ]

        for (gr4vyId, server, expectedInstance) in testCases {
            // Given
            let setup = Gr4vySetup(
                gr4vyId: gr4vyId,
                token: "token",
                merchantId: "test_merchant",
                server: server
            )

            // When
            let instance = setup.instance

            // Then
            XCTAssertEqual(instance, expectedInstance, "Failed for gr4vyId: \(gr4vyId), server: \(server)")
        }
    }

    // MARK: - JSON Encoding Tests

    func testGr4vySetupJSONEncodingWithProductionServer() throws {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test_merchant",
            token: "test_token_123",
            merchantId: "json_merchant_prod",
            server: .production,
            timeout: 25.0
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(setup)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["token"] as? String, "test_token_123")
        XCTAssertEqual(json?["merchantId"] as? String, "json_merchant_prod")
        XCTAssertEqual(json?["server"] as? String, "production")

        // Verify that gr4vyId and timeout are not encoded (not in CodingKeys)
        XCTAssertNil(json?["gr4vyId"])
        XCTAssertNil(json?["timeout"])
    }

    func testGr4vySetupJSONEncodingWithSandboxServer() throws {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "sandbox_merchant",
            token: "sandbox_token_456",
            merchantId: "json_merchant_sandbox",
            server: .sandbox,
            timeout: 45.0
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(setup)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["token"] as? String, "sandbox_token_456")
        XCTAssertEqual(json?["merchantId"] as? String, "json_merchant_sandbox")
        XCTAssertEqual(json?["server"] as? String, "sandbox")

        // Verify that gr4vyId and timeout are not encoded
        XCTAssertNil(json?["gr4vyId"])
        XCTAssertNil(json?["timeout"])
    }

    func testGr4vySetupJSONEncodingWithNilMerchantId() throws {
        // Given
        let setup = Gr4vySetup(
            gr4vyId: "test_merchant",
            token: "test_token_123",
            merchantId: nil,
            server: .production,
            timeout: 25.0
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(setup)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["token"] as? String, "test_token_123")
        XCTAssertEqual(json?["server"] as? String, "production")

        // merchantId should not be present when nil
        XCTAssertFalse(json?.keys.contains("merchantId") ?? true, "merchantId should not be encoded when nil")

        // Verify that gr4vyId and timeout are not encoded
        XCTAssertNil(json?["gr4vyId"])
        XCTAssertNil(json?["timeout"])
    }

    func testGr4vySetupEncodingDecodingRoundTrip() throws {
        // Given
        let originalSetup = Gr4vySetup(
            gr4vyId: "roundtrip_test",
            token: "roundtrip_token",
            merchantId: "roundtrip_merchant",
            server: .production,
            timeout: 35.0
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalSetup)

        // Create a struct that matches the encoded format for decoding
        struct EncodedSetup: Codable {
            let token: String
            let merchantId: String?
            let server: Gr4vyServer
        }

        let decoder = JSONDecoder()
        let decodedSetup = try decoder.decode(EncodedSetup.self, from: data)

        // Then
        XCTAssertEqual(decodedSetup.token, originalSetup.token)
        XCTAssertEqual(decodedSetup.merchantId, originalSetup.merchantId)
        XCTAssertEqual(decodedSetup.server, originalSetup.server)
    }

    // MARK: - Token Mutation Tests

    func testTokenMutation() {
        // Given
        var setup = Gr4vySetup(
            gr4vyId: "mutable_test",
            token: "initial_token",
            merchantId: "mutable_merchant",
            server: .sandbox
        )
        let newToken = "updated_token_123"

        // When
        setup.token = newToken

        // Then
        XCTAssertEqual(setup.token, newToken)
        XCTAssertEqual(setup.gr4vyId, "mutable_test") // Should remain unchanged
        XCTAssertEqual(setup.merchantId, "mutable_merchant") // Should remain unchanged
        XCTAssertEqual(setup.server, .sandbox) // Should remain unchanged
    }

    func testMerchantIdMutation() {
        // Given
        var setup = Gr4vySetup(
            gr4vyId: "merchant_mutation_test",
            token: "token",
            merchantId: "initial_merchant",
            server: .production
        )
        let newMerchantId = "updated_merchant_456"

        // When
        setup.merchantId = newMerchantId

        // Then
        XCTAssertEqual(setup.merchantId, newMerchantId)
        XCTAssertEqual(setup.gr4vyId, "merchant_mutation_test") // Should remain unchanged
        XCTAssertEqual(setup.token, "token") // Should remain unchanged
        XCTAssertEqual(setup.server, .production) // Should remain unchanged
    }

    func testMerchantIdMutationToNil() {
        // Given
        var setup = Gr4vySetup(
            gr4vyId: "merchant_nil_test",
            token: "token",
            merchantId: "initial_merchant",
            server: .sandbox
        )

        // When
        setup.merchantId = nil

        // Then
        XCTAssertNil(setup.merchantId)
        XCTAssertEqual(setup.gr4vyId, "merchant_nil_test") // Should remain unchanged
        XCTAssertEqual(setup.token, "token") // Should remain unchanged
        XCTAssertEqual(setup.server, .sandbox) // Should remain unchanged
    }

    func testMerchantIdMutationFromNil() {
        // Given
        var setup = Gr4vySetup(
            gr4vyId: "merchant_from_nil_test",
            token: "token",
            merchantId: nil,
            server: .production
        )
        let newMerchantId = "new_merchant_from_nil"

        // When
        setup.merchantId = newMerchantId

        // Then
        XCTAssertEqual(setup.merchantId, newMerchantId)
        XCTAssertEqual(setup.gr4vyId, "merchant_from_nil_test") // Should remain unchanged
        XCTAssertEqual(setup.token, "token") // Should remain unchanged
        XCTAssertEqual(setup.server, .production) // Should remain unchanged
    }

    func testTimeoutMutation() {
        // Given
        var setup = Gr4vySetup(
            gr4vyId: "timeout_test",
            token: "token",
            merchantId: "timeout_merchant",
            server: .production,
            timeout: 30.0
        )
        let newTimeout: TimeInterval = 60.0

        // When
        setup.timeout = newTimeout

        // Then
        XCTAssertEqual(setup.timeout, newTimeout)
        XCTAssertEqual(setup.gr4vyId, "timeout_test") // Should remain unchanged
        XCTAssertEqual(setup.token, "token") // Should remain unchanged
        XCTAssertEqual(setup.merchantId, "timeout_merchant") // Should remain unchanged
        XCTAssertEqual(setup.server, .production) // Should remain unchanged
    }

    // MARK: - Edge Cases Tests

    func testGr4vySetupWithEmptyStrings() {
        // Given
        let emptyGr4vyId = ""
        let emptyToken = ""
        let emptyMerchantId = ""

        // When
        let setup = Gr4vySetup(
            gr4vyId: emptyGr4vyId,
            token: emptyToken,
            merchantId: emptyMerchantId,
            server: .sandbox
        )

        // Then
        XCTAssertEqual(setup.gr4vyId, "")
        XCTAssertEqual(setup.token, "")
        XCTAssertEqual(setup.merchantId, "")
        XCTAssertEqual(setup.instance, "sandbox.") // Should handle empty gr4vyId
    }

    func testGr4vySetupWithNilMerchantId() {
        // Given
        let gr4vyId = "test_merchant"
        let token = "test_token"

        // When
        let setup = Gr4vySetup(
            gr4vyId: gr4vyId,
            token: token,
            merchantId: nil,
            server: .production
        )

        // Then
        XCTAssertEqual(setup.gr4vyId, gr4vyId)
        XCTAssertEqual(setup.token, token)
        XCTAssertNil(setup.merchantId)
        XCTAssertEqual(setup.instance, gr4vyId)
    }

    func testGr4vySetupWithSpecialCharacters() {
        // Given
        let specialGr4vyId = "merchant-123_test!@#"
        let specialToken = "token_with-special.chars123"
        let specialMerchantId = "merchant_special-chars_456!@#"

        // When
        let setup = Gr4vySetup(
            gr4vyId: specialGr4vyId,
            token: specialToken,
            merchantId: specialMerchantId,
            server: .production
        )

        // Then
        XCTAssertEqual(setup.gr4vyId, specialGr4vyId)
        XCTAssertEqual(setup.token, specialToken)
        XCTAssertEqual(setup.merchantId, specialMerchantId)
        XCTAssertEqual(setup.instance, specialGr4vyId) // Production should return as-is
    }

    func testGr4vySetupWithVeryLongStrings() {
        // Given
        let longGr4vyId = String(repeating: "a", count: 1_000)
        let longToken = String(repeating: "b", count: 2_000)
        let longMerchantId = String(repeating: "c", count: 1_500)

        // When
        let setup = Gr4vySetup(
            gr4vyId: longGr4vyId,
            token: longToken,
            merchantId: longMerchantId,
            server: .sandbox
        )

        // Then
        XCTAssertEqual(setup.gr4vyId, longGr4vyId)
        XCTAssertEqual(setup.token, longToken)
        XCTAssertEqual(setup.merchantId, longMerchantId)
        XCTAssertEqual(setup.instance, "sandbox.\(longGr4vyId)")
    }

    func testGr4vySetupWithZeroTimeout() {
        // Given
        let timeout: TimeInterval = 0.0

        // When
        let setup = Gr4vySetup(
            gr4vyId: "zero_timeout_test",
            token: "token",
            merchantId: "zero_timeout_merchant",
            server: .production,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(setup.timeout, 0.0)
        XCTAssertEqual(setup.merchantId, "zero_timeout_merchant")
    }

    func testGr4vySetupWithNegativeTimeout() {
        // Given
        let timeout: TimeInterval = -10.0

        // When
        let setup = Gr4vySetup(
            gr4vyId: "negative_timeout_test",
            token: "token",
            merchantId: "negative_timeout_merchant",
            server: .sandbox,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(setup.timeout, -10.0) // Should accept negative values
        XCTAssertEqual(setup.merchantId, "negative_timeout_merchant")
    }

    func testGr4vySetupWithVeryLargeTimeout() {
        // Given
        let timeout: TimeInterval = 999_999.0

        // When
        let setup = Gr4vySetup(
            gr4vyId: "large_timeout_test",
            token: "token",
            merchantId: "large_timeout_merchant",
            server: .production,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(setup.timeout, 999_999.0)
        XCTAssertEqual(setup.merchantId, "large_timeout_merchant")
    }
}
