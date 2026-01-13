//
//  Gr4vyVersioningResponseTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyVersioningResponseTests: XCTestCase {
    // MARK: - Helpers
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private func decode(_ json: String) throws -> Gr4vyVersioningResponse {
        try decoder.decode(Gr4vyVersioningResponse.self, from: Data(json.utf8))
    }

    private func encode(_ response: Gr4vyVersioningResponse) throws -> String {
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
            "directory_server_id": "ds-12345",
            "message_version": "2.2.0",
            "api_key": "ak_test_1234567890"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.directoryServerId, "ds-12345")
        XCTAssertEqual(response.messageVersion, "2.2.0")
        XCTAssertEqual(response.apiKey, "ak_test_1234567890")
    }

    func testDecodingWithEmptyStrings() throws {
        let json = """
        {
            "directory_server_id": "",
            "message_version": "",
            "api_key": ""
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.directoryServerId, "")
        XCTAssertEqual(response.messageVersion, "")
        XCTAssertEqual(response.apiKey, "")
    }

    func testDecodingWithDifferentVersionFormats() throws {
        let versionFormats = [
            "2.1.0",
            "2.2.0",
            "1.0.0",
            "3.0.0-beta",
            "2.2.0.1",
        ]

        for version in versionFormats {
            let json = """
            {
                "directory_server_id": "ds-test",
                "message_version": "\(version)",
                "api_key": "ak_test"
            }
            """

            let response = try decode(json)
            XCTAssertEqual(response.messageVersion, version)
        }
    }

    func testDecodingWithDifferentDirectoryServerIds() throws {
        let directoryServerIds = [
            "ds-visa-12345",
            "ds-mastercard-67890",
            "ds-amex-abcde",
            "ds-discover-fghij",
            "ds-jcb-klmno",
        ]

        for dsId in directoryServerIds {
            let json = """
            {
                "directory_server_id": "\(dsId)",
                "message_version": "2.2.0",
                "api_key": "ak_test"
            }
            """

            let response = try decode(json)
            XCTAssertEqual(response.directoryServerId, dsId)
        }
    }

    func testDecodingWithDifferentApiKeyFormats() throws {
        let apiKeys = [
            "ak_test_1234567890",
            "ak_live_abcdefghij",
            "ak_sandbox_9876543210",
            "test-key-123",
            "Bearer abc123",
        ]

        for apiKey in apiKeys {
            let json = """
            {
                "directory_server_id": "ds-test",
                "message_version": "2.2.0",
                "api_key": "\(apiKey)"
            }
            """

            let response = try decode(json)
            XCTAssertEqual(response.apiKey, apiKey)
        }
    }

    func testDecodingFailsWithMissingRequiredFields() {
        let invalidJsons = [
            // Missing directory_server_id
            """
            {
                "message_version": "2.2.0",
                "api_key": "ak_test"
            }
            """,
            // Missing message_version
            """
            {
                "directory_server_id": "ds-test",
                "api_key": "ak_test"
            }
            """,
            // Missing api_key
            """
            {
                "directory_server_id": "ds-test",
                "message_version": "2.2.0"
            }
            """,
            // Empty JSON
            """
            {}
            """,
        ]

        for invalidJson in invalidJsons {
            XCTAssertThrowsError(try decode(invalidJson), "Should throw error for missing required field")
        }
    }

    func testDecodingFailsWithInvalidDataTypes() {
        let invalidJsons = [
            // Invalid directory_server_id type (number instead of string)
            """
            {
                "directory_server_id": 123,
                "message_version": "2.2.0",
                "api_key": "ak_test"
            }
            """,
            // Invalid message_version type (boolean instead of string)
            """
            {
                "directory_server_id": "ds-test",
                "message_version": true,
                "api_key": "ak_test"
            }
            """,
            // Invalid api_key type (object instead of string)
            """
            {
                "directory_server_id": "ds-test",
                "message_version": "2.2.0",
                "api_key": {"key": "value"}
            }
            """,
        ]

        for invalidJson in invalidJsons {
            XCTAssertThrowsError(try decode(invalidJson), "Should throw error for invalid data type")
        }
    }

    func testDecodingFailsWithNullValues() {
        let invalidJsons = [
            // Null directory_server_id
            """
            {
                "directory_server_id": null,
                "message_version": "2.2.0",
                "api_key": "ak_test"
            }
            """,
            // Null message_version
            """
            {
                "directory_server_id": "ds-test",
                "message_version": null,
                "api_key": "ak_test"
            }
            """,
            // Null api_key
            """
            {
                "directory_server_id": "ds-test",
                "message_version": "2.2.0",
                "api_key": null
            }
            """,
        ]

        for invalidJson in invalidJsons {
            XCTAssertThrowsError(try decode(invalidJson), "Should throw error for null value")
        }
    }

    // MARK: - JSON Encoding Tests

    func testEncodingWithAllFields() throws {
        let json = """
        {
            "directory_server_id": "ds-encode-test",
            "message_version": "2.2.0",
            "api_key": "ak_encode_test"
        }
        """

        let originalResponse = try decode(json)
        let encodedJson = try encode(originalResponse)
        let decodedResponse = try decode(encodedJson)

        // Verify round-trip encoding/decoding
        XCTAssertEqual(originalResponse.directoryServerId, decodedResponse.directoryServerId)
        XCTAssertEqual(originalResponse.messageVersion, decodedResponse.messageVersion)
        XCTAssertEqual(originalResponse.apiKey, decodedResponse.apiKey)
    }

    func testEncodingUsesCorrectCodingKeys() throws {
        let json = """
        {
            "directory_server_id": "ds-coding-keys",
            "message_version": "2.2.0",
            "api_key": "ak_coding_keys"
        }
        """

        let response = try decode(json)
        let encodedJson = try encode(response)

        // Verify that the encoded JSON uses snake_case keys
        XCTAssertTrue(encodedJson.contains("\"directory_server_id\""))
        XCTAssertTrue(encodedJson.contains("\"message_version\""))
        XCTAssertTrue(encodedJson.contains("\"api_key\""))

        // Verify that camelCase keys are NOT used
        XCTAssertFalse(encodedJson.contains("\"directoryServerId\""))
        XCTAssertFalse(encodedJson.contains("\"messageVersion\""))
        XCTAssertFalse(encodedJson.contains("\"apiKey\""))
    }

    func testEncodingWithEmptyStrings() throws {
        let json = """
        {
            "directory_server_id": "",
            "message_version": "",
            "api_key": ""
        }
        """

        let originalResponse = try decode(json)
        let encodedJson = try encode(originalResponse)
        let decodedResponse = try decode(encodedJson)

        XCTAssertEqual(decodedResponse.directoryServerId, "")
        XCTAssertEqual(decodedResponse.messageVersion, "")
        XCTAssertEqual(decodedResponse.apiKey, "")
    }

    // MARK: - Edge Cases Tests

    func testDecodingWithSpecialCharacters() throws {
        let json = """
        {
            "directory_server_id": "ds-test-123_456",
            "message_version": "2.2.0-beta+build.123",
            "api_key": "ak_test_!@#$%^&*()"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.directoryServerId, "ds-test-123_456")
        XCTAssertEqual(response.messageVersion, "2.2.0-beta+build.123")
        XCTAssertEqual(response.apiKey, "ak_test_!@#$%^&*()")
    }

    func testDecodingWithUnicodeCharacters() throws {
        let json = """
        {
            "directory_server_id": "ds-测试",
            "message_version": "2.2.0-版本",
            "api_key": "ak_test_🔑"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.directoryServerId, "ds-测试")
        XCTAssertEqual(response.messageVersion, "2.2.0-版本")
        XCTAssertEqual(response.apiKey, "ak_test_🔑")
    }

    func testDecodingWithVeryLongStrings() throws {
        let longString = String(repeating: "a", count: 1_000)
        let json = """
        {
            "directory_server_id": "\(longString)",
            "message_version": "\(longString)",
            "api_key": "\(longString)"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.directoryServerId, longString)
        XCTAssertEqual(response.messageVersion, longString)
        XCTAssertEqual(response.apiKey, longString)
    }

    func testDecodingWithWhitespace() throws {
        let json = """
        {
            "directory_server_id": "  ds-test  ",
            "message_version": "  2.2.0  ",
            "api_key": "  ak_test  "
        }
        """

        let response = try decode(json)

        // Whitespace should be preserved
        XCTAssertEqual(response.directoryServerId, "  ds-test  ")
        XCTAssertEqual(response.messageVersion, "  2.2.0  ")
        XCTAssertEqual(response.apiKey, "  ak_test  ")
    }

    func testDecodingWithNewlines() throws {
        let json = """
        {
            "directory_server_id": "ds\\ntest",
            "message_version": "2.2.0\\nversion",
            "api_key": "ak\\ntest"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.directoryServerId, "ds\ntest")
        XCTAssertEqual(response.messageVersion, "2.2.0\nversion")
        XCTAssertEqual(response.apiKey, "ak\ntest")
    }

    func testDecodingWithEscapedCharacters() throws {
        let json = """
        {
            "directory_server_id": "ds-test\\"quoted\\"",
            "message_version": "2.2.0\\/version",
            "api_key": "ak_test\\\\backslash"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.directoryServerId, "ds-test\"quoted\"")
        XCTAssertEqual(response.messageVersion, "2.2.0/version")
        XCTAssertEqual(response.apiKey, "ak_test\\backslash")
    }

    // MARK: - Round-Trip Tests

    func testRoundTripEncodingDecodingWithVariousCombinations() throws {
        let testCases: [(String, String)] = [
            ("minimal", """
            {
                "directory_server_id": "ds-test",
                "message_version": "2.2.0",
                "api_key": "ak_test"
            }
            """),
            ("with_numbers", """
            {
                "directory_server_id": "ds-12345",
                "message_version": "2.2.0",
                "api_key": "ak_67890"
            }
            """),
            ("with_special_chars", """
            {
                "directory_server_id": "ds-test_123-456",
                "message_version": "2.2.0-beta",
                "api_key": "ak_test_key"
            }
            """),
            ("with_long_values", """
            {
                "directory_server_id": "ds-very-long-directory-server-id-with-many-characters",
                "message_version": "2.2.0-beta.1+build.1234567890",
                "api_key": "ak_very_long_api_key_with_many_characters_1234567890"
            }
            """),
        ]

        for (testName, jsonString) in testCases {
            let originalResponse = try decode(jsonString)
            let encodedJson = try encode(originalResponse)
            let decodedResponse = try decode(encodedJson)

            XCTAssertEqual(originalResponse.directoryServerId, decodedResponse.directoryServerId, "Failed for test case: \(testName)")
            XCTAssertEqual(originalResponse.messageVersion, decodedResponse.messageVersion, "Failed for test case: \(testName)")
            XCTAssertEqual(originalResponse.apiKey, decodedResponse.apiKey, "Failed for test case: \(testName)")
        }
    }

    func testInvalidJSONStructures() {
        let invalidJsons = [
            "invalid json",
            "[]",
            "null",
            "\"string\"",
            "123",
            "true",
            "{\"directory_server_id\": []}",
            "{\"message_version\": {}}",
            "{\"api_key\": 123}",
        ]

        for invalidJson in invalidJsons {
            XCTAssertThrowsError(try decode(invalidJson), "Should throw error for: \(invalidJson)")
        }
    }

    // MARK: - Realistic Scenario Tests

    func testDecodingVisaResponse() throws {
        let json = """
        {
            "directory_server_id": "A000000003",
            "message_version": "2.2.0",
            "api_key": "ak_visa_prod_abc123"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.directoryServerId, "A000000003")
        XCTAssertEqual(response.messageVersion, "2.2.0")
        XCTAssertEqual(response.apiKey, "ak_visa_prod_abc123")
    }

    func testDecodingMastercardResponse() throws {
        let json = """
        {
            "directory_server_id": "A000000004",
            "message_version": "2.1.0",
            "api_key": "ak_mastercard_prod_xyz789"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.directoryServerId, "A000000004")
        XCTAssertEqual(response.messageVersion, "2.1.0")
        XCTAssertEqual(response.apiKey, "ak_mastercard_prod_xyz789")
    }

    func testDecodingAmexResponse() throws {
        let json = """
        {
            "directory_server_id": "A000000025",
            "message_version": "2.2.0",
            "api_key": "ak_amex_prod_def456"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.directoryServerId, "A000000025")
        XCTAssertEqual(response.messageVersion, "2.2.0")
        XCTAssertEqual(response.apiKey, "ak_amex_prod_def456")
    }

    func testDecodingSandboxResponse() throws {
        let json = """
        {
            "directory_server_id": "ds-sandbox-test",
            "message_version": "2.2.0",
            "api_key": "ak_sandbox_test_123"
        }
        """

        let response = try decode(json)

        XCTAssertEqual(response.directoryServerId, "ds-sandbox-test")
        XCTAssertEqual(response.messageVersion, "2.2.0")
        XCTAssertEqual(response.apiKey, "ak_sandbox_test_123")
    }
}
