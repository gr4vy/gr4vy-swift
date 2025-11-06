//
//  Gr4vyThreeDSUiCustomization.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

/// Appearance mode for 3D Secure UI customization.
public enum Gr4vyThreeDSAppearance {
    case `default`
    case dark
}

/// Button types available for customization in the 3D Secure UI.
public enum Gr4vyThreeDSButtonType: String, Hashable {
    case submit
    case `continue`
    case next
    case resend
    case openOobApp
    case addCardholder
    case cancel
}

/// Customization options for buttons.
public struct Gr4vyThreeDSButtonCustomization {
    public var textFontName: String?
    public var textFontSize: Int?
    public var nativeFontName: String?
    public var nativeFontSize: Int?
    public var textColorHex: String?
    public var backgroundColorHex: String?
    public var cornerRadius: Int?
    
    public init(
        textFontName: String? = nil,
        textFontSize: Int? = nil,
        nativeFontName: String? = nil,
        nativeFontSize: Int? = nil,
        textColorHex: String? = nil,
        backgroundColorHex: String? = nil,
        cornerRadius: Int? = nil
    ) {
        self.textFontName = textFontName
        self.textFontSize = textFontSize
        self.nativeFontName = nativeFontName
        self.nativeFontSize = nativeFontSize
        self.textColorHex = textColorHex
        self.backgroundColorHex = backgroundColorHex
        self.cornerRadius = cornerRadius
    }
}

/// Customization options for labels.
public struct Gr4vyThreeDSLabelCustomization {
    public var textFontName: String?
    public var textFontSize: Int?
    public var nativeFontName: String?
    public var nativeFontSize: Int?
    public var textColorHex: String?
    public var headingTextFontName: String?
    public var headingTextFontSize: Int?
    public var headingNativeFontName: String?
    public var headingNativeFontSize: Int?
    public var headingTextColorHex: String?
    
    public init(
        textFontName: String? = nil,
        textFontSize: Int? = nil,
        nativeFontName: String? = nil,
        nativeFontSize: Int? = nil,
        textColorHex: String? = nil,
        headingTextFontName: String? = nil,
        headingTextFontSize: Int? = nil,
        headingNativeFontName: String? = nil,
        headingNativeFontSize: Int? = nil,
        headingTextColorHex: String? = nil
    ) {
        self.textFontName = textFontName
        self.textFontSize = textFontSize
        self.nativeFontName = nativeFontName
        self.nativeFontSize = nativeFontSize
        self.textColorHex = textColorHex
        self.headingTextFontName = headingTextFontName
        self.headingTextFontSize = headingTextFontSize
        self.headingNativeFontName = headingNativeFontName
        self.headingNativeFontSize = headingNativeFontSize
        self.headingTextColorHex = headingTextColorHex
    }
}

/// Customization options for the toolbar.
public struct Gr4vyThreeDSToolbarCustomization {
    public var textFontName: String?
    public var textFontSize: Int?
    public var nativeFontName: String?
    public var nativeFontSize: Int?
    public var textColorHex: String?
    public var backgroundColorHex: String?
    public var headerText: String?
    public var buttonText: String?
    
    public init(
        textFontName: String? = nil,
        textFontSize: Int? = nil,
        nativeFontName: String? = nil,
        nativeFontSize: Int? = nil,
        textColorHex: String? = nil,
        backgroundColorHex: String? = nil,
        headerText: String? = nil,
        buttonText: String? = nil
    ) {
        self.textFontName = textFontName
        self.textFontSize = textFontSize
        self.nativeFontName = nativeFontName
        self.nativeFontSize = nativeFontSize
        self.textColorHex = textColorHex
        self.backgroundColorHex = backgroundColorHex
        self.headerText = headerText
        self.buttonText = buttonText
    }
}

/// Customization options for text input boxes.
public struct Gr4vyThreeDSTextBoxCustomization {
    public var textFontName: String?
    public var textFontSize: Int?
    public var nativeFontName: String?
    public var nativeFontSize: Int?
    public var textColorHex: String?
    public var borderWidth: Int?
    public var borderColorHex: String?
    public var cornerRadius: Int?
    
    public init(
        textFontName: String? = nil,
        textFontSize: Int? = nil,
        nativeFontName: String? = nil,
        nativeFontSize: Int? = nil,
        textColorHex: String? = nil,
        borderWidth: Int? = nil,
        borderColorHex: String? = nil,
        cornerRadius: Int? = nil
    ) {
        self.textFontName = textFontName
        self.textFontSize = textFontSize
        self.nativeFontName = nativeFontName
        self.nativeFontSize = nativeFontSize
        self.textColorHex = textColorHex
        self.borderWidth = borderWidth
        self.borderColorHex = borderColorHex
        self.cornerRadius = cornerRadius
    }
}

/// Customization options for view backgrounds.
public struct Gr4vyThreeDSViewCustomization {
    public var challengeViewBackgroundColorHex: String?
    public var progressViewBackgroundColorHex: String?
    
    public init(
        challengeViewBackgroundColorHex: String? = nil,
        progressViewBackgroundColorHex: String? = nil
    ) {
        self.challengeViewBackgroundColorHex = challengeViewBackgroundColorHex
        self.progressViewBackgroundColorHex = progressViewBackgroundColorHex
    }
}

/// Complete UI customization configuration for the 3D Secure challenge UI.
///
/// This struct aggregates all customization options for different UI elements
/// in the 3DS authentication challenge screen.
///
/// ## Example
/// ```swift
/// let customization = Gr4vyThreeDSUiCustomization(
///     toolbar: Gr4vyThreeDSToolbarCustomization(
///         textColorHex: "#FFFFFF",
///         backgroundColorHex: "#007AFF"
///     ),
///     buttons: [
///         .submit: Gr4vyThreeDSButtonCustomization(
///             textColorHex: "#FFFFFF",
///             backgroundColorHex: "#007AFF",
///             cornerRadius: 8
///         )
///     ]
/// )
/// ```
public struct Gr4vyThreeDSUiCustomization {
    public var label: Gr4vyThreeDSLabelCustomization?
    public var toolbar: Gr4vyThreeDSToolbarCustomization?
    public var textBox: Gr4vyThreeDSTextBoxCustomization?
    public var view: Gr4vyThreeDSViewCustomization?
    public var buttons: [Gr4vyThreeDSButtonType: Gr4vyThreeDSButtonCustomization]?
    
    public init(
        label: Gr4vyThreeDSLabelCustomization? = nil,
        toolbar: Gr4vyThreeDSToolbarCustomization? = nil,
        textBox: Gr4vyThreeDSTextBoxCustomization? = nil,
        view: Gr4vyThreeDSViewCustomization? = nil,
        buttons: [Gr4vyThreeDSButtonType: Gr4vyThreeDSButtonCustomization]? = nil
    ) {
        self.label = label
        self.toolbar = toolbar
        self.textBox = textBox
        self.view = view
        self.buttons = buttons
    }
}

/// Container for UI customizations for different appearance modes.
public struct Gr4vyThreeDSUiCustomizationMap {
    public var `default`: Gr4vyThreeDSUiCustomization?
    public var dark: Gr4vyThreeDSUiCustomization?
    
    public init(default: Gr4vyThreeDSUiCustomization? = nil, dark: Gr4vyThreeDSUiCustomization? = nil) {
        self.default = `default`
        self.dark = dark
    }
}
