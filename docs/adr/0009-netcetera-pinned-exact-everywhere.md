---
status: accepted
date: 2026-08-11
---

# Netcetera's 3DS SDK is pinned to one exact version, from its official SPM repo, in every manifest

`ThreeDS_SDK` is a binary target, fetched from Netcetera's artifact host when packages are resolved. In 2026 CI was red for two months without anyone noticing ([#10](https://github.com/gr4vy/gr4vy-swift/pull/10), 2026-08-11), for two reasons:

- The Xcode project declared its own requirement (`upToNextMajorVersion` from 2.5.30) and had its own `Package.resolved`, both pinned to a revision whose host Netcetera had retired.
- A Renovate bump to `Package.swift` ([#2](https://github.com/gr4vy/gr4vy-swift/pull/2)) had gone green while changing nothing that `xcodebuild` used.

#10 made all four places agree on one exact version: `Package.swift`, the project's package requirement, and both `Package.resolved` files. [#13](https://github.com/gr4vy/gr4vy-swift/pull/13) (2026-09-08) then moved the source from `ios-3ds-sdk/SPM` to `netceteragroup/ios-3ds-sdk-spm`. The vendor confirmed that the old repo was abandoned in January 2026 ([#11](https://github.com/gr4vy/gr4vy-swift/pull/11) had been chasing its last tag, 2.6.00).

## Considered options

- **A version range.** Rejected. This is a certified payments component, and its releases have removed public API without notes (#11 found seven members removed between 2.5.32 and 2.6.00).
- **Vendoring the xcframework** (as gr4vy-kotlin does with jars). Rejected for now: it adds about 10 MB to the repo and a manual refresh step. Revisit if Netcetera's Nexus host proves unreliable (#10).

## Consequences

- Any bump has to change all four files together. A Renovate PR that touches only `Package.swift` isn't enough.
- The unit tests mock the 3DS SDK, so a bump needs a live sandbox challenge, including the cancel and timeout branches, before it merges. #13 was merged after that run.
- Netcetera tags versions like `2.7.01`, while its release notes say `2.7.0.1`. Xcode's package UI rejects the non-semver form (vendor request, November 2026), so use the tag exactly as Netcetera publishes it.
