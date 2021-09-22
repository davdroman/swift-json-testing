// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCTJSONKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(name: "XCTJSONKit", targets: ["XCTJSONKit"]),
    ],
    targets: [
        .target(
            name: "XCTJSONKit",
            dependencies: [.product(name: "CustomDump", package: "swift-custom-dump")]
        ),
        .testTarget(name: "XCTJSONKitTests", dependencies: [
            .target(name: "XCTJSONKit"),
        ]),
    ]
)

package.dependencies = [
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", .branch("main")),
]
