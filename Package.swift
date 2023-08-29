// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-json-testing",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "JSONTesting", targets: ["JSONTesting"]),
    ],
    targets: [
        .target(
            name: "JSONTesting",
            dependencies: [.product(name: "CustomDump", package: "swift-custom-dump")]
        ),
        .testTarget(name: "JSONTestingTests", dependencies: [
            .target(name: "JSONTesting"),
        ]),
    ]
)

package.dependencies = [
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.0.0"),
]
