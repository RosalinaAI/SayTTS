// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TTSServer",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-configuration", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "TTSServer",
            dependencies: [.product(name: "Hummingbird", package: "hummingbird")],
            path: "Sources/TTSServer"
        ),
        .testTarget(
            name: "TTSServerTests",
            dependencies: ["TTSServer"],
            path: "Tests/TTSServerTests"
        )
    ]
)
