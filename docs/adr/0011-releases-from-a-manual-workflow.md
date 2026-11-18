---
status: accepted
date: 2026-11-18
---

# Releases run from a manual workflow, and only its approved job creates tags

Swift Package Manager resolves this SDK straight from git tags, so whoever can create a tag can publish a release ([ADR 0010](0010-spm-only-distribution.md)). Until now any account with write access could push one, and pushing it was the release. A release now starts from a manually triggered workflow on `main`. A first job, with no secrets, checks the version and CI and lists what ships. Once someone other than the person who started it approves the run in the `release` environment, the job swaps its GitHub Actions identity for a short-lived token through Octo STS, and creates the tag and the immutable GitHub release.

The version stays in the repo (`VERSION`, `Version.swift`), bumped in an ordinary PR. Package Manager builds from the tagged source and the SDK reports its own version, so the version can't be worked out at release time.

## Considered options

- **Keep tag pushes.** Rejected: any write account, or a stolen token, could publish.
- **A release PR, such as release-please or changesets.** Rejected: an extra PR per release, and it needs a bot that writes to `main`.
- **Releasing unattended when every change came from a bot,** like Gr4vy's generated server SDKs. Rejected: every change here is written by hand, so a person has to decide each release.
- **A GitHub App whose key sits in the `release` environment.** Rejected: a long-lived key to rotate and guard, where Octo STS needs none. Reusing the server SDKs' release App would also have shared its key with every server SDK repo.

## Consequences

- No key is stored anywhere. The org's Octo STS policy only issues a `contents: write` token on this repo to `release.yml` on `main`, in the `release` environment. Changing who can release means changing that policy, in the org's `.github` repo.
- We rely on Octo STS, a hosted service, and its App can do a lot on every repo it's installed on. The tag ruleset lets that App through, so any Octo STS policy granting `contents: write` here could create tags. Keep it to this one.
- A bad release is fixed forward with a new version. Tags can't be moved or deleted.
- The approval is only as good as the approver's reading of the run's summary, which lists each PR since the last release and who approved it.
