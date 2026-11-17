// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ApplicationTracker",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "ApplicationTracker", targets: ["ApplicationTracker"])],
    targets: [
        .target(name: "TrackerCore"),
        .executableTarget(name: "ApplicationTracker", dependencies: ["TrackerCore"]),
        .testTarget(name: "TrackerCoreTests", dependencies: ["TrackerCore"]),
    ]
)
