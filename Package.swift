// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DesktopPetApp",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(
            name: "DesktopPetApp",
            targets: ["DesktopPetApp"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "DesktopPetApp",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "DesktopPetAppTests",
            dependencies: ["DesktopPetApp"]
        ),
    ]
)
