//
//  Gr4vyThreeDSUiCustomizationMapperTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import ThreeDS_SDK
import XCTest

final class Gr4vyThreeDSUiCustomizationMapperTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Map Function Tests

    func testMapWithNilInput() {
        // Given
        let input: Gr4vyThreeDSUiCustomizationMap? = nil

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNil(result)
    }

    func testMapWithEmptyCustomizationMap() {
        // Given - Map with no customizations
        let input = Gr4vyThreeDSUiCustomizationMap()

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNil(result, "Empty customization map should return nil")
    }

    func testMapWithDefaultCustomizationOnly() {
        // Given
        let defaultCustomization = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(
                textColorHex: "#FFFFFF",
                backgroundColorHex: "#007AFF"
            )
        )
        let input = Gr4vyThreeDSUiCustomizationMap(default: defaultCustomization)

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?["DEFAULT"])
        XCTAssertNil(result?["DARK"])
        XCTAssertEqual(result?.count, 1)
    }

    func testMapWithDarkCustomizationOnly() {
        // Given
        let darkCustomization = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(
                textColorHex: "#FFFFFF",
                backgroundColorHex: "#000000"
            )
        )
        let input = Gr4vyThreeDSUiCustomizationMap(dark: darkCustomization)

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNil(result?["DEFAULT"])
        XCTAssertNotNil(result?["DARK"])
        XCTAssertEqual(result?.count, 1)
    }

    func testMapWithBothDefaultAndDarkCustomizations() {
        // Given
        let defaultCustomization = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(
                textColorHex: "#000000",
                backgroundColorHex: "#FFFFFF"
            )
        )
        let darkCustomization = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(
                textColorHex: "#FFFFFF",
                backgroundColorHex: "#000000"
            )
        )
        let input = Gr4vyThreeDSUiCustomizationMap(
            default: defaultCustomization,
            dark: darkCustomization
        )

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?["DEFAULT"])
        XCTAssertNotNil(result?["DARK"])
        XCTAssertEqual(result?.count, 2)
    }

    func testMapWithCompleteCustomization() {
        // Given
        let customization = Gr4vyThreeDSUiCustomization(
            label: Gr4vyThreeDSLabelCustomization(
                textFontSize: 14,
                textColorHex: "#333333"
            ),
            toolbar: Gr4vyThreeDSToolbarCustomization(
                textColorHex: "#FFFFFF",
                backgroundColorHex: "#007AFF",
                headerText: "Secure Payment"
            ),
            textBox: Gr4vyThreeDSTextBoxCustomization(
                borderWidth: 1,
                borderColorHex: "#CCCCCC",
                cornerRadius: 4
            ),
            view: Gr4vyThreeDSViewCustomization(
                challengeViewBackgroundColorHex: "#FFFFFF"
            ),
            buttons: [
                .submit: Gr4vyThreeDSButtonCustomization(
                    textColorHex: "#FFFFFF",
                    backgroundColorHex: "#007AFF",
                    cornerRadius: 8
                ),
                .cancel: Gr4vyThreeDSButtonCustomization(
                    textColorHex: "#FF0000",
                    backgroundColorHex: "#FFFFFF",
                    cornerRadius: 8
                ),
            ]
        )
        let input = Gr4vyThreeDSUiCustomizationMap(default: customization)

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?["DEFAULT"])
        
        // Verify the UiCustomization object was created
        let uiCustomization = result?["DEFAULT"]
        XCTAssertNotNil(uiCustomization)
    }

    func testMapWithAllButtonTypes() {
        // Given
        let allButtons: [Gr4vyThreeDSButtonType: Gr4vyThreeDSButtonCustomization] = [
            .submit: Gr4vyThreeDSButtonCustomization(textColorHex: "#FFFFFF"),
            .continue: Gr4vyThreeDSButtonCustomization(textColorHex: "#FFFFFF"),
            .next: Gr4vyThreeDSButtonCustomization(textColorHex: "#FFFFFF"),
            .resend: Gr4vyThreeDSButtonCustomization(textColorHex: "#007AFF"),
            .openOobApp: Gr4vyThreeDSButtonCustomization(textColorHex: "#007AFF"),
            .addCardholder: Gr4vyThreeDSButtonCustomization(textColorHex: "#007AFF"),
            .cancel: Gr4vyThreeDSButtonCustomization(textColorHex: "#FF0000"),
        ]
        let customization = Gr4vyThreeDSUiCustomization(buttons: allButtons)
        let input = Gr4vyThreeDSUiCustomizationMap(default: customization)

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?["DEFAULT"])
    }

    func testMapWithNativeFontCustomization() {
        // Given
        let customization = Gr4vyThreeDSUiCustomization(
            label: Gr4vyThreeDSLabelCustomization(
                nativeFontName: "HelveticaNeue",
                nativeFontSize: 14,
                textColorHex: "#000000"
            ),
            toolbar: Gr4vyThreeDSToolbarCustomization(
                nativeFontName: "HelveticaNeue-Bold",
                nativeFontSize: 16,
                textColorHex: "#FFFFFF"
            )
        )
        let input = Gr4vyThreeDSUiCustomizationMap(default: customization)

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?["DEFAULT"])
    }

    func testMapWithTextBoxBorderCustomization() {
        // Given
        let customization = Gr4vyThreeDSUiCustomization(
            textBox: Gr4vyThreeDSTextBoxCustomization(
                textFontSize: 14,
                textColorHex: "#000000",
                borderWidth: 2,
                borderColorHex: "#007AFF",
                cornerRadius: 8
            )
        )
        let input = Gr4vyThreeDSUiCustomizationMap(default: customization)

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?["DEFAULT"])
    }

    func testMapWithViewBackgroundColors() {
        // Given
        let customization = Gr4vyThreeDSUiCustomization(
            view: Gr4vyThreeDSViewCustomization(
                challengeViewBackgroundColorHex: "#FFFFFF",
                progressViewBackgroundColorHex: "#F0F0F0"
            )
        )
        let input = Gr4vyThreeDSUiCustomizationMap(default: customization)

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?["DEFAULT"])
    }

    func testMapWithLabelHeadingCustomization() {
        // Given
        let customization = Gr4vyThreeDSUiCustomization(
            label: Gr4vyThreeDSLabelCustomization(
                textFontSize: 14,
                textColorHex: "#666666",
                headingTextFontSize: 18,
                headingTextColorHex: "#000000"
            )
        )
        let input = Gr4vyThreeDSUiCustomizationMap(default: customization)

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?["DEFAULT"])
    }

    func testMapWithToolbarText() {
        // Given
        let customization = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(
                headerText: "Secure Checkout",
                buttonText: "Cancel"
            )
        )
        let input = Gr4vyThreeDSUiCustomizationMap(default: customization)

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?["DEFAULT"])
    }

    // MARK: - Edge Cases

    func testMapWithEmptyButtonsDictionary() {
        // Given
        let customization = Gr4vyThreeDSUiCustomization(
            buttons: [:]
        )
        let input = Gr4vyThreeDSUiCustomizationMap(default: customization)

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        // Empty buttons dictionary should not create a customization
        XCTAssertNil(result, "Empty buttons dictionary should result in nil")
    }

    func testMapWithOnlyEmptyCustomizations() {
        // Given - Customization with all nil values
        let customization = Gr4vyThreeDSUiCustomization(
            label: nil,
            toolbar: nil,
            textBox: nil,
            view: nil,
            buttons: nil
        )
        let input = Gr4vyThreeDSUiCustomizationMap(default: customization)

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNil(result, "Customization with all nil components should return nil")
    }

    func testMapKeysAreCorrect() {
        // Given
        let defaultCustom = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(textColorHex: "#000000")
        )
        let darkCustom = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(textColorHex: "#FFFFFF")
        )
        let input = Gr4vyThreeDSUiCustomizationMap(
            default: defaultCustom,
            dark: darkCustom
        )

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNotNil(result)
        // Keys should be "DEFAULT" and "DARK" (uppercase)
        XCTAssertTrue(result?.keys.contains("DEFAULT") ?? false)
        XCTAssertTrue(result?.keys.contains("DARK") ?? false)
        XCTAssertFalse(result?.keys.contains("default") ?? true)
        XCTAssertFalse(result?.keys.contains("dark") ?? true)
    }

    func testMapWithVariousHexColorFormats() {
        // Test that various hex color formats are accepted
        let colors = ["#FFFFFF", "#000000", "#FF0000", "#00FF00", "#0000FF", "#123ABC"]

        for color in colors {
            let customization = Gr4vyThreeDSUiCustomization(
                toolbar: Gr4vyThreeDSToolbarCustomization(
                    textColorHex: color,
                    backgroundColorHex: color
                )
            )
            let input = Gr4vyThreeDSUiCustomizationMap(default: customization)

            let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

            XCTAssertNotNil(result, "Should handle color: \(color)")
        }
    }

    func testMapDoesNotModifyOriginalInput() {
        // Given
        let customization = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(
                textColorHex: "#FFFFFF",
                backgroundColorHex: "#007AFF"
            )
        )
        let input = Gr4vyThreeDSUiCustomizationMap(default: customization)

        // When
        let result = Gr4vyThreeDSUiCustomizationMapper.map(input)

        // Then
        XCTAssertNotNil(result)
        // Original input should remain unchanged
        XCTAssertNotNil(input.default)
        XCTAssertEqual(input.default?.toolbar?.textColorHex, "#FFFFFF")
        XCTAssertEqual(input.default?.toolbar?.backgroundColorHex, "#007AFF")
    }
}
