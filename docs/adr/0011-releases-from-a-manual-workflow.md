---
status: accepted
date: 2026-11-18
---

# Releases start after a version bump and wait for approval, and only the approved job creates tags

Swift Package Manager resolves this SDK straight from git tags, so whoever can create a tag can publish a release ([ADR 0010](0010-spm-only-distribution.md)). Until now any account with write access could push one, and pushing it was the release. A release now starts by itself when CI passes on `main` for a commit whose `VERSION` isn't released yet, or by hand on `main`. A first job, with no secrets, checks the version and CI and lists what ships, and Slack says it's waiting for approval. Once a release approver approves the run in the `release` environment, the job swaps its GitHub Actions identity for a short-lived token through Octo STS, and creates the tag and the immutable GitHub release.

The version stays in the repo (`VERSION`, `Version.swift`), bumped in an ordinary PR. Package Manager builds from the tagged source and the SDK reports its own version, so the version can't be worked out at release time.

## Considered options

- **Keep tag pushes.** Rejected: any write account, or a stolen token, could publish.
- **A release PR, such as release-please or changesets.** Rejected: an extra PR per release, and it needs a bot that writes to `main`.
- **Releasing unattended when every change came from a bot,** like Gr4vy's generated server SDKs. Rejected: every change here is written by hand, so a person has to decide each release.
- **Starting the Release workflow only by hand.** Tried first, on 2026-11-18. Rejected the same day: merging a bump and then pressing a button was easy to get wrong, and the first manual run started before CI had finished on `main` and failed its CI check. Starting after CI passes releases the commit CI tested, and the approval still decides.
- **A GitHub App whose key sits in the `release` environment.** Rejected: a long-lived key to rotate and guard, where Octo STS needs none. Reusing the server SDKs' release App would also have shared its key with every server SDK repo.

## Consequences

- No key is stored anywhere. The org's Octo STS policy only issues a `contents: write` token on this repo to `release.yml` on `main`, in the `release` environment. Changing who can release means changing that policy, in the org's `.github` repo.
- We rely on Octo STS, a hosted service, and its App can do a lot on every repo it's installed on. The tag ruleset lets that App through, so any Octo STS policy granting `contents: write` here could create tags. Keep it to this one.
- A bad release is fixed forward with a new version. Tags can't be moved or deleted.
- Release approvers are a short list in the `release` environment, as in the server SDKs, and may approve releases their own merges started. So one approver can release alone; the checks on that are the merge gate and Copilot on every PR, and the run's summary.
- The approval is only as good as the approver's reading of the run's summary, which lists each PR since the last release and who approved it.
