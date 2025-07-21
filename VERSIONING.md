# Version Management

This SDK uses a centralized version management system to ensure consistency for version numbers

## How it works

The version is centrally managed in `gr4vy-swift/Version.swift`:

```swift
internal struct Version {
    static let current = "1.0.0"
}
```

### Files that automatically read from Version.swift:

1. **`gr4vy-swift/Gr4vySDK.swift`** - Uses `Version.current` for the public API
2. **`gr4vy-swift.podspec`** - Extracts version using Ruby regex
3. **`VERSION`** - Plain text file for external tools (updated by script)

### Distribution methods:

- **Swift Package Manager (SPM)**: Uses Git tags for versioning
- **CocoaPods**: Reads from `Version.swift` via podspec
- **Manual Integration**: Uses `Gr4vySDK.version` property

## Updating the version

### Option 1: Use the update script (Recommended)

```bash
./update_version.sh 1.0.1
```

This script will:
- Update `Version.swift` with the new version
- Update the `VERSION` file
- Update test files that reference the version
- Show you what to do next for SPM (create Git tag)

### Option 2: Manual update

1. Edit `gr4vy-swift/Version.swift` and change the version string
2. Update the `VERSION` file to match
3. Update any test files that reference the version
4. For SPM, create a Git tag: `git tag 1.0.1`

## Validation

The version format follows semantic versioning (X.Y.Z). The update script validates this format.

## Testing

Tests verify that:
- The version is properly formatted
- The user agent includes the correct version
- All components read from the same source 