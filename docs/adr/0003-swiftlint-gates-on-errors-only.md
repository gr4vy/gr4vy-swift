---
status: accepted
---

# SwiftLint gates CI on errors only

Until [#15](https://github.com/gr4vy/gr4vy-swift/pull/15), CI ran SwiftLint only if it happened to be installed on the runner, so it never ran ("SwiftLint never runs in CI", 2026-10-09). Turning it on as configured would have failed on hundreds of existing violations. So CI now installs a pinned, checksummed SwiftLint and fails only on errors. Thresholds that the existing code broke without harm were loosened (line length 200/250, up to 8 function parameters). `missing_docs` stays a warning until the existing public API is documented.

The rules that guard against real risk are errors: printing outside `Gr4vyLogger`, hard-coded URLs, `try!`, and logging values whose names look sensitive (token, key, secret, auth). Tighten the warnings back to errors as the code is cleaned up. Don't loosen these.
