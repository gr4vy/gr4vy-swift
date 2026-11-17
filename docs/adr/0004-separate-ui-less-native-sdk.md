---
status: accepted
date: 2025-06-06
---

# A new UI-less Swift SDK sits alongside gr4vy-ios instead of extending it

Gr4vy's existing mobile SDKs (gr4vy-ios, gr4vy-android, and gr4vy-react-native on top of them) are thin wrappers that show Embed in a web view. Merchants wanted their own native card form instead: Several merchants asked for one in 2024 ([FEAT-390](https://gr4vy.atlassian.net/browse/FEAT-390), internal discussion, 2024-07-08), and a merchant's go-live in 2025 made it urgent. The Native Mobile SDK product brief answered "extend the current mobile SDK or add a new SDK?" with "New SDK". Phase 1 is API helpers only: list payment options, look up card details, list a buyer's stored payment methods, and tokenize into a checkout session. Gr4vy ships no UI, and the merchant's server, not the app, creates the transaction. The brief's requirements were finalised for an external development partner on 2025-06-06, and work started on 2025-06-16 (FEAT-390 comment).

The repo is named after the language (`gr4vy-swift`, with `gr4vy-kotlin` as its sibling) because the `gr4vy-ios` and `gr4vy-android` names were taken and weren't going to be renamed (internal discussion, 2025-07-11).

## Considered options

- **Extend gr4vy-ios.** Rejected. A web view wrapper and a set of API helpers share almost no code, and merchants on Embed would have been dragged through a breaking change.
- **Ship native UI components first** (a native card form, as Secure Fields is on the web). Deferred to a later phase. It is the bigger build, and the launch merchant wanted to build its own UI (launch post, 2025-08-01).

## Consequences

- The merchant's app handles raw card data, so the SDK does nothing to reduce the merchant's PCI scope. The brief and the launch post tell merchants to review their PCI SAQ scope with their assessor.
- gr4vy-ios is not deprecated. It is still the Embed wrapper on its own version line (2.x), so there are two Gr4vy iOS SDKs. To keep them apart in analytics, this SDK's User-Agent was renamed from `Gr4vy-iOS-SDK` to `Gr4vy-Swift` in [#9](https://github.com/gr4vy/gr4vy-swift/pull/9) (2026-08-11, release 1.0.2), matching `Gr4vy-Kotlin`. Analytics keyed on the old name stop at that release.
- Client-side payment is out of scope. A tokenize returns no payment token, so the merchant's server must create the transaction from the checkout session ID. A merchant asked how to get the card back to their server (2026-01-12).
