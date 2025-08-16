// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Cuppy_backend",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Cuppy_backend",
            targets: ["Cuppy_backend"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.5.1")
    ],
    targets: [
        .target(
            name: "Cuppy_backend",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]),
        .testTarget(
            name: "Cuppy_backendTests",
            dependencies: ["Cuppy_backend"]),
    ]
)