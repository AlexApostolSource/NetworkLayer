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
            name: "NetworkLayerSwiftLintBuildToolPlugin",
            capability: .buildTool(),
            path: "Plugins/NetworkLayerSwiftLintBuildToolPlugin"
        ),
        .target(name: "NLCore", plugins: [
            .plugin(
                name: "NetworkLayerSwiftLintBuildToolPlugin"
            )
        ]),
        .target(
            name: "NetworkLayer", dependencies: ["NLCore"], plugins: [
                .plugin(
                    name: "NetworkLayerSwiftLintBuildToolPlugin"
                )
            ]
        ),
        .testTarget(
            name: "NetworkLayerTests",
            dependencies: ["NetworkLayer"], plugins: [
                .plugin(
                    name: "NetworkLayerSwiftLintBuildToolPlugin"
                )
            ]
        ),

        .testTarget(
            name: "NLCoreTests",
            dependencies: ["NLCore"], plugins: [
                .plugin(
                    name: "NetworkLayerSwiftLintBuildToolPlugin"
                )
            ]
        )
    ]
)
