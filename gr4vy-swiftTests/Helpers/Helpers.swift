//
//  Helpers.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation
@testable import gr4vy_swift
import ThreeDS_SDK
import UIKit

final class MockHTTPClient: Gr4vyHTTPClientProtocol {
    // MARK: – Fixtures tailored per test
    var error: Error?
    var data: Data?
    var response: (any Encodable)?

    // MARK: – Captured request for assertions
    private(set) var lastURL: URL?
    private(set) var lastMethod: String?
    private(set) var lastBody: Data?

    // MARK: – Protocol conformance
    func perform<Request: Encodable>(
        to url: URL,
        method: String,
        body: Request?,
        merchantId: String?,
        timeout: TimeInterval?
    ) async throws -> Data {
        // Record inputs so tests can verify them.
        lastURL = url
        lastMethod = method
        if let body = body {
            lastBody = try JSONEncoder().encode(body)
        }

        // 1. Throw a configured error first.
        if let error = error {
            throw error
        }

        // 2. Return raw data if supplied.
        if let data = data {
            return data
        }

        // 3. Encode the provided Encodable response.
        if let encodable = response {
            return try JSONEncoder().encode(AnyEncodable(encodable))
        }

        // 4. Nothing was configured – fail loudly.
        throw Gr4vyError.decodingError("No mock fixture configured")
    }
}

// MARK: – Helper to erase the concrete type of an `Encodable`
private struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init<T: Encodable>(_ value: T) {
        self.encodeFunc = value.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

// MARK: - Mock URLSession for Testing
class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    var lastRequest: URLRequest?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request

        if let error = mockError {
            throw error
        }

        let data = mockData ?? Data()
        let response = mockResponse ?? HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        return (data, response)
    }
}

// MARK: - Fake 3DS SDK Types for Testing
//
// `Transaction` and `ProgressDialog` are protocols in the Netcetera SDK itself
// (not concrete classes), so they can be faked directly without any seam of
// our own — no extension-conformance trick needed, unlike `URLSessionProtocol`
// above where the SDK type is concrete.

/// No-op progress dialog double.
final class MockProgressDialog: ProgressDialog {
    private(set) var startCalled = false
    private(set) var stopCalled = false

    func start() { startCalled = true }
    func stop() { stopCalled = true }
}

/// Fake `Transaction` whose `doChallenge` behavior is scripted per test, so tests
/// can drive `Gr4vy3DSService.performChallengeFlow` through the paths that
/// matter without a real 3DS SDK instance: normal completion via the receiver,
/// `doChallenge` throwing instead of calling the receiver, and a progress view
/// that itself fails to appear (non-fatal per the production code).
final class FakeTransaction: Transaction {
    /// Invoked from `doChallenge` with the receiver the production code passed
    /// in, so a test can call back into it (e.g. `receiver.cancelled()`) the way
    /// the real SDK would, or throw instead.
    var doChallengeBehavior: (any ChallengeStatusReceiver) async throws -> Void = { _ in }

    /// When true, `getProgressView()` throws — exercising the "progress dialog
    /// unavailable" branch, which production code treats as non-fatal.
    var getProgressViewThrows = false

    private(set) var doChallengeCallCount = 0

    func getAuthenticationRequestParameters() throws -> AuthenticationRequestParameters {
        // Not exercised by performChallengeFlow — called earlier, on the
        // transaction returned by createTransaction.
        fatalError("getAuthenticationRequestParameters not stubbed for this test")
    }

    @MainActor
    func getProgressView() throws -> any ProgressDialog {
        if getProgressViewThrows {
            throw Gr4vyError.threeDSError("progress view unavailable")
        }
        return MockProgressDialog()
    }

    func doChallenge(
        challengeParameters: ChallengeParameters,
        challengeStatusReceiver: any ChallengeStatusReceiver,
        timeOut: Int,
        inViewController: UIViewController
    ) async throws {
        doChallengeCallCount += 1
        try await doChallengeBehavior(challengeStatusReceiver)
    }

    func useBridgingExtension(version: BridgingExtensionVersion) {
        // Not exercised by any current gr4vy-swift code path.
    }

    func close() async throws {
        // Not exercised by performChallengeFlow.
    }
}
