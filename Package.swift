// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Sandbox",
    targets: [
        .target(
            name: "Sandbox",
            dependencies: []),
        .target(
            name: "Ant",
            dependencies: ["Sandbox"]),
        .target(
            name: "Sandbox CLI",
            dependencies: ["Sandbox", "Ant"])
    ]
)
