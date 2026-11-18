# Releasing the Gr4vy Swift SDK

Swift Package Manager installs this SDK straight from git tags, so creating a tag *is* the release. Only the Release workflow creates tags, and only after a person approves it. Why: [ADR 0011](docs/adr/0011-releases-from-a-manual-workflow.md).

## 1. Bump the version in a PR

```bash
./update_version.sh 1.3.1
```

This updates `VERSION`, `gr4vy-swift/Version.swift` and the README examples. Commit it in any PR, a feature PR or a small one of its own, and merge it. Bumping the version releases nothing.

Use semantic versioning: `1.3.1` for a fix, `1.4.0` for a feature, `2.0.0` for a breaking change, and `1.4.0-beta.1` for a pre-release.

## 2. Run the Release workflow

Once CI on `main` has passed: **Actions → Release → Run workflow**, on `main`.

The first job checks, without any secrets, that:

- `VERSION` is a semantic version and `Version.swift` matches it
- that version isn't tagged yet (or is tagged on this exact commit, when re-running)
- `ci-complete` passed on this commit

It then lists every PR since the last release, with its author and who approved it, and any change to paths a person must always review. Read that list in the run's summary.

## 3. Approve it

The `release` job waits for approval in the `release` environment. Someone other than the person who started the run approves it. Approve only if you've read the list and everything in it should ship.

Once approved, the job gets a short-lived token from Octo STS, tags the commit and publishes the GitHub release with generated notes. Releases are immutable: the tag can't be moved or deleted afterwards.

## If something goes wrong

- **A check fails:** fix it on `main` and run the workflow again.
- **The run fails after approval:** run it again. It skips whatever already happened.
- **A bad release went out:** don't delete or move the tag, because merchants may already have resolved it, and immutable releases forbid it anyway. Fix forward with a new patch version.

## Repo settings this relies on

- A `release` environment that only `main` can deploy to, with required reviewers and self-review prevented. It holds no secrets.
- The `gr4vy-swift-release` Octo STS policy in the org's `.github` repo, which gives a `contents: write` token on this repo only to `release.yml` on `main`, running in the `release` environment. The Octo STS App must have access to this repo.
- A tag ruleset on all tags that blocks creation, update and deletion, with only the Octo STS App able to bypass it.
- Immutable releases turned on.
- `ci-complete` as the required status check on `main`.
