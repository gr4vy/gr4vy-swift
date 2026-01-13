//
//  Gr4vyThreeDSUiCustomizationMapper.swift
//  gr4vy-swift
//
//  Internal mapper from Gr4vy UI models to Netcetera UiCustomization types.
//

import Foundation
import ThreeDS_SDK
import UIKit

enum Gr4vyThreeDSUiCustomizationMapper {
    static func map(_ map: Gr4vyThreeDSUiCustomizationMap?) -> [String: UiCustomization]? {
        guard let map = map else { return nil }
        var result: [String: UiCustomization] = [:]
        if let light = map.default, let ui = build(from: light) {
            result["DEFAULT"] = ui
        }
        if let dark = map.dark, let ui = build(from: dark) {
            result["DARK"] = ui
        }
        return result.isEmpty ? nil : result
    }
    
    private static func build(from src: Gr4vyThreeDSUiCustomization) -> UiCustomization? {
        let ui = UiCustomization()
        var hasAny = false
        
        if let label = src.label {
            let lc = LabelCustomization()
            if let v = label.nativeFontName, let s = label.nativeFontSize, let f = UIFont(name: v, size: CGFloat(s)) { lc.setTextFont(font: f) ; hasAny = true } else {
                if let v = label.textFontName { try? lc.setTextFontName(fontName: v) ; hasAny = true }
                if let v = label.textFontSize { try? lc.setTextFontSize(fontSize: v) ; hasAny = true }
            }
            if let v = label.textColorHex { try? lc.setTextColor(hexColorCode: v) ; hasAny = true }
            if let v = label.headingNativeFontName, let s = label.headingNativeFontSize, let f = UIFont(name: v, size: CGFloat(s)) { lc.setHeadingTextFont(font: f) ; hasAny = true } else {
                if let v = label.headingTextFontName { try? lc.setHeadingTextFontName(fontName: v) ; hasAny = true }
                if let v = label.headingTextFontSize { try? lc.setHeadingTextFontSize(fontSize: v) ; hasAny = true }
            }
            if let v = label.headingTextColorHex { try? lc.setHeadingTextColor(hexColorCode: v) ; hasAny = true }
            ui.setLabelCustomization(labelCustomization: lc)
        }
        
        if let tb = src.textBox {
            let tbc = TextBoxCustomization()
            if let v = tb.nativeFontName, let s = tb.nativeFontSize, let f = UIFont(name: v, size: CGFloat(s)) { tbc.setTextFont(font: f) ; hasAny = true } else {
                if let v = tb.textFontName { try? tbc.setTextFontName(fontName: v) ; hasAny = true }
                if let v = tb.textFontSize { try? tbc.setTextFontSize(fontSize: v) ; hasAny = true }
            }
            if let v = tb.textColorHex { try? tbc.setTextColor(hexColorCode: v) ; hasAny = true }
            if let v = tb.borderWidth { try? tbc.setBorderWidth(borderWidth: v) ; hasAny = true }
            if let v = tb.borderColorHex { try? tbc.setBorderColor(hexColorCode: v) ; hasAny = true }
            if let v = tb.cornerRadius { try? tbc.setCornerRadius(cornerRadius: v) ; hasAny = true }
            ui.setTextBoxCustomization(textBoxCustomization: tbc)
        }
        
        if let bar = src.toolbar {
            let tc = ToolbarCustomization()
            if let v = bar.nativeFontName, let s = bar.nativeFontSize, let f = UIFont(name: v, size: CGFloat(s)) { tc.setTextFont(font: f) ; hasAny = true } else {
                if let v = bar.textFontName { try? tc.setTextFontName(fontName: v) ; hasAny = true }
                if let v = bar.textFontSize { try? tc.setTextFontSize(fontSize: v) ; hasAny = true }
            }
            if let v = bar.textColorHex { try? tc.setTextColor(hexColorCode: v) ; hasAny = true }
            if let v = bar.backgroundColorHex { try? tc.setBackgroundColor(hexColorCode: v) ; hasAny = true }
            if let v = bar.headerText { try? tc.setHeaderText(headerText: v) ; hasAny = true }
            if let v = bar.buttonText { try? tc.setButtonText(buttonText: v) ; hasAny = true }
            ui.setToolbarCustomization(toolbarCustomization: tc)
        }
        
        if let view = src.view {
            let vc = ViewCustomization()
            if let v = view.challengeViewBackgroundColorHex { try? vc.setChallengeViewBackgroundColor(hexColorCode: v) ; hasAny = true }
            if let v = view.progressViewBackgroundColorHex { try? vc.setProgressViewBackgroundColor(hexColorCode: v) ; hasAny = true }
            ui.setViewCustomization(viewCustomization: vc)
        }
        
        if let buttons = src.buttons, !buttons.isEmpty {
            for (type, conf) in buttons {
                let bc = ButtonCustomization()
                if let v = conf.nativeFontName, let s = conf.nativeFontSize, let f = UIFont(name: v, size: CGFloat(s)) { bc.setTextFont(font: f) ; hasAny = true } else {
                    if let v = conf.textFontName { try? bc.setTextFontName(fontName: v) ; hasAny = true }
                    if let v = conf.textFontSize { try? bc.setTextFontSize(fontSize: v) ; hasAny = true }
                }
                if let v = conf.textColorHex { try? bc.setTextColor(hexColorCode: v) ; hasAny = true }
                if let v = conf.backgroundColorHex { try? bc.setBackgroundColor(hexColorCode: v) ; hasAny = true }
                if let v = conf.cornerRadius { try? bc.setCornerRadius(cornerRadius: v) ; hasAny = true }
                if let mapped = mapButtonType(type) {
                    ui.setButtonCustomization(buttonCustomization: bc, buttonType: mapped)
                }
            }
        }
        
        return hasAny ? ui : nil
    }
    
    private static func mapButtonType(_ t: Gr4vyThreeDSButtonType) -> UiCustomization.ButtonType? {
        switch t {
        case .submit: return UiCustomization.ButtonType.SUBMIT
        case .`continue`: return UiCustomization.ButtonType.CONTINUE
        case .next: return UiCustomization.ButtonType.NEXT
        case .resend: return UiCustomization.ButtonType.RESEND
        case .openOobApp: return UiCustomization.ButtonType.OPEN_OOB_APP
        case .addCardholder: return UiCustomization.ButtonType.ADD_CH
        case .cancel: return UiCustomization.ButtonType.CANCEL
        }
    }
}
