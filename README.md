# Gr4vy Swift SDK

Developer-friendly & type-safe Swift SDK specifically catered to leverage *Gr4vy* API.

<div align="left">
    <img alt="Swift" src="https://img.shields.io/badge/Swift-5.7_5.8_5.9-orange?style=for-the-badge">
    <img alt="Platforms" src="https://img.shields.io/badge/Platforms-iOS-yellowgreen?style=for-the-badge">
    <img alt="CocoaPods Compatible" src="https://img.shields.io/cocoapods/v/gr4vy-swift.svg?style=for-the-badge">
    <img alt="Build Status" src="https://img.shields.io/github/actions/workflow/status/gr4vy/gr4vy-swift/ios.yml?branch=main&style=for-the-badge">
</div>

## Summary <!-- omit from toc -->

The official Gr4vy SDK for Swift provides a convenient way to interact with the Gr4vy API from your iOS application. This SDK allows you to seamlessly integrate Gr4vy's powerful payment orchestration capabilities.

This SDK is designed to simplify development, reduce boilerplate code, and help you get up and running with Gr4vy quickly and efficiently. It handles authentication, request management, and provides easy-to-use async/await methods for all API endpoints.

A [SwiftUI client app](https://github.com/gr4vy/gr4vy-swift-client-app) and [UIKit client app](https://github.com/gr4vy/gr4vy-uikit-client-app) that uses this SDK are available for demo and testing purposes.

- [SDK Installation](#sdk-installation)
  - [Getting started](#getting-started)
  - [Minimum Requirements](#minimum-requirements)
  - [Swift Package Manager](#swift-package-manager)
  - [CocoaPods](#cocoapods)
- [SDK Example Usage](#sdk-example-usage)
  - [Example](#example)
- [Merchant account ID selection](#merchant-account-id-selection)
- [Timeout Configuration](#timeout-configuration)
  - [SDK-Level Timeout](#sdk-level-timeout)
  - [Per-Request Timeout](#per-request-timeout)
  - [Default Timeout Values](#default-timeout-values)
- [Available Operations](#available-operations)
  - [Vault card details](#vault-card-details)
  - [Vault card details with 3D Secure authentication](#vault-card-details-with-3d-secure-authentication)
  - [List available payment options](#list-available-payment-options)
  - [Get card details](#get-card-details)
  - [List buyer's payment methods](#list-buyers-payment-methods)
- [3D Secure Authentication](#3d-secure-authentication)
  - [Overview](#overview)
  - [Customizing the 3DS UI](#customizing-the-3ds-ui)
- [Error Handling](#error-handling)
  - [Example](#example-1)
- [Server Selection](#server-selection)
  - [Select Server by Name](#select-server-by-name)
- [Debugging](#debugging)
  - [Debug Mode](#debug-mode)
- [Support](#support)
- [License](#license)


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
    .package(url: "https://github.com/gr4vy/gr4vy-swift.git", from: "1.0.1")
]
```

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'gr4vy-swift', '~> 1.0.1'
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

## Available Operations

### Vault card details

Stores the card details you collected into a Gr4vy checkout session without 3D Secure authentication.

```swift
// Create card data
let cardData = Gr4vyCardData(
    paymentMethod: .card(CardPaymentMethod(
        number: "4111111111111111",
        expirationDate: "12/25",
        securityCode: "123"
    ))
)

// Tokenize card data into checkout session
do {
    try await gr4vy.tokenize(
        checkoutSessionId: "session_123",
        cardData: cardData
    )
    print("Payment method tokenization complete")
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
        print("Payment method tokenization complete")
    case .failure(let error):
        print("Error tokenizing payment method: \(error)")
    }
}
```

#### Using stored payment methods

You can also tokenize an already-stored payment method by passing an `id` payment method to the same `tokenize` call. Include a `securityCode` only when required by the merchant or card scheme.

```swift
// Use a stored payment method ID (optionally include CVV)
let storedCardData = Gr4vyCardData(
    paymentMethod: .id(IdPaymentMethod(
        id: "b7e3a2c2-1f4b-4e8a-9c2d-2e7e2b8e9c2d", // stored payment method id (UUID)
        securityCode: "123" // optional
    ))
)

// Tokenize stored payment method (async/await)
do {
    try await gr4vy.tokenize(
        checkoutSessionId: "session_123",
        cardData: storedCardData
    )
    print("Stored payment method tokenization complete")
} catch {
    print("Error tokenizing stored payment method: \(error)")
}

// Completion handler variant
gr4vy.tokenize(
    checkoutSessionId: "session_123",
    cardData: storedCardData
) { result in
    switch result {
    case .success:
        print("Stored payment method tokenization complete")
    case .failure(let error):
        print("Error tokenizing stored payment method: \(error)")
    }
}
```


### Vault card details with 3D Secure authentication

Stores card details with optional 3D Secure authentication. When authentication is enabled, the SDK will automatically handle 3DS Secure flows.

```swift
// Create card data
let cardData = Gr4vyCardData(
    paymentMethod: .card(CardPaymentMethod(
        number: "4111111111111111",
        expirationDate: "12/25",
        securityCode: "123"
    ))
)

// Tokenize with 3DS authentication (async/await)
do {
    let result = try await gr4vy.tokenize(
        checkoutSessionId: "session_123",
        cardData: cardData,
        sdkMaxTimeoutMinutes: 5,
        authenticate: true
    )
    
    if result.tokenized {
        print("Payment method tokenized successfully")
        
        // Check authentication details
        if let auth = result.authentication {
            print("3DS attempted: \(auth.attempted)")
            print("Authentication type: \(auth.type ?? "N/A")")
            print("Transaction status: \(auth.transactionStatus ?? "N/A")")
            
            if auth.hasCancelled {
                print("User cancelled authentication")
            }
            if auth.hasTimedOut {
                print("Authentication timed out")
            }
        }
    }
} catch {
    print("Error tokenizing payment method: \(error)")
}

// With explicit view controller (async/await)
do {
    let result = try await gr4vy.tokenize(
        checkoutSessionId: "session_123",
        cardData: cardData,
        viewController: self, // Explicitly provide the presenting view controller
        sdkMaxTimeoutMinutes: 5,
        authenticate: true
    )
    print("Tokenization complete: \(result.tokenized)")
} catch {
    print("Error: \(error)")
}

// Completion handler variant
gr4vy.tokenize(
    checkoutSessionId: "session_123",
    cardData: cardData,
    sdkMaxTimeoutMinutes: 5,
    authenticate: true
) { result in
    switch result {
    case .success(let tokenizeResult):
        if tokenizeResult.tokenized {
            print("Payment method tokenized successfully")
            if let auth = tokenizeResult.authentication {
                print("Transaction status: \(auth.transactionStatus ?? "N/A")")
            }
        }
    case .failure(let error):
        print("Error tokenizing payment method: \(error)")
    }
}
```

**Parameters:**
- `checkoutSessionId`: The checkout session ID from Gr4vy
- `cardData`: The payment method data to tokenize
- `viewController`: (Optional) The view controller to present the 3DS challenge. If not provided, the SDK will automatically resolve the topmost view controller
- `sdkMaxTimeoutMinutes`: Maximum time for 3DS authentication in minutes (default: 5)
- `authenticate`: This controls if we should attempt to authenticate the card data (default: false)
- `uiCustomization`: (Optional) UI customization for the 3DS challenge screen

**Returns:** `Gr4vyTokenizeResult` containing:
- `tokenized`: Boolean indicating if tokenization was successful
- `authentication`: Optional `Gr4vyAuthentication` object with authentication details

### List available payment options

List the available payment options that can be presented at checkout.

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

### Get card details

Get details about a particular card based on its BIN, the checkout country/currency, and more.

**Note**: Some fields in the response (such as `scheme`, `cardType`, `type`) are optional and may be `nil` if not provided by the API. Always use optional binding or nil coalescing when accessing these fields.

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
    print("Card brand: \(cardDetailsResponse.scheme ?? "unknown")")
    print("Card type: \(cardDetailsResponse.cardType ?? "unknown")")
    print("Card ID: \(cardDetailsResponse.id)")
    
    // Access optional required fields
    if let requiredFields = cardDetailsResponse.requiredFields {
        print("Required fields available")
        if let address = requiredFields.address {
            print("Address fields: city=\(address.city ?? false), postalCode=\(address.postalCode ?? false)")
        }
    }
} catch {
    print("Error fetching card details: \(error)")
}

// Completion handler
gr4vy.cardDetails.get(request: request) { result in
    switch result {
    case .success(let cardDetailsResponse):
        print("Card brand: \(cardDetailsResponse.scheme ?? "unknown")")
        print("Card type: \(cardDetailsResponse.cardType ?? "unknown")")
        print("Card ID: \(cardDetailsResponse.id)")
    case .failure(let error):
        print("Error fetching card details: \(error)")
    }
}
```

### List buyer's payment methods

List all the stored payment methods for a buyer, filtered by the checkout's currency and country.

**Note**: Fields such as `type` and `id` in payment method items are optional and may be `nil`. Always use optional binding when accessing these fields.

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

## 3D Secure Authentication

### Overview

The SDK provides support for 3D Secure (3DS) authentication, and handles flows automatically. 

**Authentication Flows:**

1. **Frictionless Flow**: Authentication completes in the background without user interaction
2. **Challenge Flow**: User is presented with an authentication challenge (e.g., entering an OTP code)

**Transaction Status Codes:**

The authentication result includes a transaction status code that indicates the outcome.

### Customizing the 3DS UI

You can customize the appearance of the 3DS challenge screen to match your app's design. The SDK supports separate customizations for light and dark modes.

**Example: Basic Customization**

```swift
// Create toolbar customization
let toolbar = Gr4vyThreeDSToolbarCustomization(
    textColorHex: "#FFFFFF",
    backgroundColorHex: "#007AFF",
    headerText: "Secure Verification",
    buttonText: "Cancel"
)

// Create button customizations
let submitButton = Gr4vyThreeDSButtonCustomization(
    textFontSize: 16,
    textColorHex: "#FFFFFF",
    backgroundColorHex: "#007AFF",
    cornerRadius: 8
)

let cancelButton = Gr4vyThreeDSButtonCustomization(
    textFontSize: 16,
    textColorHex: "#007AFF",
    backgroundColorHex: "#F0F0F0",
    cornerRadius: 8
)

// Create label customization
let label = Gr4vyThreeDSLabelCustomization(
    textFontSize: 14,
    textColorHex: "#333333",
    headingTextFontSize: 18,
    headingTextColorHex: "#000000"
)

// Create text box customization
let textBox = Gr4vyThreeDSTextBoxCustomization(
    textFontSize: 16,
    textColorHex: "#000000",
    borderWidth: 1,
    borderColorHex: "#CCCCCC",
    cornerRadius: 4
)

// Combine into UI customization
let uiCustomization = Gr4vyThreeDSUiCustomization(
    label: label,
    toolbar: toolbar,
    textBox: textBox,
    buttons: [
        .submit: submitButton,
        .cancel: cancelButton
    ]
)

// Use with tokenization
let result = try await gr4vy.tokenize(
    checkoutSessionId: "session_123",
    cardData: cardData,
    authenticate: true,
    uiCustomization: Gr4vyThreeDSUiCustomizationMap(default: uiCustomization)
)
```

**Example: Light and Dark Mode Support**

```swift
// Light mode customization
let lightCustomization = Gr4vyThreeDSUiCustomization(
    label: Gr4vyThreeDSLabelCustomization(
        textColorHex: "#333333",
        headingTextColorHex: "#000000"
    ),
    toolbar: Gr4vyThreeDSToolbarCustomization(
        textColorHex: "#000000",
        backgroundColorHex: "#F8F8F8"
    ),
    view: Gr4vyThreeDSViewCustomization(
        challengeViewBackgroundColorHex: "#FFFFFF",
        progressViewBackgroundColorHex: "#F0F0F0"
    )
)

// Dark mode customization
let darkCustomization = Gr4vyThreeDSUiCustomization(
    label: Gr4vyThreeDSLabelCustomization(
        textColorHex: "#E0E0E0",
        headingTextColorHex: "#FFFFFF"
    ),
    toolbar: Gr4vyThreeDSToolbarCustomization(
        textColorHex: "#FFFFFF",
        backgroundColorHex: "#1C1C1E"
    ),
    view: Gr4vyThreeDSViewCustomization(
        challengeViewBackgroundColorHex: "#000000",
        progressViewBackgroundColorHex: "#1C1C1E"
    )
)

// Create customization map with both modes
let customizations = Gr4vyThreeDSUiCustomizationMap(
    default: lightCustomization,
    dark: darkCustomization
)

// Use with tokenization
let result = try await gr4vy.tokenize(
    checkoutSessionId: "session_123",
    cardData: cardData,
    authenticate: true,
    uiCustomization: customizations
)
```

**Available Customization Options:**

- **Toolbar**: Header text, button text, colors, and fonts
- **Labels**: Body text and heading styles
- **Buttons**: Individual styling for different button types (submit, cancel, next, etc.)
- **Text Boxes**: Input field styling including borders and corner radius
- **View**: Background colors for the challenge and progress views

All color values should be provided as hexadecimal strings (e.g., `"#007AFF"`).

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
| `threeDSError`           | 3D Secure authentication error |
| `uiContextError`         | UI context resolution error |

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
    case .threeDSError(let message):
        print("3DS authentication error: \(message)")
    case .uiContextError(let message):
        print("UI context error: \(message)")
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
