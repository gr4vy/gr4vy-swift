//
//  Gr4vySetup.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

public struct Gr4vySetup: Encodable {
    // MARK: - Properties
    public let gr4vyId: String
    public var token: String?
    public var merchantId: String?
    public let server: Gr4vyServer
    public var timeout: TimeInterval
    var instance: String {
        server == .production ? gr4vyId : "sandbox.\(gr4vyId)"
    }

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case token
        case merchantId
        case server
    }
    
    // MARK: - Initializer
    public init(gr4vyId: String,
                token: String?,
                merchantId: String?,
                server: Gr4vyServer,
                timeout: TimeInterval = 30) {
        self.gr4vyId = gr4vyId
        self.token = token
        self.merchantId = merchantId
        self.server = server
        self.timeout = timeout
    }
}
