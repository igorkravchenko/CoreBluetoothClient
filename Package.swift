// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreBluetoothClient",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "CoreBluetoothClient",
            targets: ["CoreBluetoothClient"]),
        .library(
            name: "CoreBluetoothClientLive",
            targets: ["CoreBluetoothClientLive"]),
        
        
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CoreBluetoothClient",
            dependencies: []),
        .target(
            name: "CoreBluetoothClientLive",
            dependencies: ["CoreBluetoothClient"]),
    ]
)
