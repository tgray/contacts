// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "contacts-cli",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "contacts", targets: ["contacts-cli"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git",
                 from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "contacts-cli",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")],
            exclude: ["contacts.1.ronn", "contacts.1"],
            resources: [
                .copy("version.json")
            ]
            ),
        .testTarget(
            name: "contactsTests",
            dependencies: ["contacts-cli"]),
    ]
)
