// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ChequeKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "ChequeKit", targets: ["ChequeKit"]),
        .library(name: "ChequeKitUI", targets: ["ChequeKitUI"]),
    ],
    targets: [
        .target(name: "ChequeKit"),
        .target(
            name: "ChequeKitUI",
            dependencies: [.target(name: "ChequeKit")]
        ),
        .executableTarget(
            name: "ChequeKitEvaluation",
            dependencies: [.target(name: "ChequeKit")],
            path: "Tools/ChequeKitEvaluation"
        ),
        .testTarget(
            name: "ChequeKitTests",
            dependencies: [.target(name: "ChequeKit")]
        ),
        .testTarget(
            name: "ChequeKitUITests",
            dependencies: [.target(name: "ChequeKitUI")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
