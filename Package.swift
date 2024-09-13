// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftGoogleDriveCmd",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/darrarski/swift-google-drive-client", from: "0.12.1")
    ],
    targets: [
        .executableTarget(
            name: "gdrive-cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "GoogleDriveClient", package: "swift-google-drive-client")
            ]
        )
    ]
)
