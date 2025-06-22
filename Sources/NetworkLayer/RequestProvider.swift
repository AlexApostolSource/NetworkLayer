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
    private let requestInterceptorAdapter: RequestInterceptorAdapter
    private let decoder: NetworkLayerDecoder
    private let logger: NetworkLayerLogger?

    public init(
        networkLayer: NetworkLayerProtocol,
        requestInterceptorAdapter: RequestInterceptorAdapter,
        decoder: NetworkLayerDecoder = JSONDecoder(),
        logger: NetworkLayerLogger?
    ) {
        self.networkLayer = networkLayer
        self.requestInterceptorAdapter = requestInterceptorAdapter
        self.decoder = decoder
        self.logger = logger
    }

    public func execute<T: Decodable>(endpoint: NetworkLayerEndpoint) async throws -> T {
        let request = try await requestInterceptorAdapter.adapt(endpoint: endpoint)
        let result = try await networkLayer.execute(request: request)
        let process = try await requestInterceptorAdapter.process(result, for: endpoint)

        switch process {
        case .success((let data, _)):
            do {
                return try decoder.attemptDecode(type: T.self, from: data)
            } catch {
                logger?.log(
                    logMetadata: NetworkLayerLogMetadata(
                        logLevel: .error,
                        subsystem: .decoding(error)
                    )
                )
                throw error
            }
        case .failure(let error):
            throw error
        }
    }
}
