import PackagePlugin
import Foundation

@main
struct SwiftLintBuildToolPlugin: BuildToolPlugin {

    func createBuildCommands(
        context: PluginContext,
        target: Target
    ) throws -> [Command] {

        let swiftlint = try Self.findSwiftLint()

        guard let module = target as? SourceModuleTarget else { return [] }
        let sources = module.sourceFiles(withSuffix: "swift")
                           .map(\.path.string)
        return [
            .prebuildCommand(
                displayName: "SwiftLint (\(target.name))",
                executable: swiftlint,
                arguments: ["lint",
                            "--quiet",
                            "--cache-path", context.pluginWorkDirectory.string]
                            + sources,
                environment: [:],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        ]
    }

    // --------------------------------------------------------------------
    // MARK: - Helpers
    // --------------------------------------------------------------------

    /// Busca SwiftLint en las rutas más habituales.
     static func findSwiftLint() throws -> Path {
        let candidates = [
            "/opt/homebrew/bin/swiftlint",   // Brew (Apple Silicon)
            "/usr/local/bin/swiftlint",      // Brew (Intel)
            "/usr/bin/swiftlint"             // Xcode 15+ Toolchain
        ]
        for c in candidates where FileManager.default.isExecutableFile(atPath: c) {
            return Path(c)
        }
        throw SwiftLintBuildToolPluginError.swiftlintNotFound
    }
}

