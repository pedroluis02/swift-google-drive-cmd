// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftGoogleDriveCmd",
    dependencies: [
        .package(url: "https://github.com/darrarski/swift-google-drive-client.git", from: "0.12.1")
    ],
    targets: [
        .executableTarget(name: "gdrive-cli")
    ]
)
