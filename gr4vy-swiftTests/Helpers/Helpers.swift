//
//  Helpers.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation
@testable import gr4vy_swift

///

///

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
