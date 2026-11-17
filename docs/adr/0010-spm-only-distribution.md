---
status: accepted
date: 2026-09-07
---

# The SDK ships through Swift Package Manager only

1.0.0-beta.1 was published to both CocoaPods and SPM on 2025-07-21. The next day we stopped adding CocoaPods to anything new. The SDK developer noted that CocoaPods was being phased out, with SPM the approach Apple recommends (internal discussion, 2025-07-22), and the launch merchant was told so (2025-07-25). The podspec stayed in the repo, still pinned to Netcetera 2.5.30, until review of [#13](https://github.com/gr4vy/gr4vy-swift/pull/13) found it contradicted the 2.7 code. `ThreeDS_SDK` was never on the CocoaPods trunk, and the trunk was going read-only. So the podspec was deleted ("Cocoapods is now dead", internal discussion, 2026-09-07).

A release is just a git tag. SPM reads tags straight from GitHub, so a deleted or moved tag changes package resolution for everyone at once (RELEASE.md).

## Consequences

- Apps that still use CocoaPods have to add this SDK through SPM. The `gr4vy-swift` pod stays frozen at its last trunk version, which has the old Netcetera pin, and must not be advertised.
- Don't bring the podspec back. Netcetera doesn't publish `ThreeDS_SDK` to the trunk, so a pod can't declare its 3DS dependency.
- This doesn't apply to gr4vy-ios, which still has its own CocoaPods history (internal discussion, 2026-11-02).
