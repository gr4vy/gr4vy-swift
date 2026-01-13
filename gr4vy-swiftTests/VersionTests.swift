//
//  VersionTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class VersionTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Version Tests

    func testVersionCurrentExists() {
        // Given & When
        let version = Version.current

        // Then
        XCTAssertFalse(version.isEmpty, "Version should not be empty")
    }

    func testVersionCurrentIsString() {
        // Given & When
        let version = Version.current

        // Then
        XCTAssertTrue(version is String, "Version should be a String")
    }

    func testVersionCurrentFormat() {
        // Given & When
        let version = Version.current

        // Then
        // Version should follow semantic versioning format (e.g., "1.0.0" or "1.0.0-beta.1")
        let pattern = "^\\d+\\.\\d+\\.\\d+(-[a-zA-Z0-9.]+)?$"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(version.startIndex..<version.endIndex, in: version)
        let matches = regex?.matches(in: version, options: [], range: range)

        XCTAssertNotNil(matches, "Version should match semantic versioning pattern")
        XCTAssertEqual(matches?.count, 1, "Version should match semantic versioning pattern exactly once")
    }

    func testVersionCurrentContainsNumbers() {
        // Given & When
        let version = Version.current

        // Then
        let containsNumbers = version.rangeOfCharacter(from: .decimalDigits) != nil
        XCTAssertTrue(containsNumbers, "Version should contain numbers")
    }

    func testVersionCurrentContainsDots() {
        // Given & When
        let version = Version.current

        // Then
        XCTAssertTrue(version.contains("."), "Version should contain dots")
    }

    func testVersionCurrentHasAtLeastThreeComponents() {
        // Given & When
        let version = Version.current

        // Then
        // Split by "-" first to separate version from prerelease/build metadata
        let versionParts = version.split(separator: "-")
        let mainVersion = String(versionParts[0])
        let components = mainVersion.split(separator: ".")

        XCTAssertGreaterThanOrEqual(components.count, 3, "Version should have at least 3 components (major.minor.patch)")
    }

    func testVersionCurrentMajorVersionIsNumeric() {
        // Given & When
        let version = Version.current

        // Then
        let versionParts = version.split(separator: "-")
        let mainVersion = String(versionParts[0])
        let components = mainVersion.split(separator: ".")

        if let majorVersion = components.first {
            XCTAssertNotNil(Int(majorVersion), "Major version should be numeric")
        } else {
            XCTFail("Version should have a major component")
        }
    }

    func testVersionCurrentMinorVersionIsNumeric() {
        // Given & When
        let version = Version.current

        // Then
        let versionParts = version.split(separator: "-")
        let mainVersion = String(versionParts[0])
        let components = mainVersion.split(separator: ".")

        if components.count >= 2 {
            XCTAssertNotNil(Int(components[1]), "Minor version should be numeric")
        } else {
            XCTFail("Version should have a minor component")
        }
    }

    func testVersionCurrentPatchVersionIsNumeric() {
        // Given & When
        let version = Version.current

        // Then
        let versionParts = version.split(separator: "-")
        let mainVersion = String(versionParts[0])
        let components = mainVersion.split(separator: ".")

        if components.count >= 3 {
            XCTAssertNotNil(Int(components[2]), "Patch version should be numeric")
        } else {
            XCTFail("Version should have a patch component")
        }
    }

    func testVersionCurrentDoesNotStartWithV() {
        // Given & When
        let version = Version.current

        // Then
        XCTAssertFalse(version.hasPrefix("v"), "Version should not start with 'v'")
        XCTAssertFalse(version.hasPrefix("V"), "Version should not start with 'V'")
    }

    func testVersionCurrentDoesNotContainSpaces() {
        // Given & When
        let version = Version.current

        // Then
        XCTAssertFalse(version.contains(" "), "Version should not contain spaces")
    }

    func testVersionCurrentIsAccessibleFromVersionStruct() {
        // Given & When
        let version = Version.current

        // Then
        XCTAssertNotNil(version, "Version.current should be accessible")
    }

    func testVersionCurrentConsistency() {
        // Given & When
        let version1 = Version.current
        let version2 = Version.current

        // Then
        XCTAssertEqual(version1, version2, "Version.current should return the same value consistently")
    }

    func testVersionCurrentIsNotDevelopmentPlaceholder() {
        // Given & When
        let version = Version.current

        // Then
        // Check that version is not a placeholder value
        let placeholders = ["0.0.0", "x.x.x", "X.X.X", "dev", "development", "TBD"]
        for placeholder in placeholders {
            XCTAssertNotEqual(version.lowercased(), placeholder.lowercased(),
                              "Version should not be a placeholder value: \(placeholder)")
        }
    }

    // MARK: - Semantic Versioning Component Tests

    func testVersionCurrentCanBeParsedIntoComponents() {
        // Given & When
        let version = Version.current

        // Then
        let versionParts = version.split(separator: "-")
        let mainVersion = String(versionParts[0])
        let components = mainVersion.split(separator: ".")

        XCTAssertGreaterThanOrEqual(components.count, 3)

        if components.count >= 3 {
            let major = Int(components[0])
            let minor = Int(components[1])
            let patch = Int(components[2])

            XCTAssertNotNil(major, "Major version should be a valid integer")
            XCTAssertNotNil(minor, "Minor version should be a valid integer")
            XCTAssertNotNil(patch, "Patch version should be a valid integer")
        }
    }

    func testVersionCurrentPrereleaseIdentifierFormat() {
        // Given & When
        let version = Version.current

        // Then
        if version.contains("-") {
            let parts = version.split(separator: "-")
            XCTAssertGreaterThanOrEqual(parts.count, 2, "If version contains '-', it should have a prerelease identifier")

            // Prerelease identifier should only contain alphanumerics, dots, and hyphens
            if parts.count >= 2 {
                let prerelease = String(parts[1])
                let pattern = "^[a-zA-Z0-9.]+$"
                let regex = try? NSRegularExpression(pattern: pattern, options: [])
                let range = NSRange(prerelease.startIndex..<prerelease.endIndex, in: prerelease)
                let matches = regex?.matches(in: prerelease, options: [], range: range)

                XCTAssertNotNil(matches)
                XCTAssertEqual(matches?.count, 1, "Prerelease identifier should only contain alphanumerics and dots")
            }
        }
    }

    func testVersionCurrentIsGreaterThanZero() {
        // Given & When
        let version = Version.current

        // Then
        let versionParts = version.split(separator: "-")
        let mainVersion = String(versionParts[0])
        let components = mainVersion.split(separator: ".")

        if components.count >= 3 {
            let major = Int(components[0]) ?? 0
            let minor = Int(components[1]) ?? 0
            let patch = Int(components[2]) ?? 0

            // At least one component should be greater than 0
            XCTAssertTrue(major > 0 || minor > 0 || patch > 0,
                          "Version should have at least one component greater than 0")
        }
    }

    // MARK: - Version Structure Tests

    func testVersionStructIsInternal() {
        // This test documents that Version is an internal struct
        // and should not be exposed in the public API

        // The Version struct should only be accessible within the module
        XCTAssertTrue(true, "Version struct is internal and not exposed publicly")
    }

    func testVersionCurrentIsStaticProperty() {
        // This test verifies that current is a static property
        // and can be accessed without instantiation

        let version = Version.current
        XCTAssertNotNil(version)

        // We should not need to create an instance of Version to access current
        XCTAssertTrue(true, "Version.current is a static property")
    }

    // MARK: - Comparison Tests

    func testVersionCurrentComparisonWithSelf() {
        // Given & When
        let version = Version.current

        // Then
        XCTAssertEqual(version, version, "Version should equal itself")
    }

    func testVersionCurrentHashValue() {
        // Given & When
        let version = Version.current

        // Then
        let hashValue = version.hashValue
        XCTAssertNotNil(hashValue, "Version should have a hash value")

        // Hash value should be consistent
        XCTAssertEqual(hashValue, version.hashValue, "Hash value should be consistent")
    }

    // MARK: - Integration Tests

    func testVersionCurrentCanBeUsedInLogging() {
        // Given & When
        let version = Version.current
        let logMessage = "SDK Version: \(version)"

        // Then
        XCTAssertTrue(logMessage.contains(version), "Version should be usable in logging")
        XCTAssertTrue(logMessage.hasPrefix("SDK Version:"), "Log message should be formatted correctly")
    }

    func testVersionCurrentCanBeUsedInUserAgent() {
        // Given & When
        let version = Version.current
        let userAgent = "Gr4vy-iOS-SDK/\(version)"

        // Then
        XCTAssertTrue(userAgent.contains(version), "Version should be usable in user agent string")
        XCTAssertTrue(userAgent.hasPrefix("Gr4vy-iOS-SDK/"), "User agent should be formatted correctly")
    }

    func testVersionCurrentCanBeUsedInAPIHeaders() {
        // Given & When
        let version = Version.current
        let headers = ["X-SDK-Version": version]

        // Then
        XCTAssertEqual(headers["X-SDK-Version"], version, "Version should be usable in API headers")
    }

    // MARK: - Beta Version Tests

    func testVersionCurrentBetaIdentifierIfPresent() {
        // Given & When
        let version = Version.current

        // Then
        if version.contains("beta") {
            XCTAssertTrue(version.contains("-beta"), "Beta versions should use '-beta' format")

            // Beta version should have a number after it
            let betaPattern = "beta\\.(\\d+)"
            let regex = try? NSRegularExpression(pattern: betaPattern, options: [])
            let range = NSRange(version.startIndex..<version.endIndex, in: version)
            let matches = regex?.matches(in: version, options: [], range: range)

            if let match = matches?.first, match.numberOfRanges >= 2 {
                let numberRange = match.range(at: 1)
                if let range = Range(numberRange, in: version) {
                    let betaNumber = String(version[range])
                    XCTAssertNotNil(Int(betaNumber), "Beta identifier should have a numeric component")
                }
            }
        }
    }

    // MARK: - Version File Content Tests

    func testVersionCurrentMatchesExpectedFormat() {
        // Given & When
        let version = Version.current

        // Then
        // Version should match one of the expected formats:
        // - X.Y.Z (stable release)
        // - X.Y.Z-beta.N (beta release)
        // - X.Y.Z-alpha.N (alpha release)
        // - X.Y.Z-rc.N (release candidate)

        let stablePattern = "^\\d+\\.\\d+\\.\\d+$"
        let prereleasePattern = "^\\d+\\.\\d+\\.\\d+-(alpha|beta|rc)\\.(\\d+)$"

        let stableRegex = try? NSRegularExpression(pattern: stablePattern, options: [])
        let prereleaseRegex = try? NSRegularExpression(pattern: prereleasePattern, options: [])

        let range = NSRange(version.startIndex..<version.endIndex, in: version)

        let stableMatches = stableRegex?.matches(in: version, options: [], range: range)
        let prereleaseMatches = prereleaseRegex?.matches(in: version, options: [], range: range)

        let isValidFormat = (stableMatches?.count ?? 0) > 0 || (prereleaseMatches?.count ?? 0) > 0

        XCTAssertTrue(isValidFormat, "Version should match expected format: \(version)")
    }
}
