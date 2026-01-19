//
//  JSONDecoderExtensionsTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

class JSONDecoderExtensionsTests: XCTestCase {
    var decoder: JSONDecoder!

    override func setUpWithError() throws {
        decoder = JSONDecoder()
    }

    override func tearDownWithError() throws {
        decoder = nil
    }

    // MARK: - Test Models

    private struct TestModel: Codable, Equatable {
        let id: String
        let name: String
        let value: Int
        let isActive: Bool
    }

    private struct ComplexTestModel: Codable, Equatable {
        let id: String
        let metadata: [String: String]
        let items: [TestModel]
        let optionalField: String?
    }

    // MARK: - Successful Decoding Tests

    func testDecodeIfPresentWithValidJSON() throws {
        // Given
        let testModel = TestModel(id: "123", name: "Test", value: 42, isActive: true)
        let validJSON = """
        {
            "id": "123",
            "name": "Test",
            "value": 42,
            "isActive": true
        }
        """.data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(TestModel.self, from: validJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, testModel)
    }

    func testDecodeIfPresentWithComplexModel() throws {
        // Given
        let complexJSON = """
        {
            "id": "complex_123",
            "metadata": {
                "key1": "value1",
                "key2": "value2"
            },
            "items": [
                {
                    "id": "item1",
                    "name": "First Item",
                    "value": 10,
                    "isActive": true
                },
                {
                    "id": "item2",
                    "name": "Second Item",
                    "value": 20,
                    "isActive": false
                }
            ],
            "optionalField": "present"
        }
        """.data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(ComplexTestModel.self, from: complexJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, "complex_123")
        XCTAssertEqual(result?.metadata["key1"], "value1")
        XCTAssertEqual(result?.items.count, 2)
        XCTAssertEqual(result?.items[0].name, "First Item")
        XCTAssertEqual(result?.optionalField, "present")
    }

    func testDecodeIfPresentWithOptionalFields() throws {
        // Given
        let jsonWithNullOptional = """
        {
            "id": "optional_test",
            "metadata": {},
            "items": [],
            "optionalField": null
        }
        """.data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(ComplexTestModel.self, from: jsonWithNullOptional)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, "optional_test")
        XCTAssertNil(result?.optionalField)
        XCTAssertTrue(result?.metadata.isEmpty ?? false)
        XCTAssertTrue(result?.items.isEmpty ?? false)
    }

    // MARK: - Failed Decoding Tests

    func testDecodeIfPresentWithInvalidJSON() throws {
        // Given
        let invalidJSON = "{ invalid json }".data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(TestModel.self, from: invalidJSON)

        // Then
        XCTAssertNil(result)
    }

    func testDecodeIfPresentWithMissingRequiredFields() throws {
        // Given
        let incompleteJSON = """
        {
            "id": "123",
            "name": "Test"
        }
        """.data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(TestModel.self, from: incompleteJSON)

        // Then
        XCTAssertNil(result)
    }

    func testDecodeIfPresentWithWrongDataTypes() throws {
        // Given
        let wrongTypesJSON = """
        {
            "id": "123",
            "name": "Test",
            "value": "not_a_number",
            "isActive": true
        }
        """.data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(TestModel.self, from: wrongTypesJSON)

        // Then
        XCTAssertNil(result)
    }

    func testDecodeIfPresentWithEmptyData() throws {
        // Given
        let emptyData = Data()

        // When
        let result = decoder.decodeIfPresent(TestModel.self, from: emptyData)

        // Then
        XCTAssertNil(result)
    }

    // MARK: - Built-in Types Tests

    func testDecodeIfPresentWithString() throws {
        // Given
        let stringJSON = "\"Hello World\"".data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(String.self, from: stringJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "Hello World")
    }

    func testDecodeIfPresentWithInt() throws {
        // Given
        let intJSON = "42".data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(Int.self, from: intJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 42)
    }

    func testDecodeIfPresentWithDouble() throws {
        // Given
        let doubleJSON = "3.14159".data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(Double.self, from: doubleJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 3.141_59, accuracy: 0.000_01)
    }

    func testDecodeIfPresentWithBool() throws {
        // Given
        let boolJSON = "true".data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(Bool.self, from: boolJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertTrue(result!)
    }

    func testDecodeIfPresentWithArray() throws {
        // Given
        let arrayJSON = "[1, 2, 3, 4, 5]".data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent([Int].self, from: arrayJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, [1, 2, 3, 4, 5])
    }

    func testDecodeIfPresentWithDictionary() throws {
        // Given
        let dictJSON = """
        {
            "key1": "value1",
            "key2": "value2",
            "key3": "value3"
        }
        """.data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent([String: String].self, from: dictJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?["key1"], "value1")
        XCTAssertEqual(result?["key2"], "value2")
        XCTAssertEqual(result?["key3"], "value3")
    }

    // MARK: - Edge Cases Tests

    func testDecodeIfPresentWithUnicodeCharacters() throws {
        // Given
        let unicodeJSON = """
        {
            "id": "unicode_test",
            "name": "测试 🎯 émojis",
            "value": 100,
            "isActive": true
        }
        """.data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(TestModel.self, from: unicodeJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "测试 🎯 émojis")
    }

    func testDecodeIfPresentWithLargeNumbers() throws {
        // Given
        let largeNumberJSON = """
        {
            "id": "large_test",
            "name": "Large Number Test",
            "value": 2147483647,
            "isActive": false
        }
        """.data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(TestModel.self, from: largeNumberJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.value, 2_147_483_647)
    }

    func testDecodeIfPresentWithMinimalJSON() throws {
        // Given
        let minimalJSON = "{}".data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent([String: String].self, from: minimalJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.isEmpty ?? false)
    }

    func testDecodeIfPresentWithNullValue() throws {
        // Given
        let nullJSON = "null".data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(String?.self, from: nullJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNil(result!)
    }

    // MARK: - Real-world Gr4vy Model Tests

    func testDecodeIfPresentWithGr4vyCardDetails() throws {
        // Given
        let cardDetailsJSON = """
        {
            "type": "card_details",
            "id": "cd_test_123",
            "card_type": "credit",
            "scheme": "visa",
            "scheme_icon_url": "https://example.com/visa.png",
            "country": "US",
            "required_fields": null
        }
        """.data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(Gr4vyCardDetailsResponse.self, from: cardDetailsJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, "cd_test_123")
        XCTAssertEqual(result?.scheme, "visa")
        XCTAssertEqual(result?.cardType, "credit")
        XCTAssertEqual(result?.country, "US")
    }

    func testDecodeIfPresentWithValidGr4vyCardDetails() throws {
        // Given - This is actually valid JSON (has required id field)
        let validCardDetailsJSON = """
        {
            "type": "card_details",
            "id": "cd_test_123"
        }
        """.data(using: .utf8)!

        // When
        let result = decoder.decodeIfPresent(Gr4vyCardDetailsResponse.self, from: validCardDetailsJSON)

        // Then - Should decode successfully since id is present
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, "cd_test_123")
        XCTAssertEqual(result?.type, "card_details")
    }

    // MARK: - Comparison with Standard Decode Tests

    func testDecodeIfPresentVsStandardDecodeSuccess() throws {
        // Given
        let validJSON = """
        {
            "id": "comparison_test",
            "name": "Comparison Test",
            "value": 123,
            "isActive": true
        }
        """.data(using: .utf8)!

        // When
        let standardResult = try? decoder.decode(TestModel.self, from: validJSON)
        let extensionResult = decoder.decodeIfPresent(TestModel.self, from: validJSON)

        // Then
        XCTAssertNotNil(standardResult)
        XCTAssertNotNil(extensionResult)
        XCTAssertEqual(standardResult, extensionResult)
    }

    func testDecodeIfPresentVsStandardDecodeFailure() throws {
        // Given
        let invalidJSON = "{ invalid json }".data(using: .utf8)!

        // When
        var standardThrew = false
        do {
            _ = try decoder.decode(TestModel.self, from: invalidJSON)
        } catch {
            standardThrew = true
        }

        let extensionResult = decoder.decodeIfPresent(TestModel.self, from: invalidJSON)

        // Then
        XCTAssertTrue(standardThrew, "Standard decode should throw an error")
        XCTAssertNil(extensionResult, "Extension should return nil instead of throwing")
    }

    // MARK: - Configuration Tests

    func testDecodeIfPresentWithCustomDateDecodingStrategy() throws {
        // Given
        struct DateModel: Codable, Equatable {
            let date: Date
        }

        let customDecoder = JSONDecoder()
        customDecoder.dateDecodingStrategy = .iso8601

        let dateJSON = """
        {
            "date": "2023-12-25T10:30:00Z"
        }
        """.data(using: .utf8)!

        // When
        let result = customDecoder.decodeIfPresent(DateModel.self, from: dateJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.date)
    }

    func testDecodeIfPresentWithCustomKeyDecodingStrategy() throws {
        // Given
        struct SnakeCaseModel: Codable, Equatable {
            let firstName: String
            let lastName: String
        }

        let customDecoder = JSONDecoder()
        customDecoder.keyDecodingStrategy = .convertFromSnakeCase

        let snakeCaseJSON = """
        {
            "first_name": "John",
            "last_name": "Doe"
        }
        """.data(using: .utf8)!

        // When
        let result = customDecoder.decodeIfPresent(SnakeCaseModel.self, from: snakeCaseJSON)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstName, "John")
        XCTAssertEqual(result?.lastName, "Doe")
    }
}
