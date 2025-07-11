//
//  File.swift
//  NetworkLayer
//
//  Created by Alex.personal on 3/10/24.
//

import Foundation
import NLCore

public protocol RequestProviderProtocol {
    func execute<T: Decodable>(endpoint: NetworkLayerEndpoint) async throws -> T
}

public final class RequestProvider: RequestProviderProtocol {
    private let networkLayer: NetworkLayerProtocol
    private let requestInterceptorAdapter: RequestInterceptorAdapterProtocol
    private let decoder: NetworkLayerDecoder
    private let logger: NetworkLayerLogger?

    public init(
        networkLayer: NetworkLayerProtocol,
        requestInterceptorAdapter: RequestInterceptorAdapterProtocol,
        decoder: NetworkLayerDecoder = JSONDecoder(),
        logger: NetworkLayerLogger?
    ) {
        self.networkLayer = networkLayer
        self.requestInterceptorAdapter = requestInterceptorAdapter
        self.decoder = decoder
        self.logger = logger
    }

    public func execute<T: Decodable>(endpoint: NetworkLayerEndpoint) async throws -> T {
        do {
            let request = try await requestInterceptorAdapter.adapt(endpoint: endpoint)
            let result = try await networkLayer.execute(request: request)
            let process = try await requestInterceptorAdapter.process(result, for: endpoint)
            switch process.result {
            case .success:
                return try decoder
                    .attemptDecode(type: T.self, from: process.data)
            case .failure(let error):
                throw error
            }

        } catch let error as NetworkLayerError {
            switch error {
            case .decodingFailed(let error, _):
                logger?.log(
                    logMetadata: NetworkLayerLogMetadata(
                        logLevel: .error,
                        subsystem: .decoding(error)
                    )
                )
            default:
                logger?.log(
                    logMetadata: NetworkLayerLogMetadata(
                        logLevel: .error,
                        subsystem: .network(error)
                    )
                )
            }
            throw error
        } catch let error {
            logger?.log(
                logMetadata: NetworkLayerLogMetadata(
                    logLevel: .error,
                    subsystem: .network(error)
                )
            )
            throw error
        }
    }
}
