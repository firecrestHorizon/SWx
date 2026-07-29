// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SWx",
  platforms: [.macOS(.v10_15)],  // macOS v10.15 needed for ArgumentParser
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-argument-parser.git",
      "1.7.2"..<"1.8.0"
    ),
  ],
  targets: [
    .executableTarget(
      name: "swx",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    .testTarget(
      name: "SWxTests",
      dependencies: ["swx"],
      resources: [.copy("Fixtures")]
    )
  ]
)
