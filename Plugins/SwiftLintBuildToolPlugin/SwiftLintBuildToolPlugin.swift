import Foundation
import PackagePlugin

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
            "/opt/homebrew/bin/swiftlint", // Brew (Apple Silicon)
            "/usr/local/bin/swiftlint", // Brew (Intel)
            "/usr/bin/swiftlint" // Xcode 15+ Toolchain
        ]
        let fileManager = FileManager.default
        for cand in candidates where fileManager.isExecutableFile(atPath: cand) {
            return Path(cand)
        }
        throw SwiftLintBuildToolPluginError.swiftlintNotFound
    }
}
