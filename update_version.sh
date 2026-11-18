#!/bin/bash

# Script to update version across all files in the Gr4vy iOS SDK

if [ $# -eq 0 ]; then
    echo "Usage: $0 <new_version>"
    echo "Example: $0 1.0.1"
    exit 1
fi

NEW_VERSION=$1

# Validate version format (semantic versioning)
ID='(0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*)'
SEMVER="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-$ID(\.$ID)*)?\$"
if [[ ! $NEW_VERSION =~ $SEMVER ]]; then
    echo "Error: Version must be in format X.Y.Z or X.Y.Z-label (e.g., 1.0.0 or 1.0.0-beta.1)"
    exit 1
fi

echo "Updating version to $NEW_VERSION..."

# Update VERSION file
echo $NEW_VERSION > VERSION

# Update Version.swift
sed -i '' "s/static let current = \".*\"/static let current = \"$NEW_VERSION\"/" gr4vy-swift/Version.swift

# No test rewrites needed: the tests derive expectations from Gr4vySDK.name and
# Gr4vySDK.version rather than hardcoding them.

# Update README.md dependency examples
if [ -f "README.md" ]; then
    # Update Swift Package Manager dependency
    sed -i '' "s/from: \".*\")/from: \"$NEW_VERSION\")/" README.md

    # Update any other version references in README
    sed -i '' "s/Version [0-9]\+\.[0-9]\+\.[0-9]\+[^[:space:]]*/Version $NEW_VERSION/" README.md
fi

echo "Version updated to $NEW_VERSION successfully!"
echo ""
echo "Updated files:"
echo "- VERSION"
echo "- gr4vy-swift/Version.swift"
if [ -f "README.md" ]; then
    echo "- README.md (dependency examples)"
fi
echo ""
echo "Files that automatically read from Version.swift:"
echo "- gr4vy-swift/Gr4vySDK.swift"
echo "- gr4vy-swiftTests/ (tests derive from Gr4vySDK.name/.version)"
echo ""
echo "Next steps:"
echo "1. Commit the bump in a PR and merge it"
echo "2. Once CI passes on main, approve the Release run it starts (see RELEASE.md)" 