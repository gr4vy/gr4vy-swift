#!/bin/bash

# Script to update version across all files in the Gr4vy iOS SDK

if [ $# -eq 0 ]; then
    echo "Usage: $0 <new_version>"
    echo "Example: $0 1.0.1"
    exit 1
fi

NEW_VERSION=$1

# Validate version format (semantic versioning)
if [[ ! $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9\.-]+)?$ ]]; then
    echo "Error: Version must be in format X.Y.Z or X.Y.Z-label (e.g., 1.0.0 or 1.0.0-beta.1)"
    exit 1
fi

echo "Updating version to $NEW_VERSION..."

# Update VERSION file
echo $NEW_VERSION > VERSION

# Update Version.swift
sed -i '' "s/static let current = \".*\"/static let current = \"$NEW_VERSION\"/" gr4vy-swift/Version.swift

# Update test files that might reference the version
sed -i '' "s/XCTAssertTrue(userAgent!.contains(\"Gr4vy-iOS-SDK\/.*\"))/XCTAssertTrue(userAgent!.contains(\"Gr4vy-iOS-SDK\/$NEW_VERSION\"))/" gr4vy-swiftTests/Gr4vySDKTests.swift
sed -i '' "s/XCTAssertTrue(userAgent.contains(\".*\"), \"User agent should contain version\")/XCTAssertTrue(userAgent.contains(\"$NEW_VERSION\"), \"User agent should contain version\")/" gr4vy-swiftTests/Gr4vySDKTests.swift

echo "Version updated to $NEW_VERSION successfully!"
echo ""
echo "Updated files:"
echo "- VERSION"
echo "- gr4vy-swift/Version.swift"
echo "- gr4vy-swiftTests/Gr4vySDKTests.swift"
echo ""
echo "Files that automatically read from Version.swift:"
echo "- gr4vy-swift/Gr4vySDK.swift"
echo "- gr4vy-swift.podspec"
echo ""
echo "For SPM, create a Git tag: git tag $NEW_VERSION" 