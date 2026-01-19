//
//  Gr4vyThreeDSecureResponseTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyThreeDSecureResponseTests: XCTestCase {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Helper Methods

    private func decode(_ json: String) throws -> Gr4vyThreeDSecureResponse {
        try decoder.decode(Gr4vyThreeDSecureResponse.self, from: Data(json.utf8))
    }

    private func encode(_ response: Gr4vyThreeDSecureResponse) throws -> String {
        let data = try encoder.encode(response)
        return String(data: data, encoding: .utf8) ?? ""
    }

    // MARK: - Decoding Tests

    func testDecodingFrictionlessResponse() throws {
        // Given
        let json = """
        {
            "indicator": "FINISH",
            "transaction_status": "Y",
            "cardholder_info": "Authentication successful"
        }
        """

        // When
        let response = try decode(json)

        // Then
        XCTAssertEqual(response.indicator, "FINISH")
        XCTAssertTrue(response.isFrictionless)
        XCTAssertFalse(response.isChallenge)
        XCTAssertFalse(response.isError)
        XCTAssertEqual(response.transactionStatus, "Y")
        XCTAssertEqual(response.cardholderInfo, "Authentication successful")
        XCTAssertNil(response.challenge)
    }

    func testDecodingChallengeResponse() throws {
        // Given
        let json = """
        {
            "indicator": "CHALLENGE",
            "challenge": {
                "server_transaction_id": "server_txn_123",
                "acs_transaction_id": "txn_123",
                "acs_reference_number": "ref_456",
                "acs_rendering_type": {
                    "acsInterface": "01",
                    "acsUiTemplate": "01",
                    "deviceUserInterfaceMode": "01"
                },
                "acs_signed_content": "signed_content_789"
            },
            "transaction_status": "C"
        }
        """

        // When
        let response = try decode(json)

        // Then
        XCTAssertEqual(response.indicator, "CHALLENGE")
        XCTAssertFalse(response.isFrictionless)
        XCTAssertTrue(response.isChallenge)
        XCTAssertFalse(response.isError)
        XCTAssertNotNil(response.challenge)
        XCTAssertEqual(response.transactionStatus, "C")
        XCTAssertNil(response.cardholderInfo)
    }

    func testDecodingChallengeResponseWithMissingDeviceUserInterfaceMode() throws {
        // Given - Real-world challenge response without deviceUserInterfaceMode
        let json = """
        {
            "indicator": "CHALLENGE",
            "transaction_status": "C",
            "challenge": {
                "server_transaction_id": "dbc51a89-48d9-2324-82cf-89263d2710a1",
                "acs_transaction_id": "99caa473-57db-1212-9ecc-02078ee5007c",
                "acs_reference_number": "XXX",
                "acs_rendering_type": {
                    "acsInterface": "01",
                    "acsUiTemplate": "04"
                },
                "acs_signed_content": "XXX.XXXXXX"
            },
            "cardholder_info": null
        }
        """

        // When
        let response = try decode(json)

        // Then
        XCTAssertEqual(response.indicator, "CHALLENGE")
        XCTAssertFalse(response.isFrictionless)
        XCTAssertTrue(response.isChallenge)
        XCTAssertFalse(response.isError)
        XCTAssertNotNil(response.challenge)
        XCTAssertEqual(response.transactionStatus, "C")
        XCTAssertNil(response.cardholderInfo)
        
        // Verify challenge details
        let challenge = try XCTUnwrap(response.challenge)
        XCTAssertEqual(challenge.serverTransactionId, "dbc51a89-48d9-2324-82cf-89263d2710a1")
        XCTAssertEqual(challenge.acsTransactionId, "99caa473-57db-1212-9ecc-02078ee5007c")
        XCTAssertEqual(challenge.acsReferenceNumber, "XXX")
        let acsRenderingType = try XCTUnwrap(challenge.acsRenderingType)
        XCTAssertEqual(acsRenderingType.acsInterface, "01")
        XCTAssertEqual(acsRenderingType.acsUiTemplate, "04")
        XCTAssertNil(acsRenderingType.deviceUserInterfaceMode)
        XCTAssertEqual(challenge.acsSignedContent, "XXX.XXXXXX")
    }

    func testDecodingErrorResponse() throws {
        // Given
        let json = """
        {
            "indicator": "ERROR",
            "transaction_status": "N",
            "cardholder_info": "Authentication failed"
        }
        """

        // When
        let response = try decode(json)

        // Then
        XCTAssertEqual(response.indicator, "ERROR")
        XCTAssertFalse(response.isFrictionless)
        XCTAssertFalse(response.isChallenge)
        XCTAssertTrue(response.isError)
        XCTAssertEqual(response.transactionStatus, "N")
        XCTAssertEqual(response.cardholderInfo, "Authentication failed")
        XCTAssertNil(response.challenge)
    }

    func testDecodingResponseWithNullChallenge() throws {
        // Given
        let json = """
        {
            "indicator": "FINISH",
            "challenge": null,
            "transaction_status": "Y",
            "cardholder_info": null
        }
        """

        // When
        let response = try decode(json)

        // Then
        XCTAssertEqual(response.indicator, "FINISH")
        XCTAssertTrue(response.isFrictionless)
        XCTAssertNil(response.challenge)
        XCTAssertEqual(response.transactionStatus, "Y")
        XCTAssertNil(response.cardholderInfo)
    }

    func testDecodingResponseWithoutOptionalFields() throws {
        // Given
        let json = """
        {
            "indicator": "FINISH"
        }
        """

        // When
        let response = try decode(json)

        // Then
        XCTAssertEqual(response.indicator, "FINISH")
        XCTAssertTrue(response.isFrictionless)
        XCTAssertNil(response.challenge)
        XCTAssertNil(response.transactionStatus)
        XCTAssertNil(response.cardholderInfo)
    }

    func testDecodingResponseWithAllFields() throws {
        // Given
        let json = """
        {
            "indicator": "CHALLENGE",
            "challenge": {
                "server_transaction_id": "server_txn_abc",
                "acs_transaction_id": "txn_abc",
                "acs_reference_number": "ref_def",
                "acs_rendering_type": {
                    "acsInterface": "01",
                    "acsUiTemplate": "02",
                    "deviceUserInterfaceMode": "01"
                },
                "acs_signed_content": "content_ghi"
            },
            "transaction_status": "C",
            "cardholder_info": "Please complete the challenge"
        }
        """

        // When
        let response = try decode(json)

        // Then
        XCTAssertEqual(response.indicator, "CHALLENGE")
        XCTAssertTrue(response.isChallenge)
        XCTAssertNotNil(response.challenge)
        XCTAssertEqual(response.transactionStatus, "C")
        XCTAssertEqual(response.cardholderInfo, "Please complete the challenge")
    }

    // MARK: - Computed Property Tests

    func testIsFrictionlessWhenIndicatorIsFinish() {
        // Test through JSON decoding
        let testCases = [
            "{\"indicator\": \"FINISH\"}",
            "{\"indicator\": \"FINISH\", \"transaction_status\": \"Y\"}",
            "{\"indicator\": \"FINISH\", \"transaction_status\": \"A\"}",
        ]

        for json in testCases {
            if let response = try? decode(json) {
                XCTAssertTrue(response.isFrictionless, "Failed for JSON: \(json)")
                XCTAssertFalse(response.isChallenge)
                XCTAssertFalse(response.isError)
            } else {
                XCTFail("Failed to decode: \(json)")
            }
        }
    }

    func testIsChallengeWhenIndicatorIsChallenge() {
        // Test through JSON decoding
        let testCases = [
            "{\"indicator\": \"CHALLENGE\"}",
            "{\"indicator\": \"CHALLENGE\", \"transaction_status\": \"C\"}",
            "{\"indicator\": \"CHALLENGE\", \"challenge\": null}",
        ]

        for json in testCases {
            if let response = try? decode(json) {
                XCTAssertTrue(response.isChallenge, "Failed for JSON: \(json)")
                XCTAssertFalse(response.isFrictionless)
                XCTAssertFalse(response.isError)
            } else {
                XCTFail("Failed to decode: \(json)")
            }
        }
    }

    func testIsErrorWhenIndicatorIsError() {
        // Test through JSON decoding
        let testCases = [
            "{\"indicator\": \"ERROR\"}",
            "{\"indicator\": \"ERROR\", \"transaction_status\": \"N\"}",
            "{\"indicator\": \"ERROR\", \"transaction_status\": \"U\"}",
        ]

        for json in testCases {
            if let response = try? decode(json) {
                XCTAssertTrue(response.isError, "Failed for JSON: \(json)")
                XCTAssertFalse(response.isFrictionless)
                XCTAssertFalse(response.isChallenge)
            } else {
                XCTFail("Failed to decode: \(json)")
            }
        }
    }

    func testComputedPropertiesWithUnknownIndicator() throws {
        // Given
        let json = """
        {
            "indicator": "unknown"
        }
        """

        // When
        let response = try decode(json)

        // Then - All computed properties should be false for unknown indicator
        XCTAssertFalse(response.isFrictionless)
        XCTAssertFalse(response.isChallenge)
        XCTAssertFalse(response.isError)
    }

    // MARK: - Transaction Status Tests

    func testTransactionStatusVariations() throws {
        let statuses = ["Y", "N", "U", "A", "C", "R", "D"]

        for status in statuses {
            let json = """
            {
                "indicator": "FINISH",
                "transaction_status": "\(status)"
            }
            """

            let response = try decode(json)
            XCTAssertEqual(response.transactionStatus, status, "Failed for status: \(status)")
        }
    }

    func testNullTransactionStatus() throws {
        // Given
        let json = """
        {
            "indicator": "FINISH",
            "transaction_status": null
        }
        """

        // When
        let response = try decode(json)

        // Then
        XCTAssertNil(response.transactionStatus)
    }

    // MARK: - Cardholder Info Tests

    func testCardholderInfoWithVariousMessages() throws {
        let messages = [
            "Authentication successful",
            "Please complete the challenge",
            "Authentication failed. Please try again.",
            "Technical error occurred",
            "",
        ]

        for message in messages {
            let json = """
            {
                "indicator": "FINISH",
                "cardholder_info": "\(message)"
            }
            """

            let response = try decode(json)
            XCTAssertEqual(response.cardholderInfo, message, "Failed for message: \(message)")
        }
    }

    func testCardholderInfoWithSpecialCharacters() throws {
        // Given
        let json = """
        {
            "indicator": "FINISH",
            "cardholder_info": "Success! ✅ Authentication completed @ 100% 🎉"
        }
        """

        // When
        let response = try decode(json)

        // Then
        XCTAssertEqual(response.cardholderInfo, "Success! ✅ Authentication completed @ 100% 🎉")
    }

    // MARK: - Encoding Tests

    func testEncodingFrictionlessResponse() throws {
        // Given
        let json = """
        {
            "indicator": "FINISH",
            "transaction_status": "Y",
            "cardholder_info": "Success"
        }
        """
        let originalResponse = try decode(json)

        // When
        let encodedJson = try encode(originalResponse)
        let decodedResponse = try decode(encodedJson)

        // Then
        XCTAssertEqual(originalResponse.indicator, decodedResponse.indicator)
        XCTAssertEqual(originalResponse.transactionStatus, decodedResponse.transactionStatus)
        XCTAssertEqual(originalResponse.cardholderInfo, decodedResponse.cardholderInfo)
        XCTAssertEqual(originalResponse.isFrictionless, decodedResponse.isFrictionless)
    }

    func testEncodingChallengeResponse() throws {
        // Given
        let json = """
        {
            "indicator": "CHALLENGE",
            "challenge": {
                "server_transaction_id": "server_txn_123",
                "acs_transaction_id": "txn_123",
                "acs_reference_number": "ref_456",
                "acs_rendering_type": {
                    "acsInterface": "01",
                    "acsUiTemplate": "01",
                    "deviceUserInterfaceMode": "01"
                },
                "acs_signed_content": "content_789"
            },
            "transaction_status": "C"
        }
        """
        let originalResponse = try decode(json)

        // When
        let encodedJson = try encode(originalResponse)
        let decodedResponse = try decode(encodedJson)

        // Then
        XCTAssertEqual(originalResponse.indicator, decodedResponse.indicator)
        XCTAssertEqual(originalResponse.transactionStatus, decodedResponse.transactionStatus)
        XCTAssertEqual(originalResponse.isChallenge, decodedResponse.isChallenge)
        XCTAssertNotNil(decodedResponse.challenge)
    }

    func testEncodingUsesCorrectCodingKeys() throws {
        // Given
        let json = """
        {
            "indicator": "FINISH",
            "transaction_status": "Y",
            "cardholder_info": "Success"
        }
        """
        let response = try decode(json)

        // When
        let encodedJson = try encode(response)

        // Then - Verify snake_case keys are used
        XCTAssertTrue(encodedJson.contains("\"transaction_status\""))
        XCTAssertTrue(encodedJson.contains("\"cardholder_info\""))

        // Verify camelCase keys are NOT used
        XCTAssertFalse(encodedJson.contains("\"transactionStatus\""))
        XCTAssertFalse(encodedJson.contains("\"cardholderInfo\""))
    }

    // MARK: - Round-Trip Tests

    func testRoundTripEncodingDecodingWithAllFields() throws {
        // Given
        let json = """
        {
            "indicator": "CHALLENGE",
            "challenge": {
                "server_transaction_id": "server_txn_test",
                "acs_transaction_id": "txn_test",
                "acs_reference_number": "ref_test",
                "acs_rendering_type": {
                    "acsInterface": "01",
                    "acsUiTemplate": "01",
                    "deviceUserInterfaceMode": "02"
                },
                "acs_signed_content": "content_test"
            },
            "transaction_status": "C",
            "cardholder_info": "Test message"
        }
        """
        let originalResponse = try decode(json)

        // When
        let encodedJson = try encode(originalResponse)
        let decodedResponse = try decode(encodedJson)

        // Then
        XCTAssertEqual(originalResponse.indicator, decodedResponse.indicator)
        XCTAssertEqual(originalResponse.transactionStatus, decodedResponse.transactionStatus)
        XCTAssertEqual(originalResponse.cardholderInfo, decodedResponse.cardholderInfo)
        XCTAssertEqual(originalResponse.isFrictionless, decodedResponse.isFrictionless)
        XCTAssertEqual(originalResponse.isChallenge, decodedResponse.isChallenge)
        XCTAssertEqual(originalResponse.isError, decodedResponse.isError)
    }

    func testRoundTripEncodingDecodingWithMinimalFields() throws {
        // Given
        let json = """
        {
            "indicator": "FINISH"
        }
        """
        let originalResponse = try decode(json)

        // When
        let encodedJson = try encode(originalResponse)
        let decodedResponse = try decode(encodedJson)

        // Then
        XCTAssertEqual(originalResponse.indicator, decodedResponse.indicator)
        XCTAssertNil(decodedResponse.challenge)
        XCTAssertNil(decodedResponse.transactionStatus)
        XCTAssertNil(decodedResponse.cardholderInfo)
    }

    // MARK: - Error Handling Tests

    func testDecodingFailsWithMissingIndicator() {
        // Given
        let json = """
        {
            "transaction_status": "Y",
            "cardholder_info": "Success"
        }
        """

        // Then
        XCTAssertThrowsError(try decode(json)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testDecodingFailsWithInvalidDataTypes() {
        let invalidJsons = [
            // Invalid indicator type
            """
            {
                "indicator": 123
            }
            """,
            // Invalid transaction_status type
            """
            {
                "indicator": "FINISH",
                "transaction_status": true
            }
            """,
            // Invalid cardholder_info type
            """
            {
                "indicator": "FINISH",
                "cardholder_info": 456
            }
            """,
            // Invalid challenge type
            """
            {
                "indicator": "CHALLENGE",
                "challenge": "not_an_object"
            }
            """,
        ]

        for invalidJson in invalidJsons {
            XCTAssertThrowsError(try decode(invalidJson), "Should fail for: \(invalidJson)")
        }
    }

    // MARK: - Edge Cases

    func testDecodingWithEmptyStrings() throws {
        // Given
        let json = """
        {
            "indicator": "",
            "transaction_status": "",
            "cardholder_info": ""
        }
        """

        // When
        let response = try decode(json)

        // Then
        XCTAssertEqual(response.indicator, "")
        XCTAssertEqual(response.transactionStatus, "")
        XCTAssertEqual(response.cardholderInfo, "")
        XCTAssertFalse(response.isFrictionless)
        XCTAssertFalse(response.isChallenge)
        XCTAssertFalse(response.isError)
    }

    func testDecodingWithVeryLongStrings() throws {
        // Given
        let longString = String(repeating: "a", count: 10_000)
        let json = """
        {
            "indicator": "FINISH",
            "transaction_status": "Y",
            "cardholder_info": "\(longString)"
        }
        """

        // When
        let response = try decode(json)

        // Then
        XCTAssertEqual(response.cardholderInfo?.count, 10_000)
    }

    func testMultipleIndicatorScenarios() throws {
        let scenarios: [(String, Bool, Bool, Bool)] = [
            ("FINISH", true, false, false),
            ("CHALLENGE", false, true, false),
            ("ERROR", false, false, true),
            ("unknown", false, false, false),
            ("", false, false, false),
        ]

        for (indicator, expectedFrictionless, expectedChallenge, expectedError) in scenarios {
            let json = """
            {
                "indicator": "\(indicator)"
            }
            """

            let response = try decode(json)
            XCTAssertEqual(response.isFrictionless, expectedFrictionless, "Failed for indicator: \(indicator)")
            XCTAssertEqual(response.isChallenge, expectedChallenge, "Failed for indicator: \(indicator)")
            XCTAssertEqual(response.isError, expectedError, "Failed for indicator: \(indicator)")
        }
    }
}
