//
//  Gr4vyCardDetailsService.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

// API Documentation: https://docs.gr4vy.com/reference/card-details/get-card-details#get-card-details

public final class Gr4vyCardDetailsService {
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
    
    @discardableResult
    public func get(request: Gr4vyCardDetailsRequest) async throws -> Gr4vyCardDetailsResponse {
        try await fetch(request: request)
    }
    
    public func get(
        request: Gr4vyCardDetailsRequest,
        completion: @escaping (Result<Gr4vyCardDetailsResponse, Error>) -> Void
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
    private func fetch(request: Gr4vyCardDetailsRequest) async throws -> Gr4vyCardDetailsResponse {
        let url = try Gr4vyUtility.cardDetailsURL(from: configuration.setup)

        let data = try await httpClient.perform(
            to: url,
            method: "GET",
            body: request,
            merchantId: nil,
            timeout: request.timeout
        )

        return try JSONDecoder().decode(Gr4vyCardDetailsResponse.self, from: data)
    }
}
