---
status: accepted
date: 2025-07-17
---

# The SDK authenticates with an Embed token or a checkout session ID, never with merchant credentials

The app runs on the cardholder's device, so it can't hold the merchant's Gr4vy private key. The product brief splits authentication along the same line Embed and Secure Fields use:

- The lookups (payment options, card details, a buyer's payment methods) send an Embed token. This is a short-lived JWT that the merchant's server signs, scoped to `embed` and the checkout amount.
- Tokenize, and the 3DS calls that follow it, use the checkout session ID as their only credential.

So the token is optional in the initialiser and can be swapped with `updateToken(_:)`. That change and the SDK-level merchant account ID landed on 2025-07-17 (status update). A tokenize-only integration needs no token at all ("I've not needed the token for tokenize work", internal discussion, 2025-11-11).

## Consequences

- Anyone who holds the checkout session ID can write card data to that session until it expires. The merchant's server creates sessions per checkout and must not reuse them.
- An Embed token is scoped to one amount and currency. An app that changes the basket has to get a new token from its server and call `updateToken(_:)`. Don't make the token live longer to avoid this.
- Logs mask `Authorization` headers and `"token"` fields (`Gr4vyLogger`), and SwiftLint treats logging sensitive-looking names as an error ([ADR 0003](0003-swiftlint-gates-on-errors-only.md)).
