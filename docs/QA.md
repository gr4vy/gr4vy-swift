# QA

What a release of this SDK has to go through before it's merged and tagged. Unit tests and CI prove the code does what the author meant. QA proves it does what a merchant needs, against a real Gr4vy instance, in a real app.

Run it for every PR that changes request building, 3DS, tokenization, or the public API, and for every release. Write the result up in `docs/qa-runs/` (see [the last run](qa-runs/2026-11-17-1.3.0-preferred-scheme.md) for the shape).

## What makes a good QA run

1. **Probe the server first.** Before you open the simulator, call the endpoint the SDK will call with `scripts/qa/probe-versioning.sh` and write down what the server returns for each input. If you skip this, a green SDK run can hide a contract mismatch. The 1.3.0 run found that the server ignores `preferred_scheme` this way. The SDK tests passed because they mock the server with the SDK's own assumption.
2. **Run the real client app, not a test harness.** Build [gr4vy-swift-client-app](https://github.com/gr4vy/gr4vy-swift-client-app) against the PR branch and drive it in the simulator. The 3DS challenge UI, view controller lookup and Netcetera SDK only show up here.
3. **Check the wire, not just the result screen.** The client app runs with `debugMode: true`. Capture the console and confirm the exact request (path, query, status) for every case. "attempted: true" on screen doesn't tell you which parameter was sent.
4. **Cover every outcome of `tokenize`.** Each run hits all rows of the [standard matrix](#standard-matrix), even when the change looks unrelated to some of them.
5. **Test the new input four ways:** absent, empty, a valid value, and an invalid value. Then test the exact example value from the README and doc comments, copied verbatim.
6. **Keep a baseline.** Run at least one case with the new input absent, so you can tell a regression from a feature bug.
7. **Record evidence.** For each case, keep the checkout session ID, the request and status lines, and the result JSON. Never record tokens, full card numbers outside the published test cards, or the `sdk_encrypted_data` blob.

## Setup

- **Instance.** Spider sandbox (`gr4vy config list` shows the active profile; it should be `spider` / `sandbox`). Merchant account `default`.
- **3DS configuration.** 3DS only runs for scheme and currency pairs that have a configuration. Check before you start, because it can change:
  ```bash
  gr4vy merchant-accounts three-ds-configuration list default
  ```
  On 2026-11-17 it was visa/GBP, mastercard/AUD and amex/USD. A Visa card in EUR therefore returns 204, which makes it the easy way to test the "not set up for 3DS" path.
- **Client app.** Clone `gr4vy/gr4vy-swift-client-app`, point the `gr4vy-swift` package at the PR branch (`branch = "<pr-branch>";` in `project.pbxproj`, then delete `Package.resolved`), and add any new parameter to the Tokenize screen.
- **Settings.** `scripts/qa/ios-seed.sh` creates a fresh checkout session and writes the token, Gr4vy ID, session and card into the app's settings (`simctl defaults`). It then relaunches the app with the console captured to the file you name in `QA_LOG`. It never prints the token.

## Standard matrix

Test cards are the Netcetera ones built into the client app. Expiry `01/30`. Frictionless cards use CVV `123`, challenge cards use `456`. For anything about scheme choice, also use the co-badged sandbox card `4035501000000008`: Visa as the primary scheme, with Cartes Bancaires (`carte-bancaire`) as an additional scheme. Core API's `test_cards.py` lists more, for example Visa with eftpos Australia.

| # | Case | Card / currency | Expect on the wire | Expect in result |
|---|---|---|---|---|
| 1 | Frictionless | Visa frictionless, GBP | `GET …/three-d-secure-version` 200, `POST …/three-d-secure-authenticate` 200 | `attempted: true`, `type: frictionless`, `transaction_status: Y` |
| 2 | Not set up for 3DS | Visa frictionless, EUR | version 204, no authenticate call | `attempted: false`, `tokenized: true`, no error |
| 3 | Challenge, completed | Visa challenge, GBP | version 200, authenticate 200 `CHALLENGE` | challenge UI shown; `type: challenge`, `transaction_status` set |
| 4 | Challenge, cancelled | Visa challenge, GBP, tap Cancel | as 3 | `attempted: true`, `user_cancelled: true` |
| 5 | Authentication off | Visa frictionless, GBP, Authenticate off | `PUT …/fields` only, no version call | `tokenized: true`, no `authentication` attempt |
| 6 | Version call fails | any, with a broken token or session | version 4xx/5xx | `attempted: false`, no crash |
| 7 | Challenge, timed out | Visa challenge, GBP, leave the challenge open past the challenge timeout (at least five minutes) | as 3 | `attempted: true`, `hasTimedOut: true`, no `transaction_status` |

Add feature rows on top of this. For a new request parameter, that means absent, empty, valid, invalid and the documented example, as in principle 5.

## Exit criteria

- Every row has evidence and matches its expectation, on the PR branch.
- What the probe returned matches what the SDK sends. Same parameter name, same value format.
- Any failure is either fixed in the PR, or tracked as a ticket and linked from the PR before merge.
- The run is written up in `docs/qa-runs/` in the same PR or the docs PR.

## Gotchas

- The first tap after a relaunch is often swallowed while the app is still launching. Take a screenshot before you assume a tap landed.
- `Package.resolved` pins `main`. Delete it, or the app builds against the old SDK. The build log names the resolved revision (`gr4vy-swift @ <branch> (<sha>)`), so check it.
- Netcetera's demo ACS returns `N` for the "cities" question unless you pick the right cities. `N` still proves the challenge flow works end to end.
