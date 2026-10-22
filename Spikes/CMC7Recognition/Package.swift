// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "CMC7Recognition",
    platforms: [.macOS(.v15)],
    dependencies: [.package(path: "../..")],
    targets: [
        .executableTarget(
            name: "CMC7Recognition",
            dependencies: [.product(name: "ChequeKit", package: "cheque-kit")]
        )
    ]
)