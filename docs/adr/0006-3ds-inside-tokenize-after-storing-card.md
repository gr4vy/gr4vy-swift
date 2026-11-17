---
status: accepted
date: 2025-10-10
---

# 3DS runs inside `tokenize`, after the card is stored on the checkout session

Native 3DS authenticates the card when it is stored ("perform a 3DS at the time of vaulting, instead of at transaction time", FEAT-777), so the merchant's server can create the transaction in one request. The product brief drew it as a separate `authenticate()` step that ran before `tokenize`, with the card number sent to the 3DS endpoints. It left "all-in-one" as an open question.

We chose all-in-one, and told the launch merchant so on 2025-06-27: `tokenize(…, authenticate: true)` does both. On the 2025-10-10 call we reversed the order: `PUT /checkout/sessions/{id}/fields` goes first, then the versioning and authentication calls. The 3DS endpoints then read the card from the session, so on 2025-10-14 they stopped taking the card number and expiry date, and the versioning call became a `GET` (internal discussion). This is what makes 3DS work for a stored payment method, where the app never has the card number.

## Considered options

- **Separate `authenticate()` before `tokenize()`.** Rejected. It sends the card number to 3DS endpoints as well as to the vault, and it can't work for stored payment methods.
- **3DS at transaction time.** Rejected. It needs a browser redirect or a second round-trip to the app, which defeats the point of native 3DS.

## Consequences

- With `authenticate: true`, the card is stored before 3DS starts. A skipped, failed or cancelled authentication, or a thrown 3DS error, still leaves the card on the session (`tokenized: true`). The merchant must check the authentication result before creating the transaction (see [3DS outcomes are results](0008-3ds-outcomes-are-results-not-errors.md)).
- The 3DS amount and currency come from the checkout session, not from `tokenize`. The amount was taken off the signature on 2025-10-10, and authenticating a different amount became its own feature (FEAT-883).
- The 3DS result belongs to the checkout session. The transaction picks it up on the server (FEAT-792), and so does vault forwarding (FEAT-885).
