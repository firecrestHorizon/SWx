// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SWx",
  platforms: [.macOS(.v10_15)],  // macOS v10.15 needed for ArgumentParser
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
  ],
  targets: [
    .executableTarget(
      name: "SWx",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    )
  ]
)
