// swift-tools-version: 5.10.0

import PackageDescription

let package = Package(
    name: "NetworkLayer",
    platforms: [.iOS(.v16), .macOS(.v14)],
    products: [
        .library(
            name: "NetworkLayer",
            targets: ["NetworkLayer"]
        )
    ],
    targets: [
        .plugin(
            name: "SwiftLintBuildToolPlugin",
            capability: .buildTool(),
            path: "Plugins/SwiftLintBuildToolPlugin"
        ),
        .target(name: "NLCore", plugins: [
            .plugin(
                name: "SwiftLintBuildToolPlugin"
            )
        ]),
        .target(
            name: "NetworkLayer", dependencies: ["NLCore"], plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin"
                )
            ]
        ),
        .testTarget(
            name: "NetworkLayerTests",
            dependencies: ["NetworkLayer"], plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin"
                )
            ]
        ),

        .testTarget(
            name: "NLCoreTests",
            dependencies: ["NLCore"], plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin"
                )
            ]
        )
    ]
)
