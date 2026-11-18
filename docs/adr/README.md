# Architecture decision records

Decisions that are hard to reverse, would surprise a new reader, and came out of a real trade-off. Numbers are in the order they were written down. The table is in the order the decisions were made. A few decisions about vendor licensing are kept in Gr4vy's internal docs instead of here.

| Decided | ADR |
| --- | --- |
| 2025-06-06 | [0004](0004-separate-ui-less-native-sdk.md): A new UI-less Swift SDK sits alongside gr4vy-ios instead of extending it |
| 2025-07-17 | [0005](0005-embed-token-and-checkout-session-auth.md): The SDK authenticates with an Embed token or a checkout session ID, never with merchant credentials |
| 2025-10-10 | [0006](0006-3ds-inside-tokenize-after-storing-card.md): 3DS runs inside `tokenize`, after the card is stored on the checkout session |
| 2025-10-10 | [0007](0007-netcetera-hidden-behind-gr4vy-types.md): Netcetera's 3DS SDK stays behind Gr4vy-owned public types |
| 2025-10-28 | [0008](0008-3ds-outcomes-are-results-not-errors.md): 3DS outcomes come back as a result, not as errors |
| 2026-08-11 | [0009](0009-netcetera-pinned-exact-everywhere.md): Netcetera's 3DS SDK is pinned to one exact version, from its official SPM repo, in every manifest |
| 2026-09-07 | [0010](0010-spm-only-distribution.md): The SDK ships through Swift Package Manager only |
| 2026-10-08 | [0001](0001-preferred-scheme-per-call-unvalidated.md): Preferred scheme is a per-call `tokenize` argument, and the SDK doesn't validate it |
| 2026-10-08 | [0002](0002-preferred-scheme-query-key.md): The preferred scheme is sent as the `preferredScheme` query key |
| 2026-10-19 | [0003](0003-swiftlint-gates-on-errors-only.md): SwiftLint gates CI on errors only |
| 2026-11-18 | [0011](0011-releases-from-a-manual-workflow.md): Releases run from a manual workflow, and only its approved job creates tags |
| 2026-11-18 | [0012](0012-merge-gate-leaves-trust-boundaries-to-a-person.md): The merge gate approves SDK feature code, and a person reviews the trust boundaries |

New ADRs: next free number, `status` and `date` frontmatter, and the format in the existing files. No customer names or internal links: this repo is public.
