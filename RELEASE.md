# How to Release Gr4vy Swift SDK

This guide outlines the process for releasing a new version of the Gr4vy Swift SDK.

## Overview

The release process is **mostly automated** via GitHub Actions. The workflow is triggered when you push a Git tag, and it handles building, testing, and creating a draft GitHub release.

## Release Process

### 1. Prepare the Release

#### Update Version
Run the version update script with your desired version:

```bash
./update_version.sh 1.0.0-beta.1
```

This script automatically updates:
- `VERSION` file
- `gr4vy-swift/Version.swift`
- `gr4vy-swiftTests/Gr4vySDKTests.swift`
- `README.md` (all dependency examples)

#### Verify Updates
Make sure all files were updated correctly:
- Check that tests pass: `xcodebuild -scheme gr4vy-swift test`
- Verify the version appears correctly in all updated files
- Review the README to ensure dependency examples show the new version

### 2. Test the Release Build (Optional)

You can optionally test the release build locally:

```bash
# Test the build
xcodebuild -scheme gr4vy-swift build

# Run tests
xcodebuild -scheme gr4vy-swift test
```

This verifies:
- The project builds successfully
- All unit tests pass
- No compilation errors or warnings

**Note:** This step is optional since the GitHub workflow will also run tests.

### 3. Commit and Tag

#### Commit Your Changes
```bash
git add .
git commit -m "Bump version to 1.0.0-beta.1"
```

#### Create and Push Git Tag
```bash
git tag 1.0.0-beta.1
git push origin main
git push origin 1.0.0-beta.1
```

**⚠️ Important:** Pushing the tag is what triggers the automated release workflow!

### 4. Automated Release Workflow

Once you push the tag, GitHub Actions automatically:

1. **Triggers the Release Workflow** (`.github/workflows/release.yml`)
2. **Sets up the build environment** (Xcode, Swift toolchain)
3. **Validates the project structure**
4. **Runs tests** (`xcodebuild -scheme gr4vy-swift test`)
5. **Builds release framework** (`xcodebuild -scheme gr4vy-swift build`)
6. **Creates a draft GitHub release**

### 5. Finalize the Release

1. **Go to GitHub Releases page**: `https://github.com/gr4vy/gr4vy-swift/releases`
2. **Find your draft release** (it will be marked as "Draft")
3. **Edit the release notes**:
   - Add a description of what's new
   - List breaking changes (if any)
   - Include any important notes for developers
4. **Publish the release** (remove "Draft" status)

## Release Workflow Details

### What Triggers a Release?
- Pushing a Git tag matching any pattern

### What Gets Built?
- Swift Package for distribution via SPM
- Framework built and validated
- All artifacts are made available through the GitHub release

### Where Are Releases Published?
- **GitHub Releases**: Draft release for manual finalization
- **Swift Package Manager**: Automatic distribution via Git tags

## Swift Package Manager Distribution

The Gr4vy Swift SDK is distributed exclusively through Swift Package Manager (SPM). When you create a GitHub release with a Git tag:

1. **SPM automatically discovers the new version** via the Git tag
2. **Developers can update their dependencies** to the new version
3. **No additional publishing steps** are required beyond the GitHub release

### How Developers Consume Updates

**Package.swift:**
```swift
dependencies: [
    .package(url: "https://github.com/gr4vy/gr4vy-swift.git", from: "1.0.0-beta.1")
]
```

**Xcode:**
- File → Add Package Dependencies
- Enter: `https://github.com/gr4vy/gr4vy-swift.git`
- Select version or branch

## Version Naming Convention

Follow semantic versioning with optional pre-release labels:
- `1.0.0` - Stable release
- `1.0.0-beta.1` - Beta release
- `1.0.1` - Patch release

## Rollback Process

If you need to rollback a release:

1. **Delete the problematic tag**:
   ```bash
   git tag -d 1.0.0-beta.1
   git push origin --delete 1.0.0-beta.1
   ```

2. **Delete the GitHub release** (if already published)

3. **Fix the issues and create a new patch release**

**Note:** Since SPM uses Git tags directly, deleting a tag will immediately affect package resolution for new installations.

## Testing Before Release

### Local Testing
```bash
# Build the framework
xcodebuild -scheme gr4vy-swift build

# Run all tests
xcodebuild -scheme gr4vy-swift test

# Test SPM integration locally
swift build
swift test
```
