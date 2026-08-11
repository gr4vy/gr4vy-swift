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
    // Names this SDK on the wire. Kept distinct from the gr4vy-ios Embed wrapper,
    // which is a separate SDK on its own version line.
    public static let name = "Gr4vy-Swift"
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
