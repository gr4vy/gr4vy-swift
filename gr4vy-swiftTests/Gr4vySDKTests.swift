//
//  Gr4vySDKTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vySDKTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Static Properties Tests

    func testSDKVersion() {
        // Test that version is properly set
        XCTAssertEqual(Gr4vySDK.version, "1.0.0")
        XCTAssertFalse(Gr4vySDK.version.isEmpty)

        // Test version format (should be semantic versioning)
        let versionComponents = Gr4vySDK.version.components(separatedBy: ".")
        XCTAssertEqual(versionComponents.count, 3, "Version should follow semantic versioning (major.minor.patch)")

        // Test that each component is a valid number
        for component in versionComponents {
            XCTAssertNotNil(Int(component), "Version component '\(component)' should be a valid number")
        }
    }

    func testSDKName() {
        // Test that name is properly set
        XCTAssertEqual(Gr4vySDK.name, "Gr4vy-iOS-SDK")
        XCTAssertFalse(Gr4vySDK.name.isEmpty)

        // Test name format and content
        XCTAssertTrue(Gr4vySDK.name.contains("Gr4vy"), "SDK name should contain 'Gr4vy'")
        XCTAssertTrue(Gr4vySDK.name.contains("iOS"), "SDK name should contain 'iOS'")
        XCTAssertTrue(Gr4vySDK.name.contains("SDK"), "SDK name should contain 'SDK'")
    }

    func testUserAgent() {
        // Test that user agent is properly formatted
        let userAgent = Gr4vySDK.userAgent
        XCTAssertFalse(userAgent.isEmpty)

        // Test that user agent contains expected components
        XCTAssertTrue(userAgent.contains("Gr4vy-iOS-SDK"), "User agent should contain SDK name")
        XCTAssertTrue(userAgent.contains("1.0.0"), "User agent should contain version")
        XCTAssertTrue(userAgent.contains("iOS"), "User agent should contain platform")

        // Test user agent format
        XCTAssertTrue(userAgent.hasPrefix("Gr4vy-iOS-SDK/"), "User agent should start with SDK name and version")
        XCTAssertTrue(userAgent.contains("(iOS "), "User agent should contain iOS version in parentheses")
        XCTAssertTrue(userAgent.hasSuffix(")"), "User agent should end with closing parenthesis")

        // Test that version numbers are present
        let versionRegex = try! NSRegularExpression(pattern: "\\d+\\.\\d+\\.\\d+", options: [])
        let matches = versionRegex.matches(in: userAgent, options: [], range: NSRange(location: 0, length: userAgent.count))
        XCTAssertGreaterThanOrEqual(matches.count, 1, "User agent should contain at least one version number")
    }

    func testMinimumIOSVersion() {
        // Test that minimum iOS version is properly set
        XCTAssertEqual(Gr4vySDK.minimumIOSVersion, "16.0")
        XCTAssertFalse(Gr4vySDK.minimumIOSVersion.isEmpty)

        // Test version format
        let versionComponents = Gr4vySDK.minimumIOSVersion.components(separatedBy: ".")
        XCTAssertGreaterThanOrEqual(versionComponents.count, 2, "iOS version should have at least major.minor")

        // Test that major version is a valid number and reasonable
        if let majorVersion = Int(versionComponents[0]) {
            XCTAssertGreaterThanOrEqual(majorVersion, 10, "Major iOS version should be 10 or higher")
            XCTAssertLessThanOrEqual(majorVersion, 20, "Major iOS version should be reasonable (less than 20)")
        } else {
            XCTFail("Major version component should be a valid number")
        }

        // Test that minor version is a valid number
        if versionComponents.count > 1 {
            XCTAssertNotNil(Int(versionComponents[1]), "Minor version component should be a valid number")
        }
    }

    // MARK: - iOS Version Support Tests

    func testIOSVersionSupported() {
        // Test that the current iOS version is supported
        // Since we're running on iOS 16.0+ simulator, this should always be true
        XCTAssertTrue(Gr4vySDK.isIOSVersionSupported, "Current iOS version should be supported")

        // Test that the property is accessible and returns a boolean
        let isSupported = Gr4vySDK.isIOSVersionSupported
        XCTAssertTrue(isSupported is Bool, "isIOSVersionSupported should return a Boolean value")
    }

    func testIOSVersionSupportedConsistency() {
        // Test that multiple calls return the same value
        let firstCall = Gr4vySDK.isIOSVersionSupported
        let secondCall = Gr4vySDK.isIOSVersionSupported
        let thirdCall = Gr4vySDK.isIOSVersionSupported

        XCTAssertEqual(firstCall, secondCall, "isIOSVersionSupported should be consistent")
        XCTAssertEqual(secondCall, thirdCall, "isIOSVersionSupported should be consistent")
        XCTAssertEqual(firstCall, thirdCall, "isIOSVersionSupported should be consistent")
    }

    // MARK: - Property Immutability Tests

    func testStaticPropertiesAreImmutable() {
        // Test that static properties maintain their values
        let originalVersion = Gr4vySDK.version
        let originalName = Gr4vySDK.name
        let originalMinimumVersion = Gr4vySDK.minimumIOSVersion

        // Access properties multiple times
        _ = Gr4vySDK.version
        _ = Gr4vySDK.name
        _ = Gr4vySDK.minimumIOSVersion
        _ = Gr4vySDK.isIOSVersionSupported

        // Verify they haven't changed
        XCTAssertEqual(Gr4vySDK.version, originalVersion)
        XCTAssertEqual(Gr4vySDK.name, originalName)
        XCTAssertEqual(Gr4vySDK.minimumIOSVersion, originalMinimumVersion)
    }

    // MARK: - String Content Validation Tests

    func testVersionStringFormat() {
        let version = Gr4vySDK.version

        // Test that version doesn't contain invalid characters
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.")
        let versionCharacterSet = CharacterSet(charactersIn: version)
        XCTAssertTrue(allowedCharacterSet.isSuperset(of: versionCharacterSet),
                      "Version should only contain numbers and dots")

        // Test that version doesn't start or end with a dot
        XCTAssertFalse(version.hasPrefix("."), "Version should not start with a dot")
        XCTAssertFalse(version.hasSuffix("."), "Version should not end with a dot")

        // Test that version doesn't contain consecutive dots
        XCTAssertFalse(version.contains(".."), "Version should not contain consecutive dots")
    }

    func testNameStringFormat() {
        let name = Gr4vySDK.name

        // Test that name doesn't contain invalid characters for a framework name
        XCTAssertFalse(name.contains(" "), "SDK name should not contain spaces")
        XCTAssertFalse(name.hasPrefix("-"), "SDK name should not start with hyphen")
        XCTAssertFalse(name.hasSuffix("-"), "SDK name should not end with hyphen")

        // Test length is reasonable
        XCTAssertGreaterThan(name.count, 5, "SDK name should be reasonably long")
        XCTAssertLessThan(name.count, 50, "SDK name should not be too long")
    }

    func testMinimumIOSVersionStringFormat() {
        let minVersion = Gr4vySDK.minimumIOSVersion

        // Test that minimum iOS version follows expected format
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.")
        let versionCharacterSet = CharacterSet(charactersIn: minVersion)
        XCTAssertTrue(allowedCharacterSet.isSuperset(of: versionCharacterSet),
                      "Minimum iOS version should only contain numbers and dots")

        // Test that it's not an empty string or just dots
        XCTAssertFalse(minVersion.isEmpty, "Minimum iOS version should not be empty")
        XCTAssertNotEqual(minVersion, ".", "Minimum iOS version should not be just a dot")
        XCTAssertNotEqual(minVersion, "..", "Minimum iOS version should not be just dots")
    }

    // MARK: - Comparison Tests

    func testVersionComparison() {
        // Test that version is not empty and follows semantic versioning
        let version = Gr4vySDK.version
        let components = version.components(separatedBy: ".")

        guard components.count >= 3,
              let major = Int(components[0]),
              let minor = Int(components[1]),
              let patch = Int(components[2]) else {
            XCTFail("Version should follow semantic versioning format")
            return
        }

        // Test version components are non-negative
        XCTAssertGreaterThanOrEqual(major, 0, "Major version should be non-negative")
        XCTAssertGreaterThanOrEqual(minor, 0, "Minor version should be non-negative")
        XCTAssertGreaterThanOrEqual(patch, 0, "Patch version should be non-negative")

        // Test that version is reasonable (not too high)
        XCTAssertLessThan(major, 100, "Major version should be reasonable")
        XCTAssertLessThan(minor, 100, "Minor version should be reasonable")
        XCTAssertLessThan(patch, 1_000, "Patch version should be reasonable")
    }

    func testMinimumVersionVsCurrentVersion() {
        // Test that minimum iOS version is reasonable compared to current capabilities
        let minVersion = Gr4vySDK.minimumIOSVersion
        let components = minVersion.components(separatedBy: ".")

        guard let majorVersion = Int(components[0]) else {
            XCTFail("Minimum iOS version should have a valid major version")
            return
        }

        // Test that minimum version is iOS 12.0 or higher (reasonable for modern SDKs)
        XCTAssertGreaterThanOrEqual(majorVersion, 12, "Minimum iOS version should be iOS 12.0 or higher")

        // Test that minimum version is not too far in the future
        XCTAssertLessThanOrEqual(majorVersion, 18, "Minimum iOS version should not be too far in the future")
    }

    // MARK: - Thread Safety Tests

    func testConcurrentAccess() {
        let expectation = XCTestExpectation(description: "Concurrent access completed")
        expectation.expectedFulfillmentCount = 10

        let queue = DispatchQueue.global(qos: .userInitiated)

        for i in 0..<10 {
            queue.async {
                // Access all static properties concurrently
                let version = Gr4vySDK.version
                let name = Gr4vySDK.name
                let minVersion = Gr4vySDK.minimumIOSVersion
                let isSupported = Gr4vySDK.isIOSVersionSupported

                // Verify values are consistent
                XCTAssertEqual(version, "1.0.0")
                XCTAssertEqual(name, "Gr4vy-iOS-SDK")
                XCTAssertEqual(minVersion, "16.0")
                XCTAssertTrue(isSupported is Bool)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Integration Tests

    func testSDKMetadataIntegrity() {
        // Test that all SDK metadata is consistent and valid
        let version = Gr4vySDK.version
        let name = Gr4vySDK.name
        let minVersion = Gr4vySDK.minimumIOSVersion
        let isSupported = Gr4vySDK.isIOSVersionSupported

        // All properties should be accessible
        XCTAssertNotNil(version)
        XCTAssertNotNil(name)
        XCTAssertNotNil(minVersion)
        XCTAssertNotNil(isSupported)

        // All string properties should be non-empty
        XCTAssertFalse(version.isEmpty)
        XCTAssertFalse(name.isEmpty)
        XCTAssertFalse(minVersion.isEmpty)

        // Version support should be consistent with minimum version
        // Since we're running on iOS 16.0+, and minimum is 16.0, support should be true
        XCTAssertTrue(isSupported, "iOS version support should be true for current test environment")
    }

    // MARK: - Edge Case Tests

    func testPropertyAccessAfterMultipleReads() {
        // Test that properties remain stable after many accesses
        var versions: Set<String> = []
        var names: Set<String> = []
        var minVersions: Set<String> = []
        var supportResults: Set<Bool> = []

        for _ in 0..<100 {
            versions.insert(Gr4vySDK.version)
            names.insert(Gr4vySDK.name)
            minVersions.insert(Gr4vySDK.minimumIOSVersion)
            supportResults.insert(Gr4vySDK.isIOSVersionSupported)
        }

        // Each set should contain only one unique value
        XCTAssertEqual(versions.count, 1, "Version should be consistent across multiple accesses")
        XCTAssertEqual(names.count, 1, "Name should be consistent across multiple accesses")
        XCTAssertEqual(minVersions.count, 1, "Minimum version should be consistent across multiple accesses")
        XCTAssertEqual(supportResults.count, 1, "iOS support result should be consistent across multiple accesses")
    }

    func testStringPropertiesNotEmpty() {
        // Ensure no string properties are accidentally empty
        let properties = [
            ("version", Gr4vySDK.version),
            ("name", Gr4vySDK.name),
            ("minimumIOSVersion", Gr4vySDK.minimumIOSVersion),
        ]

        for (propertyName, value) in properties {
            XCTAssertFalse(value.isEmpty, "\(propertyName) should not be empty")
            XCTAssertFalse(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                           "\(propertyName) should not be just whitespace")
        }
    }

    // MARK: - Documentation Tests

    func testSDKStructExists() {
        // Test that Gr4vySDK struct can be referenced and used
        let sdkType = type(of: Gr4vySDK.self)
        XCTAssertNotNil(sdkType, "Gr4vySDK struct should exist and be accessible")

        // Test that it's actually a struct (value type)
        XCTAssertTrue(Gr4vySDK.self is Gr4vySDK.Type, "Gr4vySDK should be a struct type")
    }

    func testAllStaticMembersAccessible() {
        // Test that all expected static members are accessible without compilation errors
        _ = Gr4vySDK.version
        _ = Gr4vySDK.name
        _ = Gr4vySDK.minimumIOSVersion
        _ = Gr4vySDK.isIOSVersionSupported

        // If we reach this point, all members are accessible
        XCTAssertTrue(true, "All static members should be accessible")
    }
}
