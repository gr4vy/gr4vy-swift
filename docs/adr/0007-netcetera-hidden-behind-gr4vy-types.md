---
status: accepted
date: 2025-10-10
---

# Netcetera's 3DS SDK stays behind Gr4vy-owned public types

On the 2025-10-10 call we agreed to "drop any mention of Netcetera from the public event/method signatures". The values the SDK returns still follow Netcetera's own events as closely as possible. So merchants pass a `Gr4vyThreeDSUiCustomizationMap` (with `default` and `dark` entries, colours as hex strings), and they get back a `Gr4vyAuthentication`. No `ThreeDS_SDK` type appears in this SDK's public API. `Gr4vyThreeDSUiCustomizationMapper` converts the Gr4vy types to Netcetera's.

This paid off in [#13](https://github.com/gr4vy/gr4vy-swift/pull/13) (1.1.0, 2026-09-08). Netcetera 2.7.0.0 was a breaking release: its methods became async, Objective-C support was removed, and the customisation map's key type changed. None of it reached merchants, so the upgrade shipped as a minor version.

## Consequences

- Every new Netcetera customisation option needs a change and a release here before merchants can use it. 2.7.0.0 added a `MONOCHROME` type that we don't expose yet.
- Netcetera's behaviour changes still reach merchants, because we pass values straight through. In 2.7.01, the dark customisation now applies to the first challenge screen ([#14](https://github.com/gr4vy/gr4vy-swift/pull/14)).
- `ThreeDS_SDK` is still a transitive dependency of the merchant's app, so its iOS minimum and any version conflicts are the merchant's problem too.
