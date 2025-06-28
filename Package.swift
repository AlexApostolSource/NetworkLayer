// swift-tools-version: 5.10.0

import PackageDescription

let package = Package(
    name: "NetworkLayer",
    platforms: [.iOS(.v15), .macOS(.v14)],
    products: [
        .library(
            name: "NetworkLayer",
            targets: ["NetworkLayer"]),
    ],
    targets: [
        .plugin(
            name: "SwiftLintBuildToolPlugin",
            capability: .buildTool(),
            dependencies: [.target(name: "SwiftLintBinary")],
            packageAccess: false
        ),
        .plugin(
            name: "SwiftLintCommandPlugin",
            capability: .command(
                intent: .custom(verb: "swiftlint", description: "SwiftLint Command Plugin"),
                permissions: [
                    .writeToPackageDirectory(
                        reason: "When this command is run with the `--fix` option it may modify source files."
                    ),
                ]
            ),
            dependencies: [.target(name: "SwiftLintBinary")],
            packageAccess: false
        ),
       
        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.59.1/SwiftLintBinary.artifactbundle.zip",
            checksum: "b9f915a58a818afcc66846740d272d5e73f37baf874e7809ff6f246ea98ad8a2"
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
            ]),
        .testTarget(
            name: "NetworkLayerTests",
            dependencies: ["NetworkLayer"], plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin"
                )
            ]
        ),
    ]
)
