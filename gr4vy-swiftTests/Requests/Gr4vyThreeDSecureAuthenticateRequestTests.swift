//
//  Gr4vyThreeDSecureAuthenticateRequestTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyThreeDSecureAuthenticateRequestTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Initialization Tests

    func testInitializationWithAllParameters() {
        // Given
        let defaultSdkType = createTestDefaultSdkType()
        let deviceChannel = "app"
        let deviceRenderOptions = createTestDeviceRenderOptions()
        let sdkAppId = "test-app-id-123"
        let sdkEncryptedData = "encrypted-data-string"
        let sdkEphemeralPubKey = createTestSdkEphemeralPubKey()
        let sdkReferenceNumber = "sdk-ref-12345"
        let sdkMaxTimeoutMinutes = 5
        let sdkTransactionId = "transaction-id-abc"
        let timeout: TimeInterval = 30.0

        // When
        let request = Gr4vyThreeDSecureAuthenticateRequest(
            defaultSdkType: defaultSdkType,
            deviceChannel: deviceChannel,
            deviceRenderOptions: deviceRenderOptions,
            sdkAppId: sdkAppId,
            sdkEncryptedData: sdkEncryptedData,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: sdkReferenceNumber,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes,
            sdkTransactionId: sdkTransactionId,
            timeout: timeout
        )

        // Then
        XCTAssertEqual(request.defaultSdkType.wrappedInd, "Y")
        XCTAssertEqual(request.defaultSdkType.sdkVariant, "ios")
        XCTAssertEqual(request.deviceChannel, deviceChannel)
        XCTAssertEqual(request.deviceRenderOptions.sdkInterface, "01")
        XCTAssertEqual(request.deviceRenderOptions.sdkUiType, ["01", "02", "03"])
        XCTAssertEqual(request.sdkAppId, sdkAppId)
        XCTAssertEqual(request.sdkEncryptedData, sdkEncryptedData)
        XCTAssertEqual(request.sdkEphemeralPubKey.y, "y-coordinate")
        XCTAssertEqual(request.sdkEphemeralPubKey.x, "x-coordinate")
        XCTAssertEqual(request.sdkEphemeralPubKey.kty, "EC")
        XCTAssertEqual(request.sdkEphemeralPubKey.crv, "P-256")
        XCTAssertEqual(request.sdkReferenceNumber, sdkReferenceNumber)
        XCTAssertEqual(request.sdkMaxTimeoutMinutes, sdkMaxTimeoutMinutes)
        XCTAssertEqual(request.sdkTransactionId, sdkTransactionId)
        XCTAssertEqual(request.timeout, timeout)
    }

    func testInitializationWithDefaultTimeout() {
        // Given
        let defaultSdkType = createTestDefaultSdkType()
        let deviceChannel = "browser"
        let deviceRenderOptions = createTestDeviceRenderOptions()
        let sdkAppId = "app-id"
        let sdkEncryptedData = "encrypted-data"
        let sdkEphemeralPubKey = createTestSdkEphemeralPubKey()
        let sdkReferenceNumber = "ref-number"
        let sdkMaxTimeoutMinutes = 10
        let sdkTransactionId = "transaction-id"

        // When
        let request = Gr4vyThreeDSecureAuthenticateRequest(
            defaultSdkType: defaultSdkType,
            deviceChannel: deviceChannel,
            deviceRenderOptions: deviceRenderOptions,
            sdkAppId: sdkAppId,
            sdkEncryptedData: sdkEncryptedData,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: sdkReferenceNumber,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes,
            sdkTransactionId: sdkTransactionId
        )

        // Then
        XCTAssertNil(request.timeout)
    }

    func testInitializationWithCustomTimeout() {
        // Given
        let timeout: TimeInterval = 45.0

        // When
        let request = createTestRequest(timeout: timeout)

        // Then
        XCTAssertEqual(request.timeout, 45.0)
    }

    func testInitializationWithZeroTimeout() {
        // Given
        let timeout: TimeInterval = 0.0

        // When
        let request = createTestRequest(timeout: timeout)

        // Then
        XCTAssertEqual(request.timeout, 0.0)
    }

    // MARK: - JSON Encoding Tests

    func testJSONEncodingWithCompleteData() throws {
        // Given
        let request = createTestRequest(sdkMaxTimeoutMinutes: 5, timeout: 30.0)

        // When
        let jsonData = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        // Then
        XCTAssertNotNil(json)

        // Verify all encoded fields are present
        XCTAssertNotNil(json?["default_sdk_type"])
        XCTAssertEqual(json?["device_channel"] as? String, "app")
        XCTAssertNotNil(json?["device_render_options"])
        XCTAssertEqual(json?["sdk_app_id"] as? String, "test-app-id")
        XCTAssertEqual(json?["sdk_encrypted_data"] as? String, "encrypted-data")
        XCTAssertNotNil(json?["sdk_ephemeral_pub_key"])
        XCTAssertEqual(json?["sdk_reference_number"] as? String, "sdk-ref-123")
        XCTAssertEqual(json?["sdk_max_timeout"] as? String, "05")
        XCTAssertEqual(json?["sdk_transaction_id"] as? String, "transaction-id-xyz")

        // Verify timeout is not encoded (not in CodingKeys)
        XCTAssertNil(json?["timeout"])
    }

    func testJSONEncodingDefaultSdkType() throws {
        // Given
        let request = createTestRequest()

        // When
        let jsonData = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        // Then
        XCTAssertNotNil(json)

        let defaultSdkType = json?["default_sdk_type"] as? [String: Any]
        XCTAssertNotNil(defaultSdkType)
        XCTAssertEqual(defaultSdkType?["wrappedInd"] as? String, "Y")
        XCTAssertEqual(defaultSdkType?["sdkVariant"] as? String, "ios")
    }

    func testJSONEncodingDeviceRenderOptions() throws {
        // Given
        let request = createTestRequest()

        // When
        let jsonData = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        // Then
        XCTAssertNotNil(json)

        let deviceRenderOptions = json?["device_render_options"] as? [String: Any]
        XCTAssertNotNil(deviceRenderOptions)
        XCTAssertEqual(deviceRenderOptions?["sdkInterface"] as? String, "01")
        XCTAssertEqual(deviceRenderOptions?["sdkUiType"] as? [String], ["01", "02", "03"])
    }

    func testJSONEncodingSdkEphemeralPubKey() throws {
        // Given
        let request = createTestRequest()

        // When
        let jsonData = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        // Then
        XCTAssertNotNil(json)

        let sdkEphemeralPubKey = json?["sdk_ephemeral_pub_key"] as? [String: Any]
        XCTAssertNotNil(sdkEphemeralPubKey)
        XCTAssertEqual(sdkEphemeralPubKey?["y"] as? String, "y-coordinate")
        XCTAssertEqual(sdkEphemeralPubKey?["x"] as? String, "x-coordinate")
        XCTAssertEqual(sdkEphemeralPubKey?["kty"] as? String, "EC")
        XCTAssertEqual(sdkEphemeralPubKey?["crv"] as? String, "P-256")
    }

    func testJSONEncodingSdkMaxTimeoutFormatting() throws {
        // Test that sdkMaxTimeoutMinutes is encoded as zero-padded 2-digit string

        // Test single digit
        let request1 = createTestRequest(sdkMaxTimeoutMinutes: 5)
        let jsonData1 = try JSONEncoder().encode(request1)
        let json1 = try JSONSerialization.jsonObject(with: jsonData1, options: []) as? [String: Any]
        XCTAssertEqual(json1?["sdk_max_timeout"] as? String, "05")

        // Test double digit
        let request2 = createTestRequest(sdkMaxTimeoutMinutes: 15)
        let jsonData2 = try JSONEncoder().encode(request2)
        let json2 = try JSONSerialization.jsonObject(with: jsonData2, options: []) as? [String: Any]
        XCTAssertEqual(json2?["sdk_max_timeout"] as? String, "15")

        // Test zero
        let request3 = createTestRequest(sdkMaxTimeoutMinutes: 0)
        let jsonData3 = try JSONEncoder().encode(request3)
        let json3 = try JSONSerialization.jsonObject(with: jsonData3, options: []) as? [String: Any]
        XCTAssertEqual(json3?["sdk_max_timeout"] as? String, "00")

        // Test large value (should still be formatted with at least 2 digits)
        let request4 = createTestRequest(sdkMaxTimeoutMinutes: 99)
        let jsonData4 = try JSONEncoder().encode(request4)
        let json4 = try JSONSerialization.jsonObject(with: jsonData4, options: []) as? [String: Any]
        XCTAssertEqual(json4?["sdk_max_timeout"] as? String, "99")
    }

    func testJSONEncodingStructure() throws {
        // Given
        let request = createTestRequest()

        // When
        let jsonData = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        // Then
        XCTAssertNotNil(json)

        // Verify expected keys are present
        let expectedKeys: Set<String> = [
            "default_sdk_type",
            "device_channel",
            "device_render_options",
            "sdk_app_id",
            "sdk_encrypted_data",
            "sdk_ephemeral_pub_key",
            "sdk_reference_number",
            "sdk_max_timeout",
            "sdk_transaction_id",
        ]

        guard let keys = json?.keys else {
            XCTFail("Expected keys not present in JSON")
            return
        }
        let actualKeys = Set(keys)
        XCTAssertEqual(actualKeys, expectedKeys)

        // Verify timeout is NOT present
        XCTAssertFalse(actualKeys.contains("timeout"))
    }

    func testJSONEncodingWithNilTimeout() throws {
        // Given
        let request = createTestRequest(timeout: nil)

        // When
        let jsonData = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertNil(json?["timeout"])
    }

    // MARK: - SdkMaxTimeout Tests

    func testSdkMaxTimeoutMinutesSingleDigit() {
        // Test values 0-9
        for minutes in 0 ... 9 {
            let request = createTestRequest(sdkMaxTimeoutMinutes: minutes)
            XCTAssertEqual(request.sdkMaxTimeoutMinutes, minutes)
        }
    }

    func testSdkMaxTimeoutMinutesDoubleDigit() {
        // Test values 10-99
        for minutes in [10, 25, 50, 75, 99] {
            let request = createTestRequest(sdkMaxTimeoutMinutes: minutes)
            XCTAssertEqual(request.sdkMaxTimeoutMinutes, minutes)
        }
    }

    func testSdkMaxTimeoutMinutesLargeValue() {
        // Given
        let largeMinutes = 999

        // When
        let request = createTestRequest(sdkMaxTimeoutMinutes: largeMinutes)

        // Then
        XCTAssertEqual(request.sdkMaxTimeoutMinutes, largeMinutes)
    }

    func testSdkMaxTimeoutMinutesZero() {
        // Given
        let request = createTestRequest(sdkMaxTimeoutMinutes: 0)

        // Then
        XCTAssertEqual(request.sdkMaxTimeoutMinutes, 0)
    }

    func testSdkMaxTimeoutEncodingWithLargeValue() throws {
        // Given - value larger than 99
        let request = createTestRequest(sdkMaxTimeoutMinutes: 123)

        // When
        let jsonData = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        // Then - should still format correctly even though it's more than 2 digits
        XCTAssertEqual(json?["sdk_max_timeout"] as? String, "123")
    }

    // MARK: - Timeout Tests

    func testTimeoutDefaultValue() {
        // Given
        let request = createTestRequest()

        // Then
        XCTAssertNil(request.timeout)
    }

    func testTimeoutCustomValue() {
        // Given
        let timeout: TimeInterval = 60.0

        // When
        let request = createTestRequest(timeout: timeout)

        // Then
        XCTAssertEqual(request.timeout, 60.0)
    }

    func testTimeoutZeroValue() {
        // Given
        let timeout: TimeInterval = 0.0

        // When
        let request = createTestRequest(timeout: timeout)

        // Then
        XCTAssertEqual(request.timeout, 0.0)
    }

    func testTimeoutNegativeValue() {
        // Given
        let timeout: TimeInterval = -5.0

        // When
        let request = createTestRequest(timeout: timeout)

        // Then
        XCTAssertEqual(request.timeout, -5.0)
    }

    func testTimeoutLargeValue() {
        // Given
        let timeout: TimeInterval = 300.0 // 5 minutes

        // When
        let request = createTestRequest(timeout: timeout)

        // Then
        XCTAssertEqual(request.timeout, 300.0)
    }

    // MARK: - Edge Cases Tests

    func testEmptyStringValues() {
        // Given
        let defaultSdkType = DefaultSdkType(wrappedInd: "", sdkVariant: "")
        let deviceRenderOptions = DeviceRenderOptions(sdkInterface: "", sdkUiType: [])
        let sdkEphemeralPubKey = SdkEphemeralPubKey(y: "", x: "", kty: "", crv: "")

        // When
        let request = Gr4vyThreeDSecureAuthenticateRequest(
            defaultSdkType: defaultSdkType,
            deviceChannel: "",
            deviceRenderOptions: deviceRenderOptions,
            sdkAppId: "",
            sdkEncryptedData: "",
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: "",
            sdkMaxTimeoutMinutes: 0,
            sdkTransactionId: ""
        )

        // Then
        XCTAssertEqual(request.defaultSdkType.wrappedInd, "")
        XCTAssertEqual(request.defaultSdkType.sdkVariant, "")
        XCTAssertEqual(request.deviceChannel, "")
        XCTAssertEqual(request.deviceRenderOptions.sdkInterface, "")
        XCTAssertEqual(request.deviceRenderOptions.sdkUiType, [])
        XCTAssertEqual(request.sdkAppId, "")
        XCTAssertEqual(request.sdkEncryptedData, "")
        XCTAssertEqual(request.sdkEphemeralPubKey.y, "")
        XCTAssertEqual(request.sdkEphemeralPubKey.x, "")
        XCTAssertEqual(request.sdkEphemeralPubKey.kty, "")
        XCTAssertEqual(request.sdkEphemeralPubKey.crv, "")
        XCTAssertEqual(request.sdkReferenceNumber, "")
        XCTAssertEqual(request.sdkTransactionId, "")
    }

    func testLongStringValues() {
        // Given
        let longString = String(repeating: "a", count: 1_000)
        let defaultSdkType = DefaultSdkType(wrappedInd: longString, sdkVariant: longString)
        let deviceRenderOptions = DeviceRenderOptions(sdkInterface: longString, sdkUiType: [longString])
        let sdkEphemeralPubKey = SdkEphemeralPubKey(y: longString, x: longString, kty: longString, crv: longString)

        // When
        let request = Gr4vyThreeDSecureAuthenticateRequest(
            defaultSdkType: defaultSdkType,
            deviceChannel: longString,
            deviceRenderOptions: deviceRenderOptions,
            sdkAppId: longString,
            sdkEncryptedData: longString,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: longString,
            sdkMaxTimeoutMinutes: 99,
            sdkTransactionId: longString
        )

        // Then
        XCTAssertEqual(request.deviceChannel.count, 1_000)
        XCTAssertEqual(request.sdkAppId.count, 1_000)
        XCTAssertEqual(request.sdkEncryptedData.count, 1_000)
        XCTAssertEqual(request.sdkReferenceNumber.count, 1_000)
        XCTAssertEqual(request.sdkTransactionId.count, 1_000)
    }

    func testUnicodeValues() {
        // Given
        let defaultSdkType = DefaultSdkType(wrappedInd: "是", sdkVariant: "测试🚀")
        let deviceRenderOptions = DeviceRenderOptions(sdkInterface: "日本", sdkUiType: ["한국어", "français"])
        let sdkEphemeralPubKey = SdkEphemeralPubKey(y: "y-坐标", x: "x-坐标", kty: "椭圆曲线", crv: "P-256🔑")

        // When
        let request = Gr4vyThreeDSecureAuthenticateRequest(
            defaultSdkType: defaultSdkType,
            deviceChannel: "应用程序",
            deviceRenderOptions: deviceRenderOptions,
            sdkAppId: "应用ID-🆔",
            sdkEncryptedData: "加密数据-🔒",
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: "参考编号-📋",
            sdkMaxTimeoutMinutes: 5,
            sdkTransactionId: "交易ID-💳"
        )

        // Then
        XCTAssertEqual(request.defaultSdkType.wrappedInd, "是")
        XCTAssertEqual(request.defaultSdkType.sdkVariant, "测试🚀")
        XCTAssertEqual(request.deviceChannel, "应用程序")
        XCTAssertEqual(request.sdkAppId, "应用ID-🆔")
        XCTAssertEqual(request.sdkEncryptedData, "加密数据-🔒")
        XCTAssertEqual(request.sdkReferenceNumber, "参考编号-📋")
        XCTAssertEqual(request.sdkTransactionId, "交易ID-💳")
    }

    func testSpecialCharacters() {
        // Given
        let specialChars = "!@#$%^&*()_+-={}[]|\\:;\"'<>,.?/~`"
        let defaultSdkType = DefaultSdkType(wrappedInd: "Y", sdkVariant: specialChars)
        let deviceRenderOptions = DeviceRenderOptions(sdkInterface: "01", sdkUiType: [specialChars])
        let sdkEphemeralPubKey = SdkEphemeralPubKey(y: specialChars, x: specialChars, kty: "EC", crv: "P-256")

        // When
        let request = Gr4vyThreeDSecureAuthenticateRequest(
            defaultSdkType: defaultSdkType,
            deviceChannel: specialChars,
            deviceRenderOptions: deviceRenderOptions,
            sdkAppId: specialChars,
            sdkEncryptedData: specialChars,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: specialChars,
            sdkMaxTimeoutMinutes: 5,
            sdkTransactionId: specialChars
        )

        // Then
        XCTAssertEqual(request.deviceChannel, specialChars)
        XCTAssertEqual(request.sdkAppId, specialChars)
        XCTAssertEqual(request.sdkEncryptedData, specialChars)
        XCTAssertEqual(request.sdkReferenceNumber, specialChars)
        XCTAssertEqual(request.sdkTransactionId, specialChars)
    }

    func testDeviceChannelVariations() {
        // Test various device channel values
        let deviceChannels = ["app", "browser", "3ds", "mobile", "desktop"]

        for channel in deviceChannels {
            let request = createTestRequest(deviceChannel: channel)
            XCTAssertEqual(request.deviceChannel, channel)
        }
    }

    func testMultipleSdkUiTypes() {
        // Given
        let uiTypes = ["01", "02", "03", "04", "05"]
        let deviceRenderOptions = DeviceRenderOptions(sdkInterface: "01", sdkUiType: uiTypes)

        // When
        let request = createTestRequest(deviceRenderOptions: deviceRenderOptions)

        // Then
        XCTAssertEqual(request.deviceRenderOptions.sdkUiType, uiTypes)
        XCTAssertEqual(request.deviceRenderOptions.sdkUiType.count, 5)
    }

    func testEmptySdkUiTypes() {
        // Given
        let deviceRenderOptions = DeviceRenderOptions(sdkInterface: "01", sdkUiType: [])

        // When
        let request = createTestRequest(deviceRenderOptions: deviceRenderOptions)

        // Then
        XCTAssertEqual(request.deviceRenderOptions.sdkUiType, [])
        XCTAssertTrue(request.deviceRenderOptions.sdkUiType.isEmpty)
    }

    func testJSONEncodingWithEmptyStringValues() throws {
        // Given
        let defaultSdkType = DefaultSdkType(wrappedInd: "", sdkVariant: "")
        let deviceRenderOptions = DeviceRenderOptions(sdkInterface: "", sdkUiType: [])
        let sdkEphemeralPubKey = SdkEphemeralPubKey(y: "", x: "", kty: "", crv: "")

        let request = Gr4vyThreeDSecureAuthenticateRequest(
            defaultSdkType: defaultSdkType,
            deviceChannel: "",
            deviceRenderOptions: deviceRenderOptions,
            sdkAppId: "",
            sdkEncryptedData: "",
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: "",
            sdkMaxTimeoutMinutes: 0,
            sdkTransactionId: ""
        )

        // When
        let jsonData = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["device_channel"] as? String, "")
        XCTAssertEqual(json?["sdk_app_id"] as? String, "")
        XCTAssertEqual(json?["sdk_encrypted_data"] as? String, "")
        XCTAssertEqual(json?["sdk_reference_number"] as? String, "")
        XCTAssertEqual(json?["sdk_max_timeout"] as? String, "00")
        XCTAssertEqual(json?["sdk_transaction_id"] as? String, "")
    }

    func testJSONEncodingWithSpecialCharacters() throws {
        // Given
        let specialChars = "test\"with'quotes<>and&special|chars"
        let defaultSdkType = DefaultSdkType(wrappedInd: "Y", sdkVariant: specialChars)
        let deviceRenderOptions = DeviceRenderOptions(sdkInterface: "01", sdkUiType: ["01"])
        let sdkEphemeralPubKey = SdkEphemeralPubKey(y: specialChars, x: specialChars, kty: "EC", crv: "P-256")

        let request = Gr4vyThreeDSecureAuthenticateRequest(
            defaultSdkType: defaultSdkType,
            deviceChannel: "app",
            deviceRenderOptions: deviceRenderOptions,
            sdkAppId: specialChars,
            sdkEncryptedData: specialChars,
            sdkEphemeralPubKey: sdkEphemeralPubKey,
            sdkReferenceNumber: specialChars,
            sdkMaxTimeoutMinutes: 5,
            sdkTransactionId: specialChars
        )

        // When
        let jsonData = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

        // Then
        XCTAssertNotNil(json)

        // Verify special characters are properly encoded
        XCTAssertEqual(json?["sdk_app_id"] as? String, specialChars)
        XCTAssertEqual(json?["sdk_encrypted_data"] as? String, specialChars)
        XCTAssertEqual(json?["sdk_reference_number"] as? String, specialChars)
        XCTAssertEqual(json?["sdk_transaction_id"] as? String, specialChars)
    }

    // MARK: - Helper Methods

    private func createTestDefaultSdkType() -> DefaultSdkType {
        DefaultSdkType(wrappedInd: "Y", sdkVariant: "ios")
    }

    private func createTestDeviceRenderOptions() -> DeviceRenderOptions {
        DeviceRenderOptions(sdkInterface: "01", sdkUiType: ["01", "02", "03"])
    }

    private func createTestSdkEphemeralPubKey() -> SdkEphemeralPubKey {
        SdkEphemeralPubKey(y: "y-coordinate", x: "x-coordinate", kty: "EC", crv: "P-256")
    }

    private func createTestRequest(
        defaultSdkType: DefaultSdkType? = nil,
        deviceChannel: String = "app",
        deviceRenderOptions: DeviceRenderOptions? = nil,
        sdkAppId: String = "test-app-id",
        sdkEncryptedData: String = "encrypted-data",
        sdkEphemeralPubKey: SdkEphemeralPubKey? = nil,
        sdkReferenceNumber: String = "sdk-ref-123",
        sdkMaxTimeoutMinutes: Int = 5,
        sdkTransactionId: String = "transaction-id-xyz",
        timeout: TimeInterval? = nil
    ) -> Gr4vyThreeDSecureAuthenticateRequest {
        Gr4vyThreeDSecureAuthenticateRequest(
            defaultSdkType: defaultSdkType ?? createTestDefaultSdkType(),
            deviceChannel: deviceChannel,
            deviceRenderOptions: deviceRenderOptions ?? createTestDeviceRenderOptions(),
            sdkAppId: sdkAppId,
            sdkEncryptedData: sdkEncryptedData,
            sdkEphemeralPubKey: sdkEphemeralPubKey ?? createTestSdkEphemeralPubKey(),
            sdkReferenceNumber: sdkReferenceNumber,
            sdkMaxTimeoutMinutes: sdkMaxTimeoutMinutes,
            sdkTransactionId: sdkTransactionId,
            timeout: timeout
        )
    }
}
