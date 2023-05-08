// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lorem",
    dependencies: [
        .package(url: "https://github.com/lukaskubanek/LoremSwiftum.git", from: "2.2.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "lorem",
            dependencies: [
                "LoremSwiftum"
            ],
            path: "Sources"
            )
    ]
)
