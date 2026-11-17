---
status: accepted
date: 2025-10-28
---

# 3DS outcomes come back as a result, not as errors

A 3DS `tokenize` can end with an authenticated card, a declined card (`N`), a cancelled challenge, a timed-out challenge, or no 3DS at all. All of these are normal results, and the merchant decides what to do with each. On the 2025-10-27 QA call, and in the thread that followed on 2025-10-28 (internal discussion), we agreed that cancellation, timeout and a negative response are returned as a successful `Gr4vyTokenizeResult` and not thrown. `hasCancelled` and `hasTimedOut` were added for the first two. `attempted` is true once the versioning call has succeeded, so a cancelled or timed-out challenge still counts as attempted.

Errors are thrown only when the SDK or the protocol breaks: the fields call fails, the 3DS SDK fails to start, the server returns an indicator we don't recognise, or the 3DS SDK reports a protocol or runtime error. On 2025-11-14 the SDK developer proposed folding protocol and runtime errors into the result as well. We did not adopt that, and they are still thrown as `Gr4vyError.threeDSError`.

## Consequences

- If the versioning call fails, for whatever reason, the result is `attempted: false` and no error is thrown. That covers a network error, a 204 (no 3DS configuration for the scheme), and a response the SDK can't decode. A merchant hit the decoding case (2026-01-15), and the 204 is now handled explicitly ([#16](https://github.com/gr4vy/gr4vy-swift/pull/16)). The merchant has to read `attempted` to find out that 3DS was skipped. See also [ADR 0001](0001-preferred-scheme-per-call-unvalidated.md).
- A thrown 3DS error does not mean the card wasn't stored. By then it is already on the session (see [3DS inside tokenize](0006-3ds-inside-tokenize-after-storing-card.md)).
- The result has no ECI. Netcetera's completion event exposes only the transaction status, so the server works out the ECI when the transaction is created ("drop the eci and we will tell merchants they can get it from the API", 2025-10-28). A vendor support ticket about getting the ECI on the device was still open in November 2026.
- The same result shape is shared with gr4vy-kotlin and Secure Fields 3DS (internal discussion, 2026-01-15). Changing it here breaks parity with them.
