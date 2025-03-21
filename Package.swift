// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Plantam",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Plantam",
            targets: ["Plantam"]),
    ],
    dependencies: [
        .package(url: "https://github.com/openai/openai-swift.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Plantam",
            dependencies: [
                .product(name: "OpenAI", package: "openai-swift"),
            ]),
        .testTarget(
            name: "PlantamTests",
            dependencies: ["Plantam"]),
    ]
)
