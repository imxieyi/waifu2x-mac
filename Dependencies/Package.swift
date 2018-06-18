// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Dependencies",
    products: [
        .library(name: "Dependencies", type: .dynamic, targets: ["Dependencies"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jatoben/CommandLine.git", from: "3.0.0-pre1"),
    ],    targets: [
        .target(name: "Dependencies", dependencies: ["CommandLine"], path: "." )
    ]
)
