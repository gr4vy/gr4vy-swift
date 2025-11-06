//
//  Gr4vyACSRenderingType.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

/// ACS (Access Control Server) rendering type configuration for 3D Secure challenge UI
struct Gr4vyACSRenderingType: Codable {
    // MARK: - Properties
    
    /// ACS interface type identifier (e.g., "01" for native, "02" for HTML)
    let acsInterface: String
    
    /// ACS UI template identifier for challenge presentation
    let acsUiTemplate: String
    
    /// Device user interface mode (e.g., "01" for text, "02" for single select, etc.)
    let deviceUserInterfaceMode: String
    
    // MARK: - CodingKeys
    
    enum CodingKeys: String, CodingKey {
        case acsInterface = "acsInterface"
        case acsUiTemplate = "acsUiTemplate"
        case deviceUserInterfaceMode = "deviceUserInterfaceMode"
    }
}
