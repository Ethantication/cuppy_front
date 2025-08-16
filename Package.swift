// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CuppyApp",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "CuppyApp",
            targets: ["CuppyApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.5.1")
    ],
    targets: [
        .target(
            name: "CuppyApp",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]),
        .testTarget(
            name: "CuppyAppTests",
            dependencies: ["CuppyApp"]),
    ]
)