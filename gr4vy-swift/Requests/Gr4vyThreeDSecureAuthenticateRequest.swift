//
//  Gr4vyThreeDSecureAuthenticateRequest.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

struct Gr4vyThreeDSecureAuthenticateRequest: Encodable {
    // MARK: - Properties
    let timeout: TimeInterval?
    let defaultSdkType: DefaultSdkType
    let deviceChannel: String
    let deviceRenderOptions: DeviceRenderOptions
    let sdkAppId: String
    let sdkEncryptedData: String
    let sdkEphemeralPubKey: SdkEphemeralPubKey
    let sdkReferenceNumber: String
    let sdkMaxTimeoutMinutes: Int
    let sdkTransactionId: String
    
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case defaultSdkType = "default_sdk_type"
        case deviceChannel = "device_channel"
        case deviceRenderOptions = "device_render_options"
        case sdkAppId = "sdk_app_id"
        case sdkEncryptedData = "sdk_encrypted_data"
        case sdkEphemeralPubKey = "sdk_ephemeral_pub_key"
        case sdkReferenceNumber = "sdk_reference_number"
        case sdkMaxTimeout = "sdk_max_timeout"
        case sdkTransactionId = "sdk_transaction_id"
    }
    
    // MARK: - Initializer
    init(defaultSdkType: DefaultSdkType,
                deviceChannel: String,
                deviceRenderOptions: DeviceRenderOptions,
                sdkAppId: String,
                sdkEncryptedData: String,
                sdkEphemeralPubKey: SdkEphemeralPubKey,
                sdkReferenceNumber: String,
                sdkMaxTimeoutMinutes: Int,
                sdkTransactionId: String,
                timeout: TimeInterval? = nil) {
        self.defaultSdkType = defaultSdkType
        self.deviceChannel = deviceChannel
        self.deviceRenderOptions = deviceRenderOptions
        self.sdkAppId = sdkAppId
        self.sdkEncryptedData = sdkEncryptedData
        self.sdkEphemeralPubKey = sdkEphemeralPubKey
        self.sdkReferenceNumber = sdkReferenceNumber
        self.sdkMaxTimeoutMinutes = sdkMaxTimeoutMinutes
        self.sdkTransactionId = sdkTransactionId
        self.timeout = timeout
    }
    
    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(defaultSdkType, forKey: .defaultSdkType)
        try container.encode(deviceChannel, forKey: .deviceChannel)
        try container.encode(deviceRenderOptions, forKey: .deviceRenderOptions)
        try container.encode(sdkAppId, forKey: .sdkAppId)
        try container.encode(sdkEncryptedData, forKey: .sdkEncryptedData)
        try container.encode(sdkEphemeralPubKey, forKey: .sdkEphemeralPubKey)
        try container.encode(sdkReferenceNumber, forKey: .sdkReferenceNumber)
        // Format as zero-padded 2-digit string for API
        try container.encode(String(format: "%02d", sdkMaxTimeoutMinutes), forKey: .sdkMaxTimeout)
        try container.encode(sdkTransactionId, forKey: .sdkTransactionId)
    }
}
