//
//  File.swift
//  NetworkLayer
//
//  Created by Alex.personal on 2/10/24.
//

import Foundation

public final class NetworkLayerConfig {
    private static let defaultPath = "www.google.com"
    public static var host: String {
        completion?() ?? defaultPath
    }
    
    /// The completion closure holds the logic to provide the base path or configuration value.
    ///  It must be set only once during app initialization, before any API requests are made.
    ///  Once set, it should not change, preventing any risk of data races.
    ///  The `nonisolated(unsafe)` keyword is used to allow synchronous access to this static
    ///  property without awaiting, but this comes with inherent risks, so use with caution.
    ///  Ensure proper application structure so that `completion` is initialized before use.
    nonisolated(unsafe) private static var completion: (() -> String)?

    static func config(host: String) {
        completion = {
            host
        }
    }
}
