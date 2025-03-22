// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Plantam",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Plantam",
            targets: ["Plantam"]),
    ],
    dependencies: [
        .package(url: "https://github.com/MacPaw/OpenAI.git", from: "0.3.7"),
    ],
    targets: [
        .target(
            name: "Plantam",
            dependencies: [
                .product(name: "OpenAI", package: "OpenAI"),
            ]),
        .testTarget(
            name: "PlantamTests",
            dependencies: [
                "Plantam",
                .product(name: "OpenAI", package: "OpenAI"),
            ]
        ),
    ]
)
