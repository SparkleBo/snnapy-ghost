// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SnnapyGhost",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "SnnapyGhost",
            targets: ["SnnapyGhost"]
        )
    ],
    targets: [
        .executableTarget(
            name: "SnnapyGhost",
            path: "Sources/SnnapyGhost",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Carbon"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("ScreenCaptureKit")
            ]
        )
    ]
)
