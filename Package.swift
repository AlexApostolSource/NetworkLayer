// swift-tools-version: 5.10.0

import PackageDescription

let package = Package(
    name: "NetworkLayer",
    platforms: [.iOS(.v15), .macOS(.v14)],
    products: [
        .library(
            name: "NetworkLayer",
            targets: ["NetworkLayer"]
        )
    ],
    targets: [
        // ---------- PLUG-INS ----------
        .plugin(
            name: "SwiftLintBuildToolPlugin",
            capability: .buildTool()
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
        )
    ]
)
