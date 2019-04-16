// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Dependencies",
    products: [
        .library(name: "Dependencies", type: .dynamic, targets: ["Dependencies"]),
    ],
    dependencies: [
        .package(url: "https://github.com/benoit-pereira-da-silva/CommandLine", from: "4.0.9"),
    ],    targets: [
        .target(name: "Dependencies", dependencies: ["CommandLineKit"], path: "." )
    ]
)
