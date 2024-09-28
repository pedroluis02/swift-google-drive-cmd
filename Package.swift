// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "GoogleDriveCmd",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.72.0")
    ],
    targets: [
        .executableTarget(
            name: "gdrive-cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio")
            ]
        ),
        .testTarget(
            name: "GoogleDriveCmdTests",
            dependencies: ["gdrive-cli"]
        )
    ]
)
