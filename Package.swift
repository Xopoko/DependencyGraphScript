// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DependencyGraphScript",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.4.0")
    ],
    targets: [
        .executableTarget(
            name: "dependency_graph",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources"
        )
    ]
)
