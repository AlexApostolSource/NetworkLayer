//
//  File.swift
//  NetworkLayer
//
//  Created by Alex.personal on 3/10/24.
//

import Foundation
import NLCore

public protocol RequestProviderProtocol {
    func execute<T: Decodable>(endpoint: NetworkLayerEndpoint)  async throws -> T
}

public final class RequestProvider: RequestProviderProtocol {
    private let networkLayer: NetworkLayerProtocol

    public init(networkLayer: NetworkLayerProtocol) {
        self.networkLayer = networkLayer
    }
    
    public func execute<T: Decodable>(endpoint: NetworkLayerEndpoint)  async throws -> T {
        guard let request = endpoint.asURLRequest else { throw URLError(.badURL)}
        return try await networkLayer.execute(request: request)
    }
}
