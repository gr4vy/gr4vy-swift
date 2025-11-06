//
//  Gr4vyVersioningResponse.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

struct Gr4vyVersioningResponse: Codable {
    let directoryServerId: String
    let messageVersion: String
    let apiKey: String
    
    enum CodingKeys: String, CodingKey {
        case directoryServerId = "directory_server_id"
        case messageVersion = "message_version"
        case apiKey = "api_key"
    }
}
