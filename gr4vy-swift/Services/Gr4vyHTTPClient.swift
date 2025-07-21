//
//  Gr4vyHTTPClient.swift
//  gr4vy-swift
//
//  Created by Gr4vy
//

import Foundation

// MARK: - Protocol Definition
public protocol Gr4vyHTTPClientProtocol {
    func perform<Request: Encodable>(
        to url: URL,
        method: String,
        body: Request?,
        merchantId: String?,
        timeout: TimeInterval?
    ) async throws -> Data
}

// MARK: - Protocol for URLSession abstraction
public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

// MARK: - Configuration Object
public struct Gr4vyHTTPConfiguration {
    // MARK: - Properties
    public let setup: Gr4vySetup
    public let debugMode: Bool
    public let session: URLSessionProtocol

    // MARK: - Initializer
    public init(setup: Gr4vySetup, debugMode: Bool = false, session: URLSessionProtocol = URLSession.shared) {
        self.setup = setup
        self.debugMode = debugMode
        self.session = session
    }

    // MARK: - Public Methods
    public func updated(with newSetup: Gr4vySetup) -> Gr4vyHTTPConfiguration {
        Gr4vyHTTPConfiguration(
            setup: newSetup,
            debugMode: debugMode,
            session: session
        )
    }
}

// MARK: - HTTP Client Implementation
public final class Gr4vyHTTPClient: Gr4vyHTTPClientProtocol {
    // MARK: - Properties
    private let configuration: Gr4vyHTTPConfiguration
    private let queue = DispatchQueue(label: "com.gr4vy.httpclient", qos: .utility)

    // MARK: - Initializer
    public init(configuration: Gr4vyHTTPConfiguration) {
        self.configuration = configuration
    }

    // MARK: - Public Methods
    public func perform<Request: Encodable>(
        to url: URL,
        method: String = "POST",
        body: Request?,
        merchantId: String?,
        timeout: TimeInterval? = nil
    ) async throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys

        var finalURL = url
        var httpBody: Data?

        // Handle request body encoding
        if let body = body {
            if method.uppercased() == "GET" {
                finalURL = try await buildURLWithQueryParams(url: url, body: body, encoder: encoder)
            } else {
                httpBody = try encoder.encode(body)
            }
        }

        let request = try buildURLRequest(
            url: finalURL,
            method: method,
            body: httpBody,
            merchantId: merchantId,
            timeout: timeout
        )

        return try await performRequest(request)
    }

    // MARK: - Private Methods

    private func buildURLWithQueryParams<Request: Encodable>(
        url: URL,
        body: Request,
        encoder: JSONEncoder
    ) async throws -> URL {
        let data = try encoder.encode(body)
        guard var root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            Gr4vyLogger.error("JSON Serialization failed")
            throw Gr4vyError.decodingError("Failed to serialize request body")
        }

        // Remove nulls
        root = root.filter { !($0.value is NSNull) }

        // Flatten single wrapper key
        if root.count == 1, let onlyValue = root.values.first as? [String: Any] {
            root = onlyValue
        }

        // Build query items
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false) ?? URLComponents()
        components.queryItems = (components.queryItems ?? []) + queryItems(from: root)

        guard let urlWithQuery = components.url else {
            throw Gr4vyError.badURL("Failed to build URL with query parameters")
        }

        return urlWithQuery
    }

    private func buildURLRequest(
        url: URL,
        method: String,
        body: Data?,
        merchantId: String?,
        timeout: TimeInterval?
    ) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.timeoutInterval = timeout ?? configuration.setup.timeout

        // Add headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Gr4vySDK.userAgent, forHTTPHeaderField: "User-Agent")
        if let authToken = configuration.setup.token {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        if let merchantId, !merchantId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            request.addValue(merchantId, forHTTPHeaderField: "x-gr4vy-merchant-account-id")
        }

        return request
    }

    private func performRequest(_ request: URLRequest) async throws -> Data {
        // Log request
        Gr4vyLogger.network("\(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
        if configuration.debugMode, let body = request.httpBody {
            Gr4vyLogger.debug(body)
        }

        let startTime = Date()

        do {
            let (data, response) = try await configuration.session.data(for: request)
            let responseTime = Date().timeIntervalSince(startTime)

            try validateResponse(response, data: data, responseTime: responseTime, url: request.url)

            return data
        } catch {
            Gr4vyLogger.error("Network Request failed: \(error.localizedDescription)")

            if let urlError = error as? URLError {
                throw Gr4vyError.networkError(urlError)
            }

            throw error
        }
    }

    private func validateResponse(
        _ response: URLResponse?,
        data: Data,
        responseTime: TimeInterval,
        url: URL?
    ) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            Gr4vyLogger.error("Invalid HTTP Response")
            throw Gr4vyError.networkError(URLError(.badServerResponse))
        }

        let urlString = url?.absoluteString ?? "unknown"
        let responseTimeString = String(format: "%.2f", responseTime)

        guard (200...299).contains(httpResponse.statusCode) else {
            // Log error response
            Gr4vyLogger.error("\(httpResponse.statusCode) \(urlString) (\(responseTimeString)s)")
            if configuration.debugMode {
                Gr4vyLogger.debug(data)
            }

            let errorMessage = extractErrorMessage(from: data)
            throw Gr4vyError.httpError(
                statusCode: httpResponse.statusCode,
                responseData: data,
                message: errorMessage
            )
        }

        // Log successful response
        Gr4vyLogger.network("\(httpResponse.statusCode) \(urlString) (\(responseTimeString)s)")
        if configuration.debugMode {
            Gr4vyLogger.debug(data)
        }
    }

    private func extractErrorMessage(from data: Data) -> String? {
        guard let responseString = String(data: data, encoding: .utf8) else {
            return nil
        }

        // Try to parse JSON error response
        if let jsonData = responseString.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            return json["message"] as? String ?? json["error"] as? String
        }

        return responseString
    }

    // MARK: - Query Items Helper
    private func queryItems(from value: Any, prefix: String? = nil) -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        switch value {
        case let dict as [String: Any]:
            for (key, val) in dict where !(val is NSNull) {
                let newPrefix = prefix != nil ? "\(prefix!).\(key)" : key
                items.append(contentsOf: queryItems(from: val, prefix: newPrefix))
            }
        case let array as [Any]:
            for val in array where !(val is NSNull) {
                let key = (prefix ?? "array") + "[]"
                items.append(URLQueryItem(name: key, value: String(describing: val)))
            }
        default:
            if let key = prefix {
                items.append(URLQueryItem(name: key, value: String(describing: value)))
            }
        }

        return items
    }
}

// MARK: - Factory
public struct Gr4vyHTTPClientFactory {
    // MARK: - Public Methods
    public static func create(
        setup: Gr4vySetup,
        debugMode: Bool = false,
        session: URLSessionProtocol = URLSession.shared
    ) -> Gr4vyHTTPClientProtocol {
        let configuration = Gr4vyHTTPConfiguration(
            setup: setup,
            debugMode: debugMode,
            session: session
        )
        return Gr4vyHTTPClient(configuration: configuration)
    }
}
