//
//  Gr4vySDK.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vySDK {
    // MARK: - Properties
    public static let version = Version.current
    public static let name = "Gr4vy-iOS-SDK"
    public static let minimumIOSVersion = "16.0"

    // MARK: - Public Methods
    public static var userAgent: String {
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
        let osVersion = "\(systemVersion.majorVersion).\(systemVersion.minorVersion).\(systemVersion.patchVersion)"
        return "\(name)/\(version) (iOS \(osVersion))"
    }
    
    public static var isIOSVersionSupported: Bool {
        if #available(iOS 16.0, *) {
            return true
        } else {
            return false
        }
    }
}
