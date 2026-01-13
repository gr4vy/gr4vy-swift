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
    dependencies: [
        .package(url: "https://github.com/ios-3ds-sdk/SPM.git", exact: "2.5.30"),
    ],
    targets: [
        .target(
            name: "gr4vy-swift",
            dependencies: [
                .product(name: "ThreeDS_SDK", package: "SPM"),
            ],
            path: "gr4vy-swift",
            resources: [
                .process("acq-encryption-amex-sign-certeq-rsa-ncaDS.crt"),
                .process("acq-encryption-diners-sign-certeq-rsa-ncaDS.crt"),
                .process("acq-encryption-jcb-sign-certeq-rsa-ncaDS.crt"),
                .process("acq-encryption-mc-sign-certeq-rsa-ncaDS.crt"),
                .process("acq-encryption-visa-sign-certeq-rsa-ncaDS.crt"),
                .process("acq-root-certeq-prev-environment-new.crt")
            ]),
        .testTarget(
            name: "gr4vy-swiftTests",
            dependencies: ["gr4vy-swift"],
            path: "gr4vy-swiftTests"),
    ]
) 