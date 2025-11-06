//
//  Gr4vyAuthenticationTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyAuthenticationTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Initialization Tests

    func testGr4vyAuthenticationInitializationWithAllParameters() {
        // Given
        let attempted = true
        let type = "frictionless"
        let transactionStatus = "Y"
        let hasCancelled = false
        let hasTimedOut = false
        let cardholderInfo = "Authentication successful"

        // When
        let auth = Gr4vyAuthentication(
            attempted: attempted,
            type: type,
            transactionStatus: transactionStatus,
            hasCancelled: hasCancelled,
            hasTimedOut: hasTimedOut,
            cardholderInfo: cardholderInfo
        )

        // Then
        XCTAssertEqual(auth.attempted, attempted)
        XCTAssertEqual(auth.type, type)
        XCTAssertEqual(auth.transactionStatus, transactionStatus)
        XCTAssertEqual(auth.hasCancelled, hasCancelled)
        XCTAssertEqual(auth.hasTimedOut, hasTimedOut)
        XCTAssertEqual(auth.cardholderInfo, cardholderInfo)
    }

    func testGr4vyAuthenticationInitializationWithDefaultParameters() {
        // Given
        let attempted = true
        let type = "challenge"
        let transactionStatus = "A"
        let cardholderInfo: String? = nil

        // When
        let auth = Gr4vyAuthentication(
            attempted: attempted,
            type: type,
            transactionStatus: transactionStatus,
            cardholderInfo: cardholderInfo
        )

        // Then
        XCTAssertEqual(auth.attempted, attempted)
        XCTAssertEqual(auth.type, type)
        XCTAssertEqual(auth.transactionStatus, transactionStatus)
        XCTAssertEqual(auth.hasCancelled, false) // Default value
        XCTAssertEqual(auth.hasTimedOut, false) // Default value
        XCTAssertNil(auth.cardholderInfo)
    }

    func testGr4vyAuthenticationWithNilOptionalValues() {
        // Given
        let attempted = false
        let type: String? = nil
        let transactionStatus: String? = nil
        let cardholderInfo: String? = nil

        // When
        let auth = Gr4vyAuthentication(
            attempted: attempted,
            type: type,
            transactionStatus: transactionStatus,
            cardholderInfo: cardholderInfo
        )

        // Then
        XCTAssertEqual(auth.attempted, false)
        XCTAssertNil(auth.type)
        XCTAssertNil(auth.transactionStatus)
        XCTAssertEqual(auth.hasCancelled, false)
        XCTAssertEqual(auth.hasTimedOut, false)
        XCTAssertNil(auth.cardholderInfo)
    }

    // MARK: - Authentication Type Tests

    func testGr4vyAuthenticationWithFrictionlessType() {
        // Given
        let type = "frictionless"
        let transactionStatus = "Y"

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: type,
            transactionStatus: transactionStatus,
            cardholderInfo: nil
        )

        // Then
        XCTAssertEqual(auth.type, "frictionless")
        XCTAssertEqual(auth.transactionStatus, "Y")
        XCTAssertTrue(auth.attempted)
    }

    func testGr4vyAuthenticationWithChallengeType() {
        // Given
        let type = "challenge"
        let transactionStatus = "C"

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: type,
            transactionStatus: transactionStatus,
            cardholderInfo: "Please complete the challenge"
        )

        // Then
        XCTAssertEqual(auth.type, "challenge")
        XCTAssertEqual(auth.transactionStatus, "C")
        XCTAssertEqual(auth.cardholderInfo, "Please complete the challenge")
    }

    func testGr4vyAuthenticationWithErrorType() {
        // Given
        let type = "error"
        let transactionStatus = "N"

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: type,
            transactionStatus: transactionStatus,
            cardholderInfo: "Authentication failed"
        )

        // Then
        XCTAssertEqual(auth.type, "error")
        XCTAssertEqual(auth.transactionStatus, "N")
        XCTAssertEqual(auth.cardholderInfo, "Authentication failed")
    }

    // MARK: - Transaction Status Tests

    func testGr4vyAuthenticationWithSuccessStatus() {
        // Given
        let transactionStatus = "Y" // Authentication successful

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: "frictionless",
            transactionStatus: transactionStatus,
            cardholderInfo: nil
        )

        // Then
        XCTAssertEqual(auth.transactionStatus, "Y")
        XCTAssertTrue(auth.attempted)
    }

    func testGr4vyAuthenticationWithFailedStatus() {
        // Given
        let transactionStatus = "N" // Authentication failed

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: "frictionless",
            transactionStatus: transactionStatus,
            cardholderInfo: nil
        )

        // Then
        XCTAssertEqual(auth.transactionStatus, "N")
        XCTAssertTrue(auth.attempted)
    }

    func testGr4vyAuthenticationWithUnavailableStatus() {
        // Given
        let transactionStatus = "U" // Authentication unavailable

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: "frictionless",
            transactionStatus: transactionStatus,
            cardholderInfo: nil
        )

        // Then
        XCTAssertEqual(auth.transactionStatus, "U")
    }

    func testGr4vyAuthenticationWithAttemptedStatus() {
        // Given
        let transactionStatus = "A" // Authentication attempted

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: "frictionless",
            transactionStatus: transactionStatus,
            cardholderInfo: nil
        )

        // Then
        XCTAssertEqual(auth.transactionStatus, "A")
    }

    func testGr4vyAuthenticationWithChallengeRequiredStatus() {
        // Given
        let transactionStatus = "C" // Challenge required

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: "challenge",
            transactionStatus: transactionStatus,
            cardholderInfo: nil
        )

        // Then
        XCTAssertEqual(auth.transactionStatus, "C")
    }

    // MARK: - Cancellation and Timeout Tests

    func testGr4vyAuthenticationWithCancellation() {
        // Given
        let hasCancelled = true

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: "challenge",
            transactionStatus: "N",
            hasCancelled: hasCancelled,
            hasTimedOut: false,
            cardholderInfo: "User cancelled authentication"
        )

        // Then
        XCTAssertTrue(auth.hasCancelled)
        XCTAssertFalse(auth.hasTimedOut)
        XCTAssertEqual(auth.cardholderInfo, "User cancelled authentication")
    }

    func testGr4vyAuthenticationWithTimeout() {
        // Given
        let hasTimedOut = true

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: "challenge",
            transactionStatus: "N",
            hasCancelled: false,
            hasTimedOut: hasTimedOut,
            cardholderInfo: "Authentication timed out"
        )

        // Then
        XCTAssertFalse(auth.hasCancelled)
        XCTAssertTrue(auth.hasTimedOut)
        XCTAssertEqual(auth.cardholderInfo, "Authentication timed out")
    }

    func testGr4vyAuthenticationWithBothCancellationAndTimeout() {
        // Given
        let hasCancelled = true
        let hasTimedOut = true

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: "error",
            transactionStatus: "N",
            hasCancelled: hasCancelled,
            hasTimedOut: hasTimedOut,
            cardholderInfo: nil
        )

        // Then
        XCTAssertTrue(auth.hasCancelled)
        XCTAssertTrue(auth.hasTimedOut)
    }

    func testGr4vyAuthenticationWithNoCancellationOrTimeout() {
        // Given
        let hasCancelled = false
        let hasTimedOut = false

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: "frictionless",
            transactionStatus: "Y",
            hasCancelled: hasCancelled,
            hasTimedOut: hasTimedOut,
            cardholderInfo: nil
        )

        // Then
        XCTAssertFalse(auth.hasCancelled)
        XCTAssertFalse(auth.hasTimedOut)
    }

    // MARK: - Cardholder Info Tests

    func testGr4vyAuthenticationWithCardholderInfo() {
        // Given
        let cardholderInfo = "Thank you for completing authentication"

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: "challenge",
            transactionStatus: "Y",
            cardholderInfo: cardholderInfo
        )

        // Then
        XCTAssertEqual(auth.cardholderInfo, cardholderInfo)
    }

    func testGr4vyAuthenticationWithLongCardholderInfo() {
        // Given
        let cardholderInfo = String(repeating: "Test message. ", count: 100)

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: "challenge",
            transactionStatus: "Y",
            cardholderInfo: cardholderInfo
        )

        // Then
        XCTAssertEqual(auth.cardholderInfo, cardholderInfo)
    }

    func testGr4vyAuthenticationWithEmptyCardholderInfo() {
        // Given
        let cardholderInfo = ""

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: "challenge",
            transactionStatus: "Y",
            cardholderInfo: cardholderInfo
        )

        // Then
        XCTAssertEqual(auth.cardholderInfo, "")
    }

    func testGr4vyAuthenticationWithSpecialCharactersInCardholderInfo() {
        // Given
        let cardholderInfo = "Success! ✅ Authentication completed @ 100% 🎉"

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: "frictionless",
            transactionStatus: "Y",
            cardholderInfo: cardholderInfo
        )

        // Then
        XCTAssertEqual(auth.cardholderInfo, cardholderInfo)
    }

    // MARK: - Edge Cases

    func testGr4vyAuthenticationNotAttempted() {
        // Given
        let attempted = false

        // When
        let auth = Gr4vyAuthentication(
            attempted: attempted,
            type: nil,
            transactionStatus: nil,
            cardholderInfo: nil
        )

        // Then
        XCTAssertFalse(auth.attempted)
        XCTAssertNil(auth.type)
        XCTAssertNil(auth.transactionStatus)
        XCTAssertFalse(auth.hasCancelled)
        XCTAssertFalse(auth.hasTimedOut)
    }

    func testGr4vyAuthenticationWithEmptyStrings() {
        // Given
        let type = ""
        let transactionStatus = ""
        let cardholderInfo = ""

        // When
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: type,
            transactionStatus: transactionStatus,
            cardholderInfo: cardholderInfo
        )

        // Then
        XCTAssertEqual(auth.type, "")
        XCTAssertEqual(auth.transactionStatus, "")
        XCTAssertEqual(auth.cardholderInfo, "")
    }

    // MARK: - Gr4vyAuthenticationType Enum Tests

    func testGr4vyAuthenticationTypeFrictionless() {
        // Given
        let type = Gr4vyAuthenticationType.frictionless

        // Then
        XCTAssertEqual(type.rawValue, "frictionless")
    }

    func testGr4vyAuthenticationTypeChallenge() {
        // Given
        let type = Gr4vyAuthenticationType.challenge

        // Then
        XCTAssertEqual(type.rawValue, "challenge")
    }

    func testGr4vyAuthenticationTypeError() {
        // Given
        let type = Gr4vyAuthenticationType.error

        // Then
        XCTAssertEqual(type.rawValue, "error")
    }

    func testGr4vyAuthenticationTypeFromRawValue() {
        // Test successful creation from raw value
        XCTAssertEqual(Gr4vyAuthenticationType(rawValue: "frictionless"), .frictionless)
        XCTAssertEqual(Gr4vyAuthenticationType(rawValue: "challenge"), .challenge)
        XCTAssertEqual(Gr4vyAuthenticationType(rawValue: "error"), .error)

        // Test failure with invalid raw value
        XCTAssertNil(Gr4vyAuthenticationType(rawValue: "invalid"))
        XCTAssertNil(Gr4vyAuthenticationType(rawValue: ""))
    }

    // MARK: - Complex Scenarios

    func testGr4vyAuthenticationSuccessfulFrictionlessFlow() {
        // Given - Simulating a successful frictionless authentication
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: Gr4vyAuthenticationType.frictionless.rawValue,
            transactionStatus: "Y",
            hasCancelled: false,
            hasTimedOut: false,
            cardholderInfo: "Authentication successful"
        )

        // Then
        XCTAssertTrue(auth.attempted)
        XCTAssertEqual(auth.type, "frictionless")
        XCTAssertEqual(auth.transactionStatus, "Y")
        XCTAssertFalse(auth.hasCancelled)
        XCTAssertFalse(auth.hasTimedOut)
        XCTAssertNotNil(auth.cardholderInfo)
    }

    func testGr4vyAuthenticationFailedChallengeFlow() {
        // Given - Simulating a failed challenge authentication
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: Gr4vyAuthenticationType.challenge.rawValue,
            transactionStatus: "N",
            hasCancelled: false,
            hasTimedOut: false,
            cardholderInfo: "Authentication failed. Please try again."
        )

        // Then
        XCTAssertTrue(auth.attempted)
        XCTAssertEqual(auth.type, "challenge")
        XCTAssertEqual(auth.transactionStatus, "N")
        XCTAssertFalse(auth.hasCancelled)
        XCTAssertFalse(auth.hasTimedOut)
        XCTAssertNotNil(auth.cardholderInfo)
    }

    func testGr4vyAuthenticationUserCancelledChallengeFlow() {
        // Given - Simulating a user-cancelled challenge
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: Gr4vyAuthenticationType.challenge.rawValue,
            transactionStatus: "N",
            hasCancelled: true,
            hasTimedOut: false,
            cardholderInfo: "User cancelled the authentication process"
        )

        // Then
        XCTAssertTrue(auth.attempted)
        XCTAssertEqual(auth.type, "challenge")
        XCTAssertEqual(auth.transactionStatus, "N")
        XCTAssertTrue(auth.hasCancelled)
        XCTAssertFalse(auth.hasTimedOut)
        XCTAssertNotNil(auth.cardholderInfo)
    }

    func testGr4vyAuthenticationTimeoutScenario() {
        // Given - Simulating a timeout scenario
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: Gr4vyAuthenticationType.challenge.rawValue,
            transactionStatus: "N",
            hasCancelled: false,
            hasTimedOut: true,
            cardholderInfo: "Authentication request timed out"
        )

        // Then
        XCTAssertTrue(auth.attempted)
        XCTAssertEqual(auth.type, "challenge")
        XCTAssertEqual(auth.transactionStatus, "N")
        XCTAssertFalse(auth.hasCancelled)
        XCTAssertTrue(auth.hasTimedOut)
        XCTAssertNotNil(auth.cardholderInfo)
    }

    func testGr4vyAuthenticationErrorScenario() {
        // Given - Simulating an error scenario
        let auth = Gr4vyAuthentication(
            attempted: true,
            type: Gr4vyAuthenticationType.error.rawValue,
            transactionStatus: "U",
            hasCancelled: false,
            hasTimedOut: false,
            cardholderInfo: "Technical error occurred during authentication"
        )

        // Then
        XCTAssertTrue(auth.attempted)
        XCTAssertEqual(auth.type, "error")
        XCTAssertEqual(auth.transactionStatus, "U")
        XCTAssertFalse(auth.hasCancelled)
        XCTAssertFalse(auth.hasTimedOut)
        XCTAssertNotNil(auth.cardholderInfo)
    }
}
