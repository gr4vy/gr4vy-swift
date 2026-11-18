---
status: accepted
date: 2026-11-18
---

# The merge gate approves SDK feature code, and a person reviews the trust boundaries

Gr4vy's merge gate approves a pull request on its own when its author is listed in `.github/merge-gate-authors.txt`, CI is green, and Copilot has reviewed the latest push with every comment answered. It never approves a change under `.github/`, and `.github/merge-gate-protected.txt` adds paths a person must always review. This repo protects the files that decide:

- what merchants' apps pull in: `Package.swift`, `Package.resolved`, the Xcode project, and the Renovate config;
- what CI checks: the test plan and the SwiftLint configs;
- where requests and the bearer token go: `Gr4vyUtility.swift` builds the API host and `Gr4vySetup.swift` chooses sandbox or production;
- what reaches merchants' logs: `Gr4vyHTTPClient.swift` logs requests and `Gr4vyLogger.swift` masks card data;
- which 3DS directory-server certificates sandbox trusts: the `acq-` certificates and their loader;
- the version script and the QA scripts, which developers run with live sandbox tokens.

Everything else, including the models, requests, services, the 3DS flow and the tests, is left to the gate.

## Considered options

- **Protect every file that handles card data, and the 3DS service.** Rejected. Those are the files most feature PRs change (4 of the 10 commits that changed SDK code in 2026 touched the checkout session service, its request, the card model or the 3DS service), so nearly every PR would need a person again. Any Swift file could open its own connection, so protecting them wouldn't close that gap either. Protecting the files that pick the host and send the request covers the redirect.
- **A person approves every PR.** Rejected: it's the friction the gate removes, and it led to admin merges.
- **Protect `VERSION` and `Version.swift`.** Rejected: a version bump releases nothing until someone runs the Release workflow and someone else approves it ([ADR 0011](0011-releases-from-a-manual-workflow.md)).

## Consequences

- A listed author can change card-data models, request shapes and the 3DS flow with only Copilot's review and CI. Copilot's comments must all be answered, so its review is the check on that code.
- The list is read from `main` and only adds paths. Changing it is under `.github/`, so it always needs a person.
- When a new file starts deciding the host, the token, logging or certificate trust, add it to the list in the same PR.
