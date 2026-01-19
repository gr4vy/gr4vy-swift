@testable import gr4vy_swift
import XCTest

class Gr4vyHTTPClientTests: XCTestCase {
    var configuration: Gr4vyHTTPConfiguration!
    var mockSession: MockURLSession!
    var httpClient: Gr4vyHTTPClient!

    override func setUpWithError() throws {
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "default-test-merchant",
            server: .sandbox,
            timeout: 30
        )

        mockSession = MockURLSession()
        configuration = Gr4vyHTTPConfiguration(
            setup: setup,
            debugMode: true,
            session: mockSession
        )

        httpClient = Gr4vyHTTPClient(configuration: configuration)
    }

    override func tearDownWithError() throws {
        configuration = nil
        mockSession = nil
        httpClient = nil
    }

    // MARK: - Request Building Tests
    func testHTTPClientBuildsCorrectPOSTRequest() async throws {
        // Setup mock response
        let mockData = """
        {"success": true}
        """.data(using: .utf8)!

        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // Create test request
        struct TestRequest: Encodable {
            let testField: String
        }

        let testRequest = TestRequest(testField: "test-value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        // Execute request
        let result = try await httpClient.perform(
            to: url,
            method: "POST",
            body: testRequest,
            merchantId: "test-merchant",
            timeout: 15
        )

        // Verify request was made correctly
        XCTAssertEqual(mockSession.lastRequest?.url, url)
        XCTAssertEqual(mockSession.lastRequest?.httpMethod, "POST")
        XCTAssertEqual(mockSession.lastRequest?.timeoutInterval, 15)

        // Verify headers
        XCTAssertEqual(mockSession.lastRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(mockSession.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
        XCTAssertEqual(mockSession.lastRequest?.value(forHTTPHeaderField: "x-gr4vy-merchant-account-id"), "test-merchant")

        // Verify user agent header
        let userAgent = mockSession.lastRequest?.value(forHTTPHeaderField: "User-Agent")
        XCTAssertNotNil(userAgent)
        XCTAssertTrue(userAgent!.contains("Gr4vy-iOS-SDK/1.0.1"))
        XCTAssertTrue(userAgent!.contains("iOS"))

        // Verify body
        XCTAssertNotNil(mockSession.lastRequest?.httpBody)
        let bodyData = mockSession.lastRequest?.httpBody
        let decodedBody = try JSONSerialization.jsonObject(with: bodyData!) as! [String: Any]
        XCTAssertEqual(decodedBody["testField"] as? String, "test-value")

        // Verify response
        XCTAssertEqual(result, mockData)
    }

    func testHTTPClientBuildsCorrectGETRequest() async throws {
        // Setup mock response
        let mockData = """
        {"result": "success"}
        """.data(using: .utf8)!

        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // Create test request
        struct TestRequest: Encodable {
            let param1: String
            let param2: Int
        }

        let testRequest = TestRequest(param1: "value1", param2: 42)
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        // Execute request
        let result = try await httpClient.perform(
            to: url,
            method: "GET",
            body: testRequest,
            merchantId: "",
            timeout: nil
        )

        // Verify request was made correctly
        XCTAssertEqual(mockSession.lastRequest?.httpMethod, "GET")
        XCTAssertEqual(mockSession.lastRequest?.timeoutInterval, 30) // Should use default timeout

        // Verify query parameters were added
        let requestURL = mockSession.lastRequest?.url
        XCTAssertNotNil(requestURL)
        XCTAssertTrue(requestURL!.query!.contains("param1=value1"))
        XCTAssertTrue(requestURL!.query!.contains("param2=42"))

        // Verify no body for GET request
        XCTAssertNil(mockSession.lastRequest?.httpBody)

        // Verify response
        XCTAssertEqual(result, mockData)
    }

    func testHTTPClientWithDefaultMethodPOST() async throws {
        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        // Execute request without specifying method (should default to POST)
        _ = try await httpClient.perform(
            to: url,
            body: testRequest,
            merchantId: "test-merchant"
        )

        XCTAssertEqual(mockSession.lastRequest?.httpMethod, "POST")
    }

    func testHTTPClientWithEmptyMerchantId() async throws {
        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        // Execute request with empty merchant ID
        _ = try await httpClient.perform(
            to: url,
            method: "POST",
            body: testRequest,
            merchantId: ""
        )

        // Verify merchant ID header is not set for empty string (empty string is treated as nil)
        XCTAssertNil(mockSession.lastRequest?.value(forHTTPHeaderField: "x-gr4vy-merchant-account-id"))
    }

    func testHTTPClientWithNilBody() async throws {
        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        // Execute request with nil body
        _ = try await httpClient.perform(
            to: url,
            method: "POST",
            body: nil as String?,
            merchantId: "test-merchant"
        )

        // Verify no body is set
        XCTAssertNil(mockSession.lastRequest?.httpBody)
    }

    // MARK: - Query Parameter Tests
    func testGETRequestWithComplexQueryParameters() async throws {
        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct NestedRequest: Encodable {
            let nested: NestedData
        }

        struct NestedData: Encodable {
            let field1: String
            let field2: Int
        }

        let testRequest = NestedRequest(
            nested: NestedData(field1: "test", field2: 123)
        )
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        _ = try await httpClient.perform(
            to: url,
            method: "GET",
            body: testRequest,
            merchantId: "test-merchant"
        )

        let requestURL = mockSession.lastRequest?.url
        XCTAssertNotNil(requestURL)
        let query = requestURL!.query!
        // The implementation flattens single wrapper keys, so "nested" wrapper is removed
        XCTAssertTrue(query.contains("field1=test"))
        XCTAssertTrue(query.contains("field2=123"))
    }

    func testGETRequestWithNullValuesFiltered() async throws {
        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct OptionalRequest: Encodable {
            let required: String
            let optional: String?
        }

        let testRequest = OptionalRequest(required: "test", optional: nil)
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        _ = try await httpClient.perform(
            to: url,
            method: "GET",
            body: testRequest,
            merchantId: "test-merchant"
        )

        let requestURL = mockSession.lastRequest?.url
        XCTAssertNotNil(requestURL)
        let query = requestURL!.query!
        XCTAssertTrue(query.contains("required=test"))
        XCTAssertFalse(query.contains("optional"))
    }

    func testGETRequestWithExistingQueryParameters() async throws {
        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let newParam: String
        }

        let testRequest = TestRequest(newParam: "newValue")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test?existing=value")!

        _ = try await httpClient.perform(
            to: url,
            method: "GET",
            body: testRequest,
            merchantId: "test-merchant"
        )

        let requestURL = mockSession.lastRequest?.url
        XCTAssertNotNil(requestURL)
        let query = requestURL!.query!
        XCTAssertTrue(query.contains("existing=value"))
        XCTAssertTrue(query.contains("newParam=newValue"))
    }

    // MARK: - Error Handling Tests
    func testHTTPClientHandlesHTTPError() async throws {
        // Setup mock error response
        let errorData = """
        {"error": "Invalid request", "message": "Bad request parameters"}
        """.data(using: .utf8)!

        mockSession.mockData = errorData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        // Execute request and expect error
        do {
            _ = try await httpClient.perform(
                to: url,
                method: "POST",
                body: testRequest,
                merchantId: "test-merchant",
                timeout: nil
            )
            XCTFail("Expected error to be thrown")
        } catch let error as Gr4vyError {
            if case .httpError(let statusCode, let responseData, let message) = error {
                XCTAssertEqual(statusCode, 400)
                XCTAssertEqual(responseData, errorData)
                XCTAssertEqual(message, "Bad request parameters")
            } else {
                XCTFail("Expected httpError, got \(error)")
            }
        }
    }

    func testHTTPClientHandlesHTTPErrorWithErrorField() async throws {
        let errorData = """
        {"error": "Invalid token"}
        """.data(using: .utf8)!

        mockSession.mockData = errorData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        do {
            _ = try await httpClient.perform(
                to: url,
                method: "POST",
                body: testRequest,
                merchantId: "test-merchant"
            )
            XCTFail("Expected error to be thrown")
        } catch let error as Gr4vyError {
            if case .httpError(let statusCode, _, let message) = error {
                XCTAssertEqual(statusCode, 401)
                XCTAssertEqual(message, "Invalid token")
            } else {
                XCTFail("Expected httpError, got \(error)")
            }
        }
    }

    func testHTTPClientHandlesHTTPErrorWithNonJSONResponse() async throws {
        let errorData = "Internal Server Error".data(using: .utf8)!

        mockSession.mockData = errorData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        do {
            _ = try await httpClient.perform(
                to: url,
                method: "POST",
                body: testRequest,
                merchantId: "test-merchant"
            )
            XCTFail("Expected error to be thrown")
        } catch let error as Gr4vyError {
            if case .httpError(let statusCode, _, let message) = error {
                XCTAssertEqual(statusCode, 500)
                XCTAssertEqual(message, "Internal Server Error")
            } else {
                XCTFail("Expected httpError, got \(error)")
            }
        }
    }

    func testHTTPClientHandlesHTTPErrorWithInvalidJSONResponse() async throws {
        let errorData = "invalid json {".data(using: .utf8)!

        mockSession.mockData = errorData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 422,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        do {
            _ = try await httpClient.perform(
                to: url,
                method: "POST",
                body: testRequest,
                merchantId: "test-merchant"
            )
            XCTFail("Expected error to be thrown")
        } catch let error as Gr4vyError {
            if case .httpError(let statusCode, _, let message) = error {
                XCTAssertEqual(statusCode, 422)
                XCTAssertEqual(message, "invalid json {")
            } else {
                XCTFail("Expected httpError, got \(error)")
            }
        }
    }

    func testHTTPClientHandlesNetworkError() async throws {
        // Setup mock network error
        mockSession.mockError = URLError(.notConnectedToInternet)

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        // Execute request and expect error
        do {
            _ = try await httpClient.perform(
                to: url,
                method: "POST",
                body: testRequest,
                merchantId: "test-merchant",
                timeout: nil
            )
            XCTFail("Expected error to be thrown")
        } catch let error as Gr4vyError {
            if case .networkError(let urlError) = error {
                XCTAssertEqual(urlError.code, .notConnectedToInternet)
            } else {
                XCTFail("Expected networkError, got \(error)")
            }
        }
    }

    func testHTTPClientHandlesBadServerResponse() async throws {
        // Setup mock with invalid response type
        mockSession.mockData = Data()
        mockSession.mockResponse = URLResponse() // Not HTTPURLResponse

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        do {
            _ = try await httpClient.perform(
                to: url,
                method: "POST",
                body: testRequest,
                merchantId: "test-merchant"
            )
            XCTFail("Expected error to be thrown")
        } catch let error as Gr4vyError {
            if case .networkError(let urlError) = error {
                XCTAssertEqual(urlError.code, .badServerResponse)
            } else {
                XCTFail("Expected networkError with badServerResponse, got \(error)")
            }
        }
    }

    func testHTTPClientHandlesGenericError() async throws {
        // Setup mock with generic error
        struct CustomError: Error {}
        mockSession.mockError = CustomError()

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        do {
            _ = try await httpClient.perform(
                to: url,
                method: "POST",
                body: testRequest,
                merchantId: "test-merchant"
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is CustomError)
        }
    }

    // MARK: - Response Validation Tests
    func testHTTPClientHandlesSuccessStatusCodes() async throws {
        let successCodes = [200, 201, 202, 204, 299]

        for statusCode in successCodes {
            let mockData = "{}".data(using: .utf8)!
            mockSession.mockData = mockData
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )

            struct TestRequest: Encodable {
                let test: String
            }

            let testRequest = TestRequest(test: "value")
            let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

            // Should not throw for success status codes
            let result = try await httpClient.perform(
                to: url,
                method: "POST",
                body: testRequest,
                merchantId: "test-merchant"
            )

            XCTAssertEqual(result, mockData)
        }
    }

    func testHTTPClientHandlesErrorStatusCodes() async throws {
        let errorCodes = [300, 400, 401, 404, 500, 502, 503]

        for statusCode in errorCodes {
            let errorData = "{}".data(using: .utf8)!
            mockSession.mockData = errorData
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )

            struct TestRequest: Encodable {
                let test: String
            }

            let testRequest = TestRequest(test: "value")
            let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

            do {
                _ = try await httpClient.perform(
                    to: url,
                    method: "POST",
                    body: testRequest,
                    merchantId: "test-merchant"
                )
                XCTFail("Expected error to be thrown for status code \(statusCode)")
            } catch let error as Gr4vyError {
                if case .httpError(let actualStatusCode, _, _) = error {
                    XCTAssertEqual(actualStatusCode, statusCode)
                } else {
                    XCTFail("Expected httpError for status code \(statusCode), got \(error)")
                }
            }
        }
    }

    // MARK: - Encoding Error Tests
    func testHTTPClientHandlesEncodingError() async throws {
        struct NonEncodableRequest {
            let function: () -> Void = {}
        }

        // This should fail because functions aren't encodable
        // But since we can't make a struct with a function Encodable,
        // let's test with a different approach - invalid JSON serialization

        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        // Test with GET request that has encoding issues
        struct TestRequest: Encodable {
            let validField: String

            func encode(to encoder: Encoder) throws {
                throw EncodingError.invalidValue(
                    self,
                    EncodingError.Context(codingPath: [], debugDescription: "Test encoding error")
                )
            }
        }

        let testRequest = TestRequest(validField: "test")

        do {
            _ = try await httpClient.perform(
                to: url,
                method: "GET",
                body: testRequest,
                merchantId: "test-merchant"
            )
            XCTFail("Expected encoding error to be thrown")
        } catch {
            XCTAssertTrue(error is EncodingError)
        }
    }

    // MARK: - Configuration Tests
    func testHTTPConfigurationUpdate() {
        let originalSetup = Gr4vySetup(
            gr4vyId: "original-id",
            token: "original-token",
            merchantId: "original-merchant",
            server: .sandbox
        )

        let originalConfig = Gr4vyHTTPConfiguration(
            setup: originalSetup,
            debugMode: false
        )

        let newSetup = Gr4vySetup(
            gr4vyId: "new-id",
            token: "new-token",
            merchantId: "new-merchant",
            server: .production
        )

        let updatedConfig = originalConfig.updated(with: newSetup)

        // Verify configuration was updated correctly
        XCTAssertEqual(updatedConfig.setup.gr4vyId, "new-id")
        XCTAssertEqual(updatedConfig.setup.token, "new-token")
        XCTAssertEqual(updatedConfig.setup.merchantId, "new-merchant")
        XCTAssertEqual(updatedConfig.setup.server, .production)
        XCTAssertEqual(updatedConfig.debugMode, false) // Should preserve original debug mode
        // Note: Can't compare sessions directly as URLSessionProtocol doesn't conform to Equatable
    }

    func testHTTPConfigurationInitialization() {
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox,
            timeout: 45
        )

        let mockSession = MockURLSession()

        let config = Gr4vyHTTPConfiguration(
            setup: setup,
            debugMode: true,
            session: mockSession
        )

        XCTAssertEqual(config.setup.gr4vyId, "test-id")
        XCTAssertEqual(config.setup.token, "test-token")
        XCTAssertEqual(config.setup.merchantId, "test-merchant")
        XCTAssertEqual(config.setup.server, .sandbox)
        XCTAssertEqual(config.setup.timeout, 45)
        XCTAssertEqual(config.debugMode, true)
    }

    func testHTTPConfigurationDefaultValues() {
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        let config = Gr4vyHTTPConfiguration(setup: setup)

        XCTAssertEqual(config.debugMode, false)
        XCTAssertTrue(config.session is URLSession)
    }

    // MARK: - Factory Tests
    func testHTTPClientFactory() {
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        let httpClient = Gr4vyHTTPClientFactory.create(
            setup: setup,
            debugMode: true
        )

        XCTAssertNotNil(httpClient)
        XCTAssertTrue(httpClient is Gr4vyHTTPClient)
    }

    func testHTTPClientFactoryWithCustomSession() {
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        let mockSession = MockURLSession()

        let httpClient = Gr4vyHTTPClientFactory.create(
            setup: setup,
            debugMode: false,
            session: mockSession
        )

        XCTAssertNotNil(httpClient)
        XCTAssertTrue(httpClient is Gr4vyHTTPClient)
    }

    func testHTTPClientFactoryDefaultValues() {
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        let httpClient = Gr4vyHTTPClientFactory.create(setup: setup)

        XCTAssertNotNil(httpClient)
        XCTAssertTrue(httpClient is Gr4vyHTTPClient)
    }

    // MARK: - Debug Mode Tests
    func testHTTPClientWithDebugModeDisabled() async throws {
        // Create configuration with debug mode disabled
        let setup = Gr4vySetup(
            gr4vyId: "test-id",
            token: "test-token",
            merchantId: "test-merchant",
            server: .sandbox
        )

        let debugConfig = Gr4vyHTTPConfiguration(
            setup: setup,
            debugMode: false,
            session: mockSession
        )

        let debugClient = Gr4vyHTTPClient(configuration: debugConfig)

        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        // Should work normally with debug mode disabled
        let result = try await debugClient.perform(
            to: url,
            method: "POST",
            body: testRequest,
            merchantId: "test-merchant"
        )

        XCTAssertEqual(result, mockData)
    }

    // MARK: - Edge Cases Tests
    func testHTTPClientWithVeryLongTimeout() async throws {
        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        _ = try await httpClient.perform(
            to: url,
            method: "POST",
            body: testRequest,
            merchantId: "test-merchant",
            timeout: 300.0 // 5 minutes
        )

        XCTAssertEqual(mockSession.lastRequest?.timeoutInterval, 300.0)
    }

    func testHTTPClientWithSpecialCharactersInMerchantId() async throws {
        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        let specialMerchantId = "merchant-123_test@example.com"

        _ = try await httpClient.perform(
            to: url,
            method: "POST",
            body: testRequest,
            merchantId: specialMerchantId
        )

        XCTAssertEqual(
            mockSession.lastRequest?.value(forHTTPHeaderField: "x-gr4vy-merchant-account-id"),
            specialMerchantId
        )
    }

    func testHTTPClientWithDifferentHTTPMethods() async throws {
        let methods = ["PUT", "PATCH", "DELETE"]

        for method in methods {
            let mockData = "{}".data(using: .utf8)!
            mockSession.mockData = mockData
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )

            struct TestRequest: Encodable {
                let test: String
            }

            let testRequest = TestRequest(test: "value")
            let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

            _ = try await httpClient.perform(
                to: url,
                method: method,
                body: testRequest,
                merchantId: "test-merchant"
            )

            XCTAssertEqual(mockSession.lastRequest?.httpMethod, method)
            XCTAssertNotNil(mockSession.lastRequest?.httpBody) // Should have body for non-GET methods
        }
    }

    func testHTTPClientWithEmptyResponseData() async throws {
        let mockData = Data() // Empty data
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        let result = try await httpClient.perform(
            to: url,
            method: "POST",
            body: testRequest,
            merchantId: "test-merchant"
        )

        XCTAssertEqual(result, mockData)
        XCTAssertEqual(result.count, 0)
    }

    // MARK: - MerchantId Comprehensive Tests

    func testHTTPClientWithNilMerchantId() async throws {
        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        // Execute request with nil merchant ID
        _ = try await httpClient.perform(
            to: url,
            method: "POST",
            body: testRequest,
            merchantId: nil
        )

        // Verify merchant ID header is not set when nil
        XCTAssertNil(mockSession.lastRequest?.value(forHTTPHeaderField: "x-gr4vy-merchant-account-id"))

        // Verify other headers are still set correctly
        XCTAssertEqual(mockSession.lastRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(mockSession.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
    }

    func testHTTPClientWithValidMerchantId() async throws {
        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!
        let merchantId = "valid-merchant-123"

        // Execute request with valid merchant ID
        _ = try await httpClient.perform(
            to: url,
            method: "POST",
            body: testRequest,
            merchantId: merchantId
        )

        // Verify merchant ID header is set correctly
        XCTAssertEqual(
            mockSession.lastRequest?.value(forHTTPHeaderField: "x-gr4vy-merchant-account-id"),
            merchantId
        )

        // Verify other headers are still set correctly
        XCTAssertEqual(mockSession.lastRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(mockSession.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
    }

    func testHTTPClientMerchantIdEdgeCases() async throws {
        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        // Test cases: (merchantId, shouldSetHeader, description)
        let testCases: [(String?, Bool, String)] = [
            (nil, false, "nil merchantId"),
            ("", false, "empty merchantId"),
            ("merchant-123", true, "normal merchantId"),
            ("merchant_with_underscores", true, "merchantId with underscores"),
            ("merchant.with.dots", true, "merchantId with dots"),
            ("merchant@domain.com", true, "merchantId with email format"),
            ("123456789", true, "numeric merchantId"),
            ("merchant-with-very-long-name-that-exceeds-normal-length", true, "very long merchantId"),
            ("merchant_测试_🚀", true, "merchantId with Unicode characters"),
        ]

        for (merchantId, shouldSetHeader, description) in testCases {
            // Execute request
            _ = try await httpClient.perform(
                to: url,
                method: "POST",
                body: testRequest,
                merchantId: merchantId
            )

            // Verify header behavior
            let headerValue = mockSession.lastRequest?.value(forHTTPHeaderField: "x-gr4vy-merchant-account-id")
            if shouldSetHeader {
                XCTAssertEqual(headerValue, merchantId, "Failed for case: \(description)")
            } else {
                XCTAssertNil(headerValue, "Failed for case: \(description)")
            }
        }
    }

    func testHTTPClientMerchantIdWithDifferentMethods() async throws {
        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!
        let merchantId = "method-test-merchant"

        let methods = ["GET", "POST", "PUT", "PATCH", "DELETE"]

        for method in methods {
            // Execute request with merchantId
            _ = try await httpClient.perform(
                to: url,
                method: method,
                body: testRequest,
                merchantId: merchantId
            )

            // Verify merchantId header is set for all methods
            XCTAssertEqual(
                mockSession.lastRequest?.value(forHTTPHeaderField: "x-gr4vy-merchant-account-id"),
                merchantId,
                "MerchantId header not set correctly for \(method) method"
            )

            // Verify method is set correctly
            XCTAssertEqual(mockSession.lastRequest?.httpMethod, method)
        }
    }

    func testHTTPClientMerchantIdDoesNotAffectOtherHeaders() async throws {
        let mockData = "{}".data(using: .utf8)!
        mockSession.mockData = mockData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!

        // Test with merchantId
        _ = try await httpClient.perform(
            to: url,
            method: "POST",
            body: testRequest,
            merchantId: "test-merchant",
            timeout: 45.0
        )

        let requestWithMerchant = mockSession.lastRequest!

        // Test without merchantId (nil)
        _ = try await httpClient.perform(
            to: url,
            method: "POST",
            body: testRequest,
            merchantId: nil,
            timeout: 45.0
        )

        let requestWithoutMerchant = mockSession.lastRequest!

        // Verify other headers are identical
        XCTAssertEqual(
            requestWithMerchant.value(forHTTPHeaderField: "Content-Type"),
            requestWithoutMerchant.value(forHTTPHeaderField: "Content-Type")
        )
        XCTAssertEqual(
            requestWithMerchant.value(forHTTPHeaderField: "Authorization"),
            requestWithoutMerchant.value(forHTTPHeaderField: "Authorization")
        )

        // Verify merchantId header difference
        XCTAssertNotNil(requestWithMerchant.value(forHTTPHeaderField: "x-gr4vy-merchant-account-id"))
        XCTAssertNil(requestWithoutMerchant.value(forHTTPHeaderField: "x-gr4vy-merchant-account-id"))

        // Verify other request properties are identical
        XCTAssertEqual(requestWithMerchant.url, requestWithoutMerchant.url)
        XCTAssertEqual(requestWithMerchant.httpMethod, requestWithoutMerchant.httpMethod)
        XCTAssertEqual(requestWithMerchant.timeoutInterval, requestWithoutMerchant.timeoutInterval)
        XCTAssertEqual(requestWithMerchant.httpBody, requestWithoutMerchant.httpBody)
    }

    func testHTTPClientMerchantIdWithErrorResponses() async throws {
        // Test that merchantId is sent even when requests fail
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )
        mockSession.mockData = """
        {"error": "Bad Request"}
        """.data(using: .utf8)!

        struct TestRequest: Encodable {
            let test: String
        }

        let testRequest = TestRequest(test: "value")
        let url = URL(string: "https://api.sandbox.test-id.gr4vy.app/test")!
        let merchantId = "error-test-merchant"

        do {
            _ = try await httpClient.perform(
                to: url,
                method: "POST",
                body: testRequest,
                merchantId: merchantId
            )
            XCTFail("Should have thrown an error")
        } catch {
            // Expected to fail, but verify merchantId header was still sent
            XCTAssertEqual(
                mockSession.lastRequest?.value(forHTTPHeaderField: "x-gr4vy-merchant-account-id"),
                merchantId
            )
        }
    }
}
