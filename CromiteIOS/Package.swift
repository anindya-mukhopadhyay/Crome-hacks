// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CromiteIOS",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "CromiteCore", targets: ["CromiteCore"]),
        .library(name: "CromiteUI", targets: ["CromiteUI"]),
        .executable(name: "CromiteApp", targets: ["CromiteApp"]),
        .executable(name: "CromiteTestRunner", targets: ["CromiteTestRunner"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CromiteCore",
            dependencies: [],
            path: "Sources/CromiteCore"
        ),
        .target(
            name: "CromiteUI",
            dependencies: ["CromiteCore"],
            path: "Sources/CromiteUI"
        ),
        .executableTarget(
            name: "CromiteApp",
            dependencies: ["CromiteCore", "CromiteUI"],
            path: "Sources/CromiteApp"
        ),
        .executableTarget(
            name: "CromiteTestRunner",
            dependencies: ["CromiteCore"],
            path: "Sources/CromiteTestRunner"
        )
    ]
)
