// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "gr4vy-swift",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "gr4vy-swift",
            targets: ["gr4vy-swift"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "gr4vy-swift",
            dependencies: [],
            path: "gr4vy-swift"),
        .testTarget(
            name: "gr4vy-swiftTests",
            dependencies: ["gr4vy-swift"],
            path: "gr4vy-swiftTests"),
    ]
) 