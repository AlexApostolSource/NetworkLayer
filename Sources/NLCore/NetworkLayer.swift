// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public protocol NetworkLayerProtocol {
    func execute<T: Decodable>(request: URLRequest)  async throws -> T
}

public final class NetworkLayer: NetworkLayerProtocol {
    let networkLayerCore: NetworkLayerCoreProtocol
    
    public init(networkLayerCore: NetworkLayerCoreProtocol) {
        self.networkLayerCore = networkLayerCore
    }
    
    public func execute<T: Decodable>(request: URLRequest)  async throws -> T {
        let (data, _) = try await networkLayerCore.execute(request: request)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
