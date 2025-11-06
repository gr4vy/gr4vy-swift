//
//  Gr4vyPaymentOptionsService.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

// API Documentation: https://docs.gr4vy.com/guides/api/payment-options

public final class Gr4vyPaymentOptionsService {
    // MARK: - Properties
    private var httpClient: Gr4vyHTTPClientProtocol
    private var configuration: Gr4vyHTTPConfiguration
    
    public let debugMode: Bool
    
    // MARK: - Initializer
    public init(setup: Gr4vySetup, debugMode: Bool = false, session: URLSessionProtocol = URLSession.shared) {
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
    
    @discardableResult
    public func list(request: Gr4vyPaymentOptionRequest) async throws -> [Gr4vyPaymentOption] {
        try await fetch(request: request)
    }
    
    public func list(
        request: Gr4vyPaymentOptionRequest,
        completion: @escaping (Result<[Gr4vyPaymentOption], Error>) -> Void
    ) {
        Task {
            do {
                let items = try await fetch(request: request)
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private Methods
    private func fetch(request: Gr4vyPaymentOptionRequest) async throws -> [Gr4vyPaymentOption] {
        let url = try Gr4vyUtility.paymentOptionsURL(from: configuration.setup)

        let data = try await httpClient.perform(
            to: url,
            method: "POST",
            body: request,
            merchantId: request.merchantId ?? configuration.setup.merchantId,
            timeout: request.timeout
        )

        let wrapper = try JSONDecoder().decode(PaymentOptionsWrapper.self, from: data)
        return wrapper.items
    }
}
