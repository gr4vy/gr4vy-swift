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

# Update testSDKVersion hardcoded version if present
sed -i '' "s/XCTAssertEqual(Gr4vySDK.version, \".*\")/XCTAssertEqual(Gr4vySDK.version, \"$NEW_VERSION\")/" gr4vy-swiftTests/Gr4vySDKTests.swift

# Update README.md dependency examples
if [ -f "README.md" ]; then
    # Update Swift Package Manager dependency
    sed -i '' "s/from: \".*\")/from: \"$NEW_VERSION\")/" README.md
    
    # Update CocoaPods dependency
    sed -i '' "s/'gr4vy-swift', '~> .*'/'gr4vy-swift', '~> $NEW_VERSION'/" README.md
    
    # Update any other version references in README
    sed -i '' "s/Version [0-9]\+\.[0-9]\+\.[0-9]\+[^[:space:]]*/Version $NEW_VERSION/" README.md
fi

echo "Version updated to $NEW_VERSION successfully!"
echo ""
echo "Updated files:"
echo "- VERSION"
echo "- gr4vy-swift/Version.swift"
echo "- gr4vy-swiftTests/Gr4vySDKTests.swift"
if [ -f "README.md" ]; then
    echo "- README.md (dependency examples)"
fi
echo ""
echo "Files that automatically read from Version.swift:"
echo "- gr4vy-swift/Gr4vySDK.swift"
echo "- gr4vy-swift.podspec"
echo ""
echo "Next steps:"
echo "1. Test the build: xcodebuild -scheme gr4vy-swift build"
echo "2. Commit changes: git add . && git commit -m \"Bump version to $NEW_VERSION\""
echo "3. Create Git tag: git tag $NEW_VERSION"
echo "4. Push changes: git push && git push --tags" 