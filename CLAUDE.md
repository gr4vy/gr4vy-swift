# gr4vy-swift

Gr4vy's iOS SDK: card tokenization and native 3DS (Netcetera) for merchant apps. Distributed through Swift Package Manager by git tag.

- **Vocabulary:** use the terms in [GLOSSARY.md](GLOSSARY.md). Say "preferred scheme", not "selected scheme", and "primary scheme", not "main scheme".
- **Decisions:** read [docs/adr/](docs/adr/) before changing request shapes, 3DS behaviour or CI lint rules. Add an ADR when a change is hard to reverse, surprising and the result of a real trade-off.
- **QA:** follow [docs/QA.md](docs/QA.md) for any change to requests, 3DS or the public API. Probe the server with `scripts/qa/probe-versioning.sh` before trusting a green simulator run. Write each run up in `docs/qa-runs/`.
- **Contract:** query keys on Core API's checkout session endpoints are camelCase (`deviceChannel`, `preferredScheme`). Scheme values are Gr4vy ids such as `carte-bancaire`, not brand names.
- **Checks:** `swiftlint lint` (errors fail CI) and `xcodebuild test -scheme gr4vy-swiftTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
- **Merge gate:** PRs from authors in `.github/merge-gate-authors.txt` are approved by the merge gate once CI is green and Copilot's comments are answered. Changes under `.github/` or to a path in `.github/merge-gate-protected.txt` need a person ([ADR 0012](docs/adr/0012-merge-gate-leaves-trust-boundaries-to-a-person.md)). When a file starts deciding the API host, the token, logging or 3DS trust, add it to that list.
- **Releases:** see [RELEASE.md](RELEASE.md). Bump with `./update_version.sh` in a PR, merge, then run the Release workflow. Never push tags: only the Release workflow can create them.
