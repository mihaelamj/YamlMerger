// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "YAMLMerger",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "YAMLMerger",
            targets: ["YAMLMerger"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "YAMLMerger",
            dependencies: []
        ),
        .testTarget(
            name: "YAMLMergerTests",
            dependencies: ["YAMLMerger"],
            resources: [
                .copy("Schema")
            ]
        ),
    ]
)
