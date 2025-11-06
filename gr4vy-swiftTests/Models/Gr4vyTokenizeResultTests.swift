//
//  Gr4vyTokenizeResultTests.swift
//  gr4vy-swiftTests
//
//  Created by Gr4vy
//

@testable import gr4vy_swift
import XCTest

final class Gr4vyTokenizeResultTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Initialization Tests

    func testGr4vyTokenizeResultInitializationWithAuthentication() {
        // Given
        let tokenized = true
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: "frictionless",
            transactionStatus: "Y",
            cardholderInfo: nil
        )

        // When
        let result = Gr4vyTokenizeResult(
            tokenized: tokenized,
            authentication: authentication
        )

        // Then
        XCTAssertEqual(result.tokenized, true)
        XCTAssertNotNil(result.authentication)
        XCTAssertEqual(result.authentication?.attempted, true)
        XCTAssertEqual(result.authentication?.type, "frictionless")
        XCTAssertEqual(result.authentication?.transactionStatus, "Y")
    }

    func testGr4vyTokenizeResultInitializationWithoutAuthentication() {
        // Given
        let tokenized = true

        // When
        let result = Gr4vyTokenizeResult(tokenized: tokenized)

        // Then
        XCTAssertEqual(result.tokenized, true)
        XCTAssertNil(result.authentication)
    }

    func testGr4vyTokenizeResultInitializationWithNilAuthentication() {
        // Given
        let tokenized = false
        let authentication: Gr4vyAuthentication? = nil

        // When
        let result = Gr4vyTokenizeResult(
            tokenized: tokenized,
            authentication: authentication
        )

        // Then
        XCTAssertEqual(result.tokenized, false)
        XCTAssertNil(result.authentication)
    }

    // MARK: - Success Scenarios

    func testGr4vyTokenizeResultSuccessWithoutThreeDS() {
        // Given - Simulating successful tokenization without 3DS
        let tokenized = true
        let authentication: Gr4vyAuthentication? = nil

        // When
        let result = Gr4vyTokenizeResult(
            tokenized: tokenized,
            authentication: authentication
        )

        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNil(result.authentication)
    }

    func testGr4vyTokenizeResultSuccessWithFrictionlessThreeDS() {
        // Given - Simulating successful tokenization with frictionless 3DS
        let tokenized = true
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: "frictionless",
            transactionStatus: "Y",
            hasCancelled: false,
            hasTimedOut: false,
            cardholderInfo: "Authentication successful"
        )

        // When
        let result = Gr4vyTokenizeResult(
            tokenized: tokenized,
            authentication: authentication
        )

        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNotNil(result.authentication)
        XCTAssertTrue(result.authentication!.attempted)
        XCTAssertEqual(result.authentication!.type, "frictionless")
        XCTAssertEqual(result.authentication!.transactionStatus, "Y")
        XCTAssertFalse(result.authentication!.hasCancelled)
        XCTAssertFalse(result.authentication!.hasTimedOut)
    }

    func testGr4vyTokenizeResultSuccessWithChallengeThreeDS() {
        // Given - Simulating successful tokenization with challenge 3DS
        let tokenized = true
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: "challenge",
            transactionStatus: "Y",
            hasCancelled: false,
            hasTimedOut: false,
            cardholderInfo: "Challenge completed successfully"
        )

        // When
        let result = Gr4vyTokenizeResult(
            tokenized: tokenized,
            authentication: authentication
        )

        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNotNil(result.authentication)
        XCTAssertTrue(result.authentication!.attempted)
        XCTAssertEqual(result.authentication!.type, "challenge")
        XCTAssertEqual(result.authentication!.transactionStatus, "Y")
    }

    // MARK: - Failure Scenarios

    func testGr4vyTokenizeResultFailureWithoutAuthentication() {
        // Given - Simulating failed tokenization without 3DS
        let tokenized = false

        // When
        let result = Gr4vyTokenizeResult(tokenized: tokenized)

        // Then
        XCTAssertFalse(result.tokenized)
        XCTAssertNil(result.authentication)
    }

    func testGr4vyTokenizeResultFailureWithFailedAuthentication() {
        // Given - Simulating failed tokenization with failed 3DS
        let tokenized = false
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: "challenge",
            transactionStatus: "N",
            hasCancelled: false,
            hasTimedOut: false,
            cardholderInfo: "Authentication failed"
        )

        // When
        let result = Gr4vyTokenizeResult(
            tokenized: tokenized,
            authentication: authentication
        )

        // Then
        XCTAssertFalse(result.tokenized)
        XCTAssertNotNil(result.authentication)
        XCTAssertTrue(result.authentication!.attempted)
        XCTAssertEqual(result.authentication!.transactionStatus, "N")
    }

    func testGr4vyTokenizeResultFailureWithCancelledAuthentication() {
        // Given - Simulating failed tokenization due to user cancellation
        let tokenized = false
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: "challenge",
            transactionStatus: "N",
            hasCancelled: true,
            hasTimedOut: false,
            cardholderInfo: "User cancelled"
        )

        // When
        let result = Gr4vyTokenizeResult(
            tokenized: tokenized,
            authentication: authentication
        )

        // Then
        XCTAssertFalse(result.tokenized)
        XCTAssertNotNil(result.authentication)
        XCTAssertTrue(result.authentication!.hasCancelled)
        XCTAssertFalse(result.authentication!.hasTimedOut)
    }

    func testGr4vyTokenizeResultFailureWithTimedOutAuthentication() {
        // Given - Simulating failed tokenization due to timeout
        let tokenized = false
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: "challenge",
            transactionStatus: "N",
            hasCancelled: false,
            hasTimedOut: true,
            cardholderInfo: "Authentication timed out"
        )

        // When
        let result = Gr4vyTokenizeResult(
            tokenized: tokenized,
            authentication: authentication
        )

        // Then
        XCTAssertFalse(result.tokenized)
        XCTAssertNotNil(result.authentication)
        XCTAssertFalse(result.authentication!.hasCancelled)
        XCTAssertTrue(result.authentication!.hasTimedOut)
    }

    func testGr4vyTokenizeResultFailureWithAuthenticationError() {
        // Given - Simulating failed tokenization with authentication error
        let tokenized = false
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: "error",
            transactionStatus: "U",
            hasCancelled: false,
            hasTimedOut: false,
            cardholderInfo: "Technical error"
        )

        // When
        let result = Gr4vyTokenizeResult(
            tokenized: tokenized,
            authentication: authentication
        )

        // Then
        XCTAssertFalse(result.tokenized)
        XCTAssertNotNil(result.authentication)
        XCTAssertEqual(result.authentication!.type, "error")
        XCTAssertEqual(result.authentication!.transactionStatus, "U")
    }

    // MARK: - Authentication Not Attempted Scenarios

    func testGr4vyTokenizeResultWithAuthenticationNotAttempted() {
        // Given - Simulating tokenization where 3DS was not attempted
        let tokenized = true
        let authentication = Gr4vyAuthentication(
            attempted: false,
            type: nil,
            transactionStatus: nil,
            cardholderInfo: nil
        )

        // When
        let result = Gr4vyTokenizeResult(
            tokenized: tokenized,
            authentication: authentication
        )

        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNotNil(result.authentication)
        XCTAssertFalse(result.authentication!.attempted)
        XCTAssertNil(result.authentication!.type)
        XCTAssertNil(result.authentication!.transactionStatus)
    }

    // MARK: - Complex Scenarios

    func testGr4vyTokenizeResultSuccessfulEndToEndFlow() {
        // Given - Complete successful flow with all authentication details
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: "frictionless",
            transactionStatus: "Y",
            hasCancelled: false,
            hasTimedOut: false,
            cardholderInfo: "Thank you for completing authentication"
        )
        let result = Gr4vyTokenizeResult(
            tokenized: true,
            authentication: authentication
        )

        // Then - Verify complete state
        XCTAssertTrue(result.tokenized)
        XCTAssertNotNil(result.authentication)
        
        let auth = result.authentication!
        XCTAssertTrue(auth.attempted)
        XCTAssertEqual(auth.type, "frictionless")
        XCTAssertEqual(auth.transactionStatus, "Y")
        XCTAssertFalse(auth.hasCancelled)
        XCTAssertFalse(auth.hasTimedOut)
        XCTAssertNotNil(auth.cardholderInfo)
    }

    func testGr4vyTokenizeResultPartialSuccessScenario() {
        // Given - Authentication attempted but resulted in specific status
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: "frictionless",
            transactionStatus: "A", // Attempted
            hasCancelled: false,
            hasTimedOut: false,
            cardholderInfo: "Authentication attempted"
        )
        let result = Gr4vyTokenizeResult(
            tokenized: true,
            authentication: authentication
        )

        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNotNil(result.authentication)
        XCTAssertTrue(result.authentication!.attempted)
        XCTAssertEqual(result.authentication!.transactionStatus, "A")
    }

    func testGr4vyTokenizeResultWithAllAuthenticationStatusCodes() {
        // Test various EMVCo status codes
        let statusCodes = ["Y", "N", "U", "A", "C", "R", "D"]
        
        for status in statusCodes {
            // Given
            let authentication = Gr4vyAuthentication(
                attempted: true,
                type: "frictionless",
                transactionStatus: status,
                cardholderInfo: nil
            )
            
            // When
            let result = Gr4vyTokenizeResult(
                tokenized: true,
                authentication: authentication
            )
            
            // Then
            XCTAssertEqual(result.authentication?.transactionStatus, status, "Failed for status: \(status)")
        }
    }

    // MARK: - Edge Cases

    func testGr4vyTokenizeResultWithMinimalData() {
        // Given - Minimal valid data
        let result = Gr4vyTokenizeResult(tokenized: false)

        // Then
        XCTAssertFalse(result.tokenized)
        XCTAssertNil(result.authentication)
    }

    func testGr4vyTokenizeResultWithCompleteAuthenticationData() {
        // Given - All possible authentication fields populated
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: "challenge",
            transactionStatus: "Y",
            hasCancelled: false,
            hasTimedOut: false,
            cardholderInfo: "Complete authentication information with all fields populated"
        )
        let result = Gr4vyTokenizeResult(
            tokenized: true,
            authentication: authentication
        )

        // Then - All fields should be preserved
        XCTAssertTrue(result.tokenized)
        let auth = result.authentication!
        XCTAssertTrue(auth.attempted)
        XCTAssertEqual(auth.type, "challenge")
        XCTAssertEqual(auth.transactionStatus, "Y")
        XCTAssertFalse(auth.hasCancelled)
        XCTAssertFalse(auth.hasTimedOut)
        XCTAssertNotNil(auth.cardholderInfo)
    }

    func testGr4vyTokenizeResultSuccessWithMultipleTransactionStatuses() {
        // Test different combinations of tokenization success with various transaction statuses
        let testCases: [(Bool, String)] = [
            (true, "Y"),   // Success with successful auth
            (true, "A"),   // Success with attempted auth
            (false, "N"),  // Failure with failed auth
            (false, "U"),  // Failure with unavailable auth
        ]
        
        for (tokenized, status) in testCases {
            // Given
            let authentication = Gr4vyAuthentication(
                attempted: true,
                type: "frictionless",
                transactionStatus: status,
                cardholderInfo: nil
            )
            
            // When
            let result = Gr4vyTokenizeResult(
                tokenized: tokenized,
                authentication: authentication
            )
            
            // Then
            XCTAssertEqual(result.tokenized, tokenized)
            XCTAssertEqual(result.authentication?.transactionStatus, status)
        }
    }

    // MARK: - Mixed State Tests

    func testGr4vyTokenizeResultTokenizedTrueButAuthenticationFailed() {
        // Given - Edge case where tokenization succeeded but auth failed
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: "challenge",
            transactionStatus: "N",
            hasCancelled: false,
            hasTimedOut: false,
            cardholderInfo: "Authentication failed but tokenization succeeded"
        )
        let result = Gr4vyTokenizeResult(
            tokenized: true,
            authentication: authentication
        )

        // Then
        XCTAssertTrue(result.tokenized)
        XCTAssertNotNil(result.authentication)
        XCTAssertEqual(result.authentication!.transactionStatus, "N")
    }

    func testGr4vyTokenizeResultTokenizedFalseButAuthenticationSucceeded() {
        // Given - Edge case where auth succeeded but tokenization failed
        let authentication = Gr4vyAuthentication(
            attempted: true,
            type: "frictionless",
            transactionStatus: "Y",
            hasCancelled: false,
            hasTimedOut: false,
            cardholderInfo: "Authentication succeeded but tokenization failed"
        )
        let result = Gr4vyTokenizeResult(
            tokenized: false,
            authentication: authentication
        )

        // Then
        XCTAssertFalse(result.tokenized)
        XCTAssertNotNil(result.authentication)
        XCTAssertEqual(result.authentication!.transactionStatus, "Y")
    }
}
