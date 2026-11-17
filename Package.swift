// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ApplicationTracker",
    platforms: [.macOS(.v14)],
    products: [.library(name: "TrackerCore", targets: ["TrackerCore"])],
    targets: [
        .target(name: "TrackerCore"),
        .testTarget(name: "TrackerCoreTests", dependencies: ["TrackerCore"]),
    ]
)
