//
//  Gr4vyCheckoutSessionService.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

// API Documentation: https://docs.gr4vy.com/reference/checkout-sessions/update-checkout-session-fields

public final class Gr4vyCheckoutSessionService {
    // MARK: - Properties
    private var httpClient: Gr4vyHTTPClientProtocol
    private var configuration: Gr4vyHTTPConfiguration
    public let debugMode: Bool

    // MARK: - Initializer
    public init(setup: Gr4vySetup, debugMode: Bool = false, session: URLSession = .shared) {
        self.configuration = Gr4vyHTTPConfiguration(setup: setup, debugMode: debugMode, session: session)
        self.httpClient = Gr4vyHTTPClientFactory.create(setup: setup, debugMode: debugMode, session: session)
        self.debugMode = debugMode
    }

    public init(httpClient: Gr4vyHTTPClientProtocol, configuration: Gr4vyHTTPConfiguration) {
        self.httpClient = httpClient
        self.configuration = configuration
        self.debugMode = configuration.debugMode
    }

    // MARK: - Public Methods
    public func updateSetup(_ newSetup: Gr4vySetup) {
        self.configuration = configuration.updated(with: newSetup)
        self.httpClient = Gr4vyHTTPClientFactory.create(
            setup: newSetup,
            debugMode: debugMode,
            session: configuration.session
        )
    }

    public func tokenize(checkoutSessionId: String, cardData: Gr4vyCardData) async throws {
        try await performTokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
    }

    public func tokenize(
        checkoutSessionId: String,
        cardData: Gr4vyCardData,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await performTokenize(checkoutSessionId: checkoutSessionId, cardData: cardData)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private Methods
    private func performTokenize(checkoutSessionId: String, cardData: Gr4vyCardData) async throws {
        let url = try Gr4vyUtility.checkoutSessionFieldsURL(from: configuration.setup, checkoutSessionId: checkoutSessionId)

        let requestBody = Gr4vyCheckoutSessionRequest(paymentMethod: cardData.paymentMethod)

        _ = try await httpClient.perform(
            to: url,
            method: "PUT",
            body: requestBody,
            merchantId: nil,
            timeout: requestBody.timeout
        )
    }
}
