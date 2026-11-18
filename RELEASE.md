# Releasing the Gr4vy Swift SDK

Swift Package Manager installs this SDK straight from git tags, so creating a tag *is* the release. Only the Release workflow creates tags, and only after a person approves it. Why: [ADR 0011](docs/adr/0011-releases-from-a-manual-workflow.md).

## 1. Bump the version in a PR

```bash
./update_version.sh 1.3.1
```

This updates `VERSION`, `gr4vy-swift/Version.swift` and the README examples. Commit it in any PR, a feature PR or a small one of its own, and merge it. Merging starts a release that waits for approval; nothing ships until someone approves it. If the release changes SDK code, run [QA](docs/QA.md) first and write it up in `docs/qa-runs/`. A release that only changes CI, docs or the version number needs none.

Use semantic versioning: `1.3.1` for a fix, `1.4.0` for a feature, `2.0.0` for a breaking change, and `1.4.0-beta.1` for a pre-release.

## 2. The Release workflow starts by itself

When CI passes on `main`, the Release workflow starts for that exact commit. If `VERSION` is already released, it stops there with nothing to do, which is what happens on every merge that doesn't bump the version. Otherwise its first job checks, without any secrets, that:

- `VERSION` is a semantic version and `Version.swift` matches it
- that version isn't tagged yet (or is tagged on this exact commit, when re-running)
- `ci-complete` passed on this commit

You can also start it by hand on `main` (**Actions → Release → Run workflow**), for example to retry.

It then lists every PR since the last release, with its author and who approved it, and any change to paths a person must always review. Read that list in the run's summary.

## 3. Approve it

A Slack notice says the version is waiting for release approval, with a link to the run. The `release` job waits in the `release` environment until a release approver approves it. As in Gr4vy's server SDKs, the approvers are a short list in the environment's settings, and they may approve a run their own merge started; anyone else's release waits for one of them. Approve only if you've read the list and everything in it should ship.

Once approved, the job gets a short-lived token from Octo STS, tags the commit and publishes the GitHub release with generated notes. Releases are immutable: the tag can't be moved or deleted afterwards. Slack says when it's released, or that it failed or was rejected.

## If something goes wrong

- **A check fails:** fix it on `main`; the next green CI run starts the release again, or run it by hand.
- **The run fails after approval:** run it again. It skips whatever already happened.
- **A bad release went out:** don't delete or move the tag, because merchants may already have resolved it, and immutable releases forbid it anyway. Fix forward with a new patch version.

## Repo settings this relies on

- A `release` environment that only `main` can deploy to, with a short list of required reviewers, who may approve their own runs. It holds no secrets.
- The `gr4vy-swift-release` Octo STS policy in the org's `.github` repo, which gives a `contents: write` token on this repo only to `release.yml` on `main`, running in the `release` environment. The Octo STS App must have access to this repo.
- A tag ruleset on all tags that blocks creation, update and deletion, with only the Octo STS App able to bypass it.
- Immutable releases turned on.
- `ci-complete` as the required status check on `main`.
- This repo on the `SLACK_SDK_WEBHOOK_URL` org secret's repository list, for the Slack notices.
