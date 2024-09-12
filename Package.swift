// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftGoogleDriveCmd",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "gdrive-cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
