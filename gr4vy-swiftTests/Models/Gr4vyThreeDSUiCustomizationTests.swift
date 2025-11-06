//
//  Gr4vyThreeDSUiCustomizationTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyThreeDSUiCustomizationTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Gr4vyThreeDSAppearance Tests

    func testGr4vyThreeDSAppearanceDefaultCase() {
        // Given
        let appearance = Gr4vyThreeDSAppearance.default

        // Then
        XCTAssertEqual(appearance, .default)
    }

    func testGr4vyThreeDSAppearanceDarkCase() {
        // Given
        let appearance = Gr4vyThreeDSAppearance.dark

        // Then
        XCTAssertEqual(appearance, .dark)
    }

    // MARK: - Gr4vyThreeDSButtonType Tests

    func testGr4vyThreeDSButtonTypeAllCases() {
        // Test all button types and their raw values
        XCTAssertEqual(Gr4vyThreeDSButtonType.submit.rawValue, "submit")
        XCTAssertEqual(Gr4vyThreeDSButtonType.continue.rawValue, "continue")
        XCTAssertEqual(Gr4vyThreeDSButtonType.next.rawValue, "next")
        XCTAssertEqual(Gr4vyThreeDSButtonType.resend.rawValue, "resend")
        XCTAssertEqual(Gr4vyThreeDSButtonType.openOobApp.rawValue, "openOobApp")
        XCTAssertEqual(Gr4vyThreeDSButtonType.addCardholder.rawValue, "addCardholder")
        XCTAssertEqual(Gr4vyThreeDSButtonType.cancel.rawValue, "cancel")
    }

    func testGr4vyThreeDSButtonTypeFromRawValue() {
        // Test creation from raw values
        XCTAssertEqual(Gr4vyThreeDSButtonType(rawValue: "submit"), .submit)
        XCTAssertEqual(Gr4vyThreeDSButtonType(rawValue: "continue"), .continue)
        XCTAssertEqual(Gr4vyThreeDSButtonType(rawValue: "next"), .next)
        XCTAssertEqual(Gr4vyThreeDSButtonType(rawValue: "resend"), .resend)
        XCTAssertEqual(Gr4vyThreeDSButtonType(rawValue: "openOobApp"), .openOobApp)
        XCTAssertEqual(Gr4vyThreeDSButtonType(rawValue: "addCardholder"), .addCardholder)
        XCTAssertEqual(Gr4vyThreeDSButtonType(rawValue: "cancel"), .cancel)

        // Test invalid raw value
        XCTAssertNil(Gr4vyThreeDSButtonType(rawValue: "invalid"))
    }

    func testGr4vyThreeDSButtonTypeHashable() {
        // Test that button types can be used in dictionaries
        var buttonDict: [Gr4vyThreeDSButtonType: String] = [:]
        buttonDict[.submit] = "Submit Button"
        buttonDict[.cancel] = "Cancel Button"

        XCTAssertEqual(buttonDict[.submit], "Submit Button")
        XCTAssertEqual(buttonDict[.cancel], "Cancel Button")
    }

    // MARK: - Gr4vyThreeDSButtonCustomization Tests

    func testGr4vyThreeDSButtonCustomizationInitializationWithAllParameters() {
        // Given
        let customization = Gr4vyThreeDSButtonCustomization(
            textFontName: "HelveticaNeue-Bold",
            textFontSize: 16,
            nativeFontName: "System-Bold",
            nativeFontSize: 16,
            textColorHex: "#FFFFFF",
            backgroundColorHex: "#007AFF",
            cornerRadius: 8
        )

        // Then
        XCTAssertEqual(customization.textFontName, "HelveticaNeue-Bold")
        XCTAssertEqual(customization.textFontSize, 16)
        XCTAssertEqual(customization.nativeFontName, "System-Bold")
        XCTAssertEqual(customization.nativeFontSize, 16)
        XCTAssertEqual(customization.textColorHex, "#FFFFFF")
        XCTAssertEqual(customization.backgroundColorHex, "#007AFF")
        XCTAssertEqual(customization.cornerRadius, 8)
    }

    func testGr4vyThreeDSButtonCustomizationInitializationWithDefaultParameters() {
        // Given
        let customization = Gr4vyThreeDSButtonCustomization()

        // Then
        XCTAssertNil(customization.textFontName)
        XCTAssertNil(customization.textFontSize)
        XCTAssertNil(customization.nativeFontName)
        XCTAssertNil(customization.nativeFontSize)
        XCTAssertNil(customization.textColorHex)
        XCTAssertNil(customization.backgroundColorHex)
        XCTAssertNil(customization.cornerRadius)
    }

    func testGr4vyThreeDSButtonCustomizationPartialInitialization() {
        // Given
        let customization = Gr4vyThreeDSButtonCustomization(
            textFontSize: 18,
            textColorHex: "#000000",
            cornerRadius: 4
        )

        // Then
        XCTAssertNil(customization.textFontName)
        XCTAssertEqual(customization.textFontSize, 18)
        XCTAssertNil(customization.nativeFontName)
        XCTAssertNil(customization.nativeFontSize)
        XCTAssertEqual(customization.textColorHex, "#000000")
        XCTAssertNil(customization.backgroundColorHex)
        XCTAssertEqual(customization.cornerRadius, 4)
    }

    // MARK: - Gr4vyThreeDSLabelCustomization Tests

    func testGr4vyThreeDSLabelCustomizationInitializationWithAllParameters() {
        // Given
        let customization = Gr4vyThreeDSLabelCustomization(
            textFontName: "Helvetica",
            textFontSize: 14,
            nativeFontName: "System",
            nativeFontSize: 14,
            textColorHex: "#333333",
            headingTextFontName: "Helvetica-Bold",
            headingTextFontSize: 18,
            headingNativeFontName: "System-Bold",
            headingNativeFontSize: 18,
            headingTextColorHex: "#000000"
        )

        // Then
        XCTAssertEqual(customization.textFontName, "Helvetica")
        XCTAssertEqual(customization.textFontSize, 14)
        XCTAssertEqual(customization.nativeFontName, "System")
        XCTAssertEqual(customization.nativeFontSize, 14)
        XCTAssertEqual(customization.textColorHex, "#333333")
        XCTAssertEqual(customization.headingTextFontName, "Helvetica-Bold")
        XCTAssertEqual(customization.headingTextFontSize, 18)
        XCTAssertEqual(customization.headingNativeFontName, "System-Bold")
        XCTAssertEqual(customization.headingNativeFontSize, 18)
        XCTAssertEqual(customization.headingTextColorHex, "#000000")
    }

    func testGr4vyThreeDSLabelCustomizationInitializationWithDefaultParameters() {
        // Given
        let customization = Gr4vyThreeDSLabelCustomization()

        // Then
        XCTAssertNil(customization.textFontName)
        XCTAssertNil(customization.textFontSize)
        XCTAssertNil(customization.nativeFontName)
        XCTAssertNil(customization.nativeFontSize)
        XCTAssertNil(customization.textColorHex)
        XCTAssertNil(customization.headingTextFontName)
        XCTAssertNil(customization.headingTextFontSize)
        XCTAssertNil(customization.headingNativeFontName)
        XCTAssertNil(customization.headingNativeFontSize)
        XCTAssertNil(customization.headingTextColorHex)
    }

    func testGr4vyThreeDSLabelCustomizationBodyTextOnly() {
        // Given
        let customization = Gr4vyThreeDSLabelCustomization(
            textFontName: "Helvetica",
            textFontSize: 14,
            textColorHex: "#666666"
        )

        // Then
        XCTAssertEqual(customization.textFontName, "Helvetica")
        XCTAssertEqual(customization.textFontSize, 14)
        XCTAssertEqual(customization.textColorHex, "#666666")
        XCTAssertNil(customization.headingTextFontName)
        XCTAssertNil(customization.headingTextFontSize)
        XCTAssertNil(customization.headingTextColorHex)
    }

    func testGr4vyThreeDSLabelCustomizationHeadingTextOnly() {
        // Given
        let customization = Gr4vyThreeDSLabelCustomization(
            headingTextFontName: "Helvetica-Bold",
            headingTextFontSize: 20,
            headingTextColorHex: "#000000"
        )

        // Then
        XCTAssertNil(customization.textFontName)
        XCTAssertNil(customization.textFontSize)
        XCTAssertNil(customization.textColorHex)
        XCTAssertEqual(customization.headingTextFontName, "Helvetica-Bold")
        XCTAssertEqual(customization.headingTextFontSize, 20)
        XCTAssertEqual(customization.headingTextColorHex, "#000000")
    }

    // MARK: - Gr4vyThreeDSToolbarCustomization Tests

    func testGr4vyThreeDSToolbarCustomizationInitializationWithAllParameters() {
        // Given
        let customization = Gr4vyThreeDSToolbarCustomization(
            textFontName: "Helvetica",
            textFontSize: 16,
            nativeFontName: "System",
            nativeFontSize: 16,
            textColorHex: "#FFFFFF",
            backgroundColorHex: "#007AFF",
            headerText: "Secure Checkout",
            buttonText: "Cancel"
        )

        // Then
        XCTAssertEqual(customization.textFontName, "Helvetica")
        XCTAssertEqual(customization.textFontSize, 16)
        XCTAssertEqual(customization.nativeFontName, "System")
        XCTAssertEqual(customization.nativeFontSize, 16)
        XCTAssertEqual(customization.textColorHex, "#FFFFFF")
        XCTAssertEqual(customization.backgroundColorHex, "#007AFF")
        XCTAssertEqual(customization.headerText, "Secure Checkout")
        XCTAssertEqual(customization.buttonText, "Cancel")
    }

    func testGr4vyThreeDSToolbarCustomizationInitializationWithDefaultParameters() {
        // Given
        let customization = Gr4vyThreeDSToolbarCustomization()

        // Then
        XCTAssertNil(customization.textFontName)
        XCTAssertNil(customization.textFontSize)
        XCTAssertNil(customization.nativeFontName)
        XCTAssertNil(customization.nativeFontSize)
        XCTAssertNil(customization.textColorHex)
        XCTAssertNil(customization.backgroundColorHex)
        XCTAssertNil(customization.headerText)
        XCTAssertNil(customization.buttonText)
    }

    func testGr4vyThreeDSToolbarCustomizationTextOnly() {
        // Given
        let customization = Gr4vyThreeDSToolbarCustomization(
            headerText: "Authentication Required",
            buttonText: "Close"
        )

        // Then
        XCTAssertEqual(customization.headerText, "Authentication Required")
        XCTAssertEqual(customization.buttonText, "Close")
        XCTAssertNil(customization.textFontName)
        XCTAssertNil(customization.backgroundColorHex)
    }

    // MARK: - Gr4vyThreeDSTextBoxCustomization Tests

    func testGr4vyThreeDSTextBoxCustomizationInitializationWithAllParameters() {
        // Given
        let customization = Gr4vyThreeDSTextBoxCustomization(
            textFontName: "Helvetica",
            textFontSize: 14,
            nativeFontName: "System",
            nativeFontSize: 14,
            textColorHex: "#000000",
            borderWidth: 1,
            borderColorHex: "#CCCCCC",
            cornerRadius: 4
        )

        // Then
        XCTAssertEqual(customization.textFontName, "Helvetica")
        XCTAssertEqual(customization.textFontSize, 14)
        XCTAssertEqual(customization.nativeFontName, "System")
        XCTAssertEqual(customization.nativeFontSize, 14)
        XCTAssertEqual(customization.textColorHex, "#000000")
        XCTAssertEqual(customization.borderWidth, 1)
        XCTAssertEqual(customization.borderColorHex, "#CCCCCC")
        XCTAssertEqual(customization.cornerRadius, 4)
    }

    func testGr4vyThreeDSTextBoxCustomizationInitializationWithDefaultParameters() {
        // Given
        let customization = Gr4vyThreeDSTextBoxCustomization()

        // Then
        XCTAssertNil(customization.textFontName)
        XCTAssertNil(customization.textFontSize)
        XCTAssertNil(customization.nativeFontName)
        XCTAssertNil(customization.nativeFontSize)
        XCTAssertNil(customization.textColorHex)
        XCTAssertNil(customization.borderWidth)
        XCTAssertNil(customization.borderColorHex)
        XCTAssertNil(customization.cornerRadius)
    }

    func testGr4vyThreeDSTextBoxCustomizationBorderOnly() {
        // Given
        let customization = Gr4vyThreeDSTextBoxCustomization(
            borderWidth: 2,
            borderColorHex: "#007AFF",
            cornerRadius: 8
        )

        // Then
        XCTAssertEqual(customization.borderWidth, 2)
        XCTAssertEqual(customization.borderColorHex, "#007AFF")
        XCTAssertEqual(customization.cornerRadius, 8)
        XCTAssertNil(customization.textFontName)
        XCTAssertNil(customization.textColorHex)
    }

    // MARK: - Gr4vyThreeDSViewCustomization Tests

    func testGr4vyThreeDSViewCustomizationInitializationWithAllParameters() {
        // Given
        let customization = Gr4vyThreeDSViewCustomization(
            challengeViewBackgroundColorHex: "#FFFFFF",
            progressViewBackgroundColorHex: "#F0F0F0"
        )

        // Then
        XCTAssertEqual(customization.challengeViewBackgroundColorHex, "#FFFFFF")
        XCTAssertEqual(customization.progressViewBackgroundColorHex, "#F0F0F0")
    }

    func testGr4vyThreeDSViewCustomizationInitializationWithDefaultParameters() {
        // Given
        let customization = Gr4vyThreeDSViewCustomization()

        // Then
        XCTAssertNil(customization.challengeViewBackgroundColorHex)
        XCTAssertNil(customization.progressViewBackgroundColorHex)
    }

    func testGr4vyThreeDSViewCustomizationChallengeViewOnly() {
        // Given
        let customization = Gr4vyThreeDSViewCustomization(
            challengeViewBackgroundColorHex: "#FFFFFF"
        )

        // Then
        XCTAssertEqual(customization.challengeViewBackgroundColorHex, "#FFFFFF")
        XCTAssertNil(customization.progressViewBackgroundColorHex)
    }

    // MARK: - Gr4vyThreeDSUiCustomization Tests

    func testGr4vyThreeDSUiCustomizationInitializationWithAllParameters() {
        // Given
        let label = Gr4vyThreeDSLabelCustomization(textColorHex: "#333333")
        let toolbar = Gr4vyThreeDSToolbarCustomization(headerText: "Checkout")
        let textBox = Gr4vyThreeDSTextBoxCustomization(borderWidth: 1)
        let view = Gr4vyThreeDSViewCustomization(challengeViewBackgroundColorHex: "#FFFFFF")
        let buttons: [Gr4vyThreeDSButtonType: Gr4vyThreeDSButtonCustomization] = [
            .submit: Gr4vyThreeDSButtonCustomization(textColorHex: "#FFFFFF"),
            .cancel: Gr4vyThreeDSButtonCustomization(textColorHex: "#FF0000"),
        ]

        // When
        let customization = Gr4vyThreeDSUiCustomization(
            label: label,
            toolbar: toolbar,
            textBox: textBox,
            view: view,
            buttons: buttons
        )

        // Then
        XCTAssertNotNil(customization.label)
        XCTAssertEqual(customization.label?.textColorHex, "#333333")
        XCTAssertNotNil(customization.toolbar)
        XCTAssertEqual(customization.toolbar?.headerText, "Checkout")
        XCTAssertNotNil(customization.textBox)
        XCTAssertEqual(customization.textBox?.borderWidth, 1)
        XCTAssertNotNil(customization.view)
        XCTAssertEqual(customization.view?.challengeViewBackgroundColorHex, "#FFFFFF")
        XCTAssertNotNil(customization.buttons)
        XCTAssertEqual(customization.buttons?.count, 2)
        XCTAssertEqual(customization.buttons?[.submit]?.textColorHex, "#FFFFFF")
        XCTAssertEqual(customization.buttons?[.cancel]?.textColorHex, "#FF0000")
    }

    func testGr4vyThreeDSUiCustomizationInitializationWithDefaultParameters() {
        // Given
        let customization = Gr4vyThreeDSUiCustomization()

        // Then
        XCTAssertNil(customization.label)
        XCTAssertNil(customization.toolbar)
        XCTAssertNil(customization.textBox)
        XCTAssertNil(customization.view)
        XCTAssertNil(customization.buttons)
    }

    func testGr4vyThreeDSUiCustomizationPartialInitialization() {
        // Given
        let toolbar = Gr4vyThreeDSToolbarCustomization(
            textColorHex: "#FFFFFF",
            backgroundColorHex: "#007AFF"
        )

        // When
        let customization = Gr4vyThreeDSUiCustomization(toolbar: toolbar)

        // Then
        XCTAssertNil(customization.label)
        XCTAssertNotNil(customization.toolbar)
        XCTAssertNil(customization.textBox)
        XCTAssertNil(customization.view)
        XCTAssertNil(customization.buttons)
    }

    func testGr4vyThreeDSUiCustomizationWithMultipleButtons() {
        // Given
        let buttons: [Gr4vyThreeDSButtonType: Gr4vyThreeDSButtonCustomization] = [
            .submit: Gr4vyThreeDSButtonCustomization(
                textColorHex: "#FFFFFF",
                backgroundColorHex: "#007AFF",
                cornerRadius: 8
            ),
            .cancel: Gr4vyThreeDSButtonCustomization(
                textColorHex: "#007AFF",
                backgroundColorHex: "#FFFFFF",
                cornerRadius: 8
            ),
            .next: Gr4vyThreeDSButtonCustomization(
                textColorHex: "#FFFFFF",
                backgroundColorHex: "#34C759",
                cornerRadius: 8
            ),
        ]

        // When
        let customization = Gr4vyThreeDSUiCustomization(buttons: buttons)

        // Then
        XCTAssertNotNil(customization.buttons)
        XCTAssertEqual(customization.buttons?.count, 3)
        XCTAssertNotNil(customization.buttons?[.submit])
        XCTAssertNotNil(customization.buttons?[.cancel])
        XCTAssertNotNil(customization.buttons?[.next])
        XCTAssertNil(customization.buttons?[.resend])
    }

    // MARK: - Gr4vyThreeDSUiCustomizationMap Tests

    func testGr4vyThreeDSUiCustomizationMapInitializationWithBothModes() {
        // Given
        let lightCustomization = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(backgroundColorHex: "#FFFFFF")
        )
        let darkCustomization = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(backgroundColorHex: "#000000")
        )

        // When
        let map = Gr4vyThreeDSUiCustomizationMap(
            default: lightCustomization,
            dark: darkCustomization
        )

        // Then
        XCTAssertNotNil(map.default)
        XCTAssertNotNil(map.dark)
        XCTAssertEqual(map.default?.toolbar?.backgroundColorHex, "#FFFFFF")
        XCTAssertEqual(map.dark?.toolbar?.backgroundColorHex, "#000000")
    }

    func testGr4vyThreeDSUiCustomizationMapInitializationWithDefaultOnly() {
        // Given
        let lightCustomization = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(backgroundColorHex: "#FFFFFF")
        )

        // When
        let map = Gr4vyThreeDSUiCustomizationMap(default: lightCustomization)

        // Then
        XCTAssertNotNil(map.default)
        XCTAssertNil(map.dark)
        XCTAssertEqual(map.default?.toolbar?.backgroundColorHex, "#FFFFFF")
    }

    func testGr4vyThreeDSUiCustomizationMapInitializationWithDarkOnly() {
        // Given
        let darkCustomization = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(backgroundColorHex: "#000000")
        )

        // When
        let map = Gr4vyThreeDSUiCustomizationMap(dark: darkCustomization)

        // Then
        XCTAssertNil(map.default)
        XCTAssertNotNil(map.dark)
        XCTAssertEqual(map.dark?.toolbar?.backgroundColorHex, "#000000")
    }

    func testGr4vyThreeDSUiCustomizationMapInitializationEmpty() {
        // Given
        let map = Gr4vyThreeDSUiCustomizationMap()

        // Then
        XCTAssertNil(map.default)
        XCTAssertNil(map.dark)
    }

    // MARK: - Complex Integration Tests

    func testCompleteUICustomizationExample() {
        // Given - Complete customization as shown in documentation
        let submitButton = Gr4vyThreeDSButtonCustomization(
            textFontSize: 16,
            textColorHex: "#FFFFFF",
            backgroundColorHex: "#007AFF",
            cornerRadius: 8
        )

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
                textFontSize: 14,
                borderWidth: 1,
                borderColorHex: "#CCCCCC",
                cornerRadius: 4
            ),
            view: Gr4vyThreeDSViewCustomization(
                challengeViewBackgroundColorHex: "#FFFFFF"
            ),
            buttons: [.submit: submitButton]
        )

        // Then - All components should be properly initialized
        XCTAssertNotNil(customization.label)
        XCTAssertNotNil(customization.toolbar)
        XCTAssertNotNil(customization.textBox)
        XCTAssertNotNil(customization.view)
        XCTAssertNotNil(customization.buttons)
        
        XCTAssertEqual(customization.toolbar?.headerText, "Secure Payment")
        XCTAssertEqual(customization.buttons?[.submit]?.cornerRadius, 8)
    }

    func testLightAndDarkModeCustomizations() {
        // Given - Different customizations for light and dark modes
        let lightMode = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(
                textColorHex: "#000000",
                backgroundColorHex: "#FFFFFF"
            ),
            view: Gr4vyThreeDSViewCustomization(
                challengeViewBackgroundColorHex: "#FFFFFF"
            ),
            buttons: [
                .submit: Gr4vyThreeDSButtonCustomization(
                    textColorHex: "#FFFFFF",
                    backgroundColorHex: "#007AFF"
                ),
            ]
        )

        let darkMode = Gr4vyThreeDSUiCustomization(
            toolbar: Gr4vyThreeDSToolbarCustomization(
                textColorHex: "#FFFFFF",
                backgroundColorHex: "#000000"
            ),
            view: Gr4vyThreeDSViewCustomization(
                challengeViewBackgroundColorHex: "#1C1C1E"
            ),
            buttons: [
                .submit: Gr4vyThreeDSButtonCustomization(
                    textColorHex: "#000000",
                    backgroundColorHex: "#0A84FF"
                ),
            ]
        )

        let map = Gr4vyThreeDSUiCustomizationMap(
            default: lightMode,
            dark: darkMode
        )

        // Then - Both modes should be configured correctly
        XCTAssertEqual(map.default?.toolbar?.textColorHex, "#000000")
        XCTAssertEqual(map.default?.toolbar?.backgroundColorHex, "#FFFFFF")
        XCTAssertEqual(map.dark?.toolbar?.textColorHex, "#FFFFFF")
        XCTAssertEqual(map.dark?.toolbar?.backgroundColorHex, "#000000")
        
        XCTAssertEqual(map.default?.view?.challengeViewBackgroundColorHex, "#FFFFFF")
        XCTAssertEqual(map.dark?.view?.challengeViewBackgroundColorHex, "#1C1C1E")
    }

    // MARK: - Edge Cases

    func testColorHexFormats() {
        // Test various valid hex color formats
        let colors = ["#FFFFFF", "#000000", "#FF0000", "#00FF00", "#0000FF", "#123ABC"]
        
        for color in colors {
            let customization = Gr4vyThreeDSButtonCustomization(
                textColorHex: color,
                backgroundColorHex: color
            )
            
            XCTAssertEqual(customization.textColorHex, color)
            XCTAssertEqual(customization.backgroundColorHex, color)
        }
    }

    func testFontSizeRanges() {
        // Test various font sizes
        let fontSizes = [8, 10, 12, 14, 16, 18, 20, 24, 32]
        
        for size in fontSizes {
            let customization = Gr4vyThreeDSButtonCustomization(textFontSize: size)
            XCTAssertEqual(customization.textFontSize, size)
        }
    }

    func testCornerRadiusRanges() {
        // Test various corner radius values
        let radii = [0, 2, 4, 8, 12, 16, 20]
        
        for radius in radii {
            let customization = Gr4vyThreeDSButtonCustomization(cornerRadius: radius)
            XCTAssertEqual(customization.cornerRadius, radius)
        }
    }

    func testBorderWidthRanges() {
        // Test various border width values
        let widths = [0, 1, 2, 3, 4, 5]
        
        for width in widths {
            let customization = Gr4vyThreeDSTextBoxCustomization(borderWidth: width)
            XCTAssertEqual(customization.borderWidth, width)
        }
    }

    func testAllButtonTypesInDictionary() {
        // Test that all button types can be used together
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

        XCTAssertEqual(customization.buttons?.count, 7)
        XCTAssertNotNil(customization.buttons?[.submit])
        XCTAssertNotNil(customization.buttons?[.continue])
        XCTAssertNotNil(customization.buttons?[.next])
        XCTAssertNotNil(customization.buttons?[.resend])
        XCTAssertNotNil(customization.buttons?[.openOobApp])
        XCTAssertNotNil(customization.buttons?[.addCardholder])
        XCTAssertNotNil(customization.buttons?[.cancel])
    }
}
