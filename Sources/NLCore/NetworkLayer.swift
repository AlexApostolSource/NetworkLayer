// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public protocol NetworkLayerProtocol {
    func execute<T: Decodable>(request: URLRequest)  async throws -> T
}

public final class NetworkLayer: NetworkLayerProtocol {
   private let networkLayerCore: NetworkLayerCoreProtocol
    
    public init(urlSession: URLSession = .shared) {
        self.networkLayerCore = NetworkLayerCore(session: urlSession)
    }
    
    public func execute<T: Decodable>(request: URLRequest)  async throws -> T {
        let (data, _) = try await networkLayerCore.execute(request: request)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
