# Gr4vy Swift SDK

Developer-friendly & type-safe Swift SDK specifically catered to leverage *Gr4vy* API.

<div align="left">
    <img alt="Build Status" src="https://github.com/gr4vy/gr4vy-swift/actions/workflows/ios.yml/badge.svg?branch=main">
    <img alt="Swift" src="https://img.shields.io/badge/Swift-5.7_5.8_5.9-orange?style=for-the-badge">
    <img alt="Platforms" src="https://img.shields.io/badge/Platforms-iOS-yellowgreen?style=for-the-badge">
    <img alt="CocoaPods Compatible" src="https://img.shields.io/cocoapods/v/gr4vy-swift.svg?style=for-the-badge">
</div>

## Summary

Gr4vy Swift SDK

The official Gr4vy SDK for Swift provides a convenient way to interact with the Gr4vy API from your iOS application. This SDK allows you to seamlessly integrate Gr4vy's powerful payment orchestration capabilities.

This SDK is designed to simplify development, reduce boilerplate code, and help you get up and running with Gr4vy quickly and efficiently. It handles authentication, request management, and provides easy-to-use async/await methods for all API endpoints.

<!-- No Summary [summary] -->

<!-- Start Table of Contents [toc] -->
## Table of Contents
<!-- $toc-max-depth=2 -->
* [Gr4vy Swift SDK](#gr4vy-swift-sdk)
  * [SDK Installation](#sdk-installation)
  * [SDK Example Usage](#sdk-example-usage)
  * [Merchant account ID selection](#merchant-account-id-selection)
  * [Timeout Configuration](#timeout-configuration)
  * [Error Handling](#error-handling)
  * [Server Selection](#server-selection)
  * [Debugging](#debugging)
* [Development](#development)
  * [Testing](#testing)
  * [Migration from UI SDK](#migration-from-ui-sdk)
  * [Contributions](#contributions)

<!-- End Table of Contents [toc] -->

<!-- Start SDK Installation [installation] -->
## SDK Installation

### Getting started

iOS 16.0+ is required.

The samples below show how the published SDK artifact is used:

### Minimum Requirements

- **iOS 16.0+**
- **Swift 5.7+**

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/gr4vy/gr4vy-swift.git", from: "1.0.0-beta.1")
]
```

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'gr4vy-swift', '~> 1.0.0-beta.1'
```

Then run:

```bash
pod install
```
<!-- End SDK Installation [installation] -->

## SDK Example Usage

### Example

```swift
import gr4vy_swift

do {
    let gr4vy = try Gr4vy(
        gr4vyId: "example",
        token: "your_jwt_token", // Optional
        merchantId: "merchant_123", // Optional
        server: .sandbox,
        debugMode: true // Optional
    )
    
    // Create payment options request
    let request = Gr4vyPaymentOptionRequest(
        merchantId: "merchant_123",
        metadata: ["order_id": "12345"],
        country: "US",
        currency: "USD",
        amount: 1299,
        locale: "en-US",
        cartItems: nil
    )
    
    // Get payment options using async/await
    let paymentOptions = try await gr4vy.paymentOptions.list(request: request)
    print("Available payment options: \(paymentOptions.count)")
    
} catch {
    print("Error: \(error)")
}
```

## Merchant account ID selection

Depending on the API used, you might need to explicitly define a merchant account ID to use. When using the SDK, you can set the `merchantId`
at the SDK level, or, on some requests directly.

```swift
let request = Gr4vyPaymentOptionRequest(
    merchantId: "merchant_123",
    metadata: ["order_id": "12345"],
    country: "US",
    currency: "USD",
    amount: 1299,
    locale: "en-US",
    cartItems: nil
)
```

Alternatively, the merchant account ID can also be set when initializing the SDK.

```swift
let gr4vy = try Gr4vy(
    gr4vyId: "example",
    token: "your_jwt_token",
    merchantId: "merchant_123", // Set the default merchant ID
    server: .sandbox,
    debugMode: true
)
```

## Timeout Configuration

The SDK supports configuring request timeouts both at the SDK level (for all requests) and per individual request. This allows you to control how long the SDK will wait for API responses before timing out.

### SDK-Level Timeout

You can set a default timeout for all requests when initializing the SDK. This timeout will be used for all API calls unless overridden at the request level.

```swift
let gr4vy = try Gr4vy(
    gr4vyId: "example",
    token: "your_jwt_token",
    merchantId: "merchant_123",
    server: .sandbox,
    timeout: 45.0, // Set default timeout to 45 seconds
    debugMode: true
)
```

### Per-Request Timeout

You can override the SDK-level timeout for individual requests by specifying the `timeout` parameter in request objects:

```swift
// Payment Options with custom timeout
let paymentOptionsRequest = Gr4vyPaymentOptionRequest(
    merchantId: "merchant_123",
    metadata: ["order_id": "12345"],
    country: "US",
    currency: "USD",
    amount: 1299,
    locale: "en-US",
    cartItems: nil,
    timeout: 60.0 // Override to 60 seconds for this request
)

// Card Details with custom timeout
let cardDetailsRequest = Gr4vyCardDetailsRequest(
    cardDetails: cardDetails,
    timeout: 20.0 // Override to 20 seconds for this request
)

// Buyers Payment Methods with custom timeout
let buyersRequest = Gr4vyBuyersPaymentMethodsRequest(
    paymentMethods: paymentMethods,
    merchantId: "merchant_123",
    timeout: 30.0 // Override to 30 seconds for this request
)
```

### Default Timeout Values

- **SDK Default**: 30 seconds (if not specified during initialization)
- **Request Override**: Uses SDK default if not specified per request

> **Note**: Timeout values are specified in seconds as `TimeInterval` (Double). 

<!-- No SDK Example Usage [usage] -->

### Usage Examples

#### Payment Options Service

```swift
// Create request
let request = Gr4vyPaymentOptionRequest(
    merchantId: "merchant_123", // Optional, uses SDK merchantId if not provided
    metadata: ["order_id": "12345"],
    country: "US",
    currency: "USD",
    amount: 1299,
    locale: "en-US",
    cartItems: nil
)

// Async/await
do {
    let paymentOptions = try await gr4vy.paymentOptions.list(request: request)
    print("Available payment options: \(paymentOptions.count)")
} catch {
    print("Error fetching payment options: \(error)")
}

// Completion handler
gr4vy.paymentOptions.list(request: request) { result in
    switch result {
    case .success(let paymentOptions):
        print("Available payment options: \(paymentOptions.count)")
    case .failure(let error):
        print("Error fetching payment options: \(error)")
    }
}
```

#### Card Details Service

```swift
// Create card details object
let cardDetails = Gr4vyCardDetails(
    currency: "USD",
    amount: "1299",
    bin: "411111",
    country: "US",
    intent: "capture"
)

// Create request
let request = Gr4vyCardDetailsRequest(
    cardDetails: cardDetails,
    timeout: 30.0
)

// Async/await
do {
    let cardDetailsResponse = try await gr4vy.cardDetails.get(request: request)
    print("Card brand: \(cardDetailsResponse.scheme)")
    print("Card type: \(cardDetailsResponse.cardType)")
} catch {
    print("Error fetching card details: \(error)")
}

// Completion handler
gr4vy.cardDetails.get(request: request) { result in
    switch result {
    case .success(let cardDetailsResponse):
        print("Card brand: \(cardDetailsResponse.scheme)")
        print("Card type: \(cardDetailsResponse.cardType)")
    case .failure(let error):
        print("Error fetching card details: \(error)")
    }
}
```

#### Buyers Payment Methods Service

```swift
// Create payment methods criteria
let paymentMethods = Gr4vyBuyersPaymentMethods(
    buyerId: "buyer_123",
    buyerExternalIdentifier: "external_456",
    sortBy: .lastUsedAt,
    orderBy: .desc,
    country: "US",
    currency: "USD"
)

// Create request
let request = Gr4vyBuyersPaymentMethodsRequest(
    paymentMethods: paymentMethods,
    merchantId: "merchant_123", // Optional
    timeout: 30.0
)

// Async/await
do {
    let paymentMethodsList = try await gr4vy.paymentMethods.list(request: request)
    print("Found \(paymentMethodsList.count) payment methods")
} catch {
    print("Error fetching payment methods: \(error)")
}

// Completion handler
gr4vy.paymentMethods.list(request: request) { result in
    switch result {
    case .success(let paymentMethodsList):
        print("Found \(paymentMethodsList.count) payment methods")
    case .failure(let error):
        print("Error fetching payment methods: \(error)")
    }
}
```

#### Checkout Session Service

```swift
// Create card data
let cardData = Gr4vyCardData(
    paymentMethod: .card(CardPaymentMethod(
        number: "4111111111111111",
        expirationDate: "12/25",
        securityCode: "123"
    ))
)

// Tokenize payment method
do {
    try await gr4vy.tokenize(
        checkoutSessionId: "session_123",
        cardData: cardData
    )
    print("Payment method tokenized successfully")
} catch {
    print("Error tokenizing payment method: \(error)")
}

// Completion handler
gr4vy.tokenize(
    checkoutSessionId: "session_123",
    cardData: cardData
) { result in
    switch result {
    case .success:
        print("Payment method tokenized successfully")
    case .failure(let error):
        print("Error tokenizing payment method: \(error)")
    }
}
```
<!-- End Available Services and Operations [operations] -->

<!-- Start Error Handling [errors] -->
## Error Handling

By default, an API error will throw a `Gr4vyError` exception. The SDK provides error handling with specific error types. They are:

| Error Type                | Description              |
| ------------------------- | ------------------------ |
| `invalidGr4vyId`         | Invalid Gr4vy ID provided |
| `badURL`                 | Invalid URL construction |
| `httpError`              | HTTP request failed      |
| `networkError`           | Network connectivity issues |
| `decodingError`          | JSON decoding failed     |

### Example

```swift
import gr4vy_swift

do {
    let paymentOptions = try await gr4vy.paymentOptions.list(request: request)
    // Handle success
} catch let error as Gr4vyError {
    switch error {
    case .invalidGr4vyId:
        print("Invalid Gr4vy ID provided")
    case .badURL(let url):
        print("Invalid URL: \(url)")
    case .httpError(let statusCode, _, let message):
        print("HTTP \(statusCode): \(message ?? "Unknown error")")
    case .networkError(let urlError):
        print("Network error: \(urlError.localizedDescription)")
    case .decodingError(let message):
        print("Decoding error: \(message)")
    }
} catch {
    print("Unexpected error: \(error)")
}
```
<!-- End Error Handling [errors] -->

<!-- Start Server Selection [server] -->
## Server Selection

### Select Server by Name

You can override the default server globally using the `server` parameter when initializing the SDK client instance. The selected server will then be used as the default for API calls to Gr4vy. Available configurations:

| Name         | Server                               | Description |
| ------------ | ------------------------------------ | ----------- |
| `sandbox`    | `https://api.sandbox.{id}.gr4vy.app` | Sandbox environment |
| `production` | `https://api.{id}.gr4vy.app`         | Production environment |

#### Example

```swift
import gr4vy_swift

let gr4vy = try Gr4vy(
    gr4vyId: "example",
    token: "your_jwt_token",
    merchantId: "default",
    server: .production, // Use production environment
    debugMode: false
)
```
<!-- End Server Selection [server] -->

<!-- Start Debugging [debug] -->
## Debugging

### Debug Mode

You can setup your SDK to emit debug logs for SDK requests and responses.

For request and response logging, enable `debugMode` when initializing the SDK:

```swift
let gr4vy = try Gr4vy(
    gr4vyId: "example",
    token: "your_jwt_token",
    merchantId: "default",
    server: .sandbox,
    debugMode: true // Enable debug logging
)
```

You can also manually control logging:

```swift
// Manually control logging
Gr4vyLogger.enable()  // Enable logging
Gr4vyLogger.disable() // Disable logging
```

Example output:
```
[Gr4vy SDK] Network request: GET https://api.sandbox.example.gr4vy.app/payment-options
[Gr4vy SDK] Response: 200 OK
[Gr4vy SDK] Response time: 245ms
```

**WARNING**: This should only be used for temporary debugging purposes. Leaving this option on in a production system could expose credentials/secrets in logs. Authorization headers are automatically redacted.
<!-- End Debugging [debug] -->

## Support

- **Documentation**: [https://docs.gr4vy.com](https://docs.gr4vy.com)
- **Issues**: [GitHub Issues](https://github.com/gr4vy/gr4vy-swift/issues)
- **Email**: mobile@gr4vy.com

## License

This project is provided as-is under the [LICENSE](LICENSE).
