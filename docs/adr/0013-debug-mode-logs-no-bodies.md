---
status: accepted
date: 2026-11-27
---

# Debug mode logs no request or response bodies

With `debugMode` on, the SDK logs each request's method and URL, the response status and time, and the 3DS steps. For an error response it logs only the fields of Gr4vy's error envelope that say what went wrong: `code`, `message`, and each detail's `location`, `pointer` and `message`. It doesn't log request or response bodies.

Merchants turn debug mode on in their own apps, and its output ends up in their logs and crash tools. Before this, the SDK printed every body and masked what a list of patterns recognised: card numbers without spaces, security codes, `token` and `Bearer` values. A QA run found the 3DS authenticate request's `sdk_encrypted_data` and the response's `acs_signed_content` printed in full, and a card number with spaces got past the card number pattern. A pattern list only covers the fields someone thought of. Any new field leaks until a pattern is added.

## Considered options

- **Keep logging bodies and add patterns for the 3DS fields.** Rejected: it fixes these two fields and leaves the next one to leak.
- **Mask bodies by key, with a list of fields that are safe to print.** Rejected for now: every response shape needs its own list, and the lists drift as the API changes. The request line, status and error summary answer most debugging questions.
- **Log nothing in debug mode.** Rejected: the request line, status and error summary are what QA and merchants use to see which call failed and why.

## Consequences

- You can't see a response's fields in the log. Read them from the result the SDK returns, or from the request in a proxy you control.
- The masking patterns in `Gr4vyLogger` stay as a backstop for the lines that are still logged. They aren't what keeps card data out.
- URLs are still logged, including query values such as `preferredScheme`.
- An error body that isn't JSON, such as a proxy's HTML page, still becomes the error's message, and the failed request's log line includes it. Changing that changes the error the SDK returns, so it's left for a separate change.
- `debugMode` also sets the 3DS SDK's own log level to debug. This decision covers the SDK's own log lines, not the 3DS SDK's.
- A new log line that prints a payload needs the same care. `Gr4vyHTTPClient.swift` and `Gr4vyLogger.swift` are on the merge gate's protected list ([ADR 0012](0012-merge-gate-leaves-trust-boundaries-to-a-person.md)), so a person reviews it.
