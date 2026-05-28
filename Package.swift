// swift-tools-version: 6.0

/* Native */
import PackageDescription

// MARK: - Package

let package = Package(
    name: "MockupKit",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "MockupKit",
            targets: ["MockupKit"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/grantbrooksgoodman/component-kit",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "MockupKit",
            dependencies: [
                .product(
                    name: "ComponentKit",
                    package: "component-kit"
                ),
            ],
            path: "Sources",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
