//
//  RetryInterceptor.swift
//  NetworkLayer
//
//  Created by Alex.personal on 1/7/25.
//

import Foundation
@preconcurrency import NLCore

public final actor RetryInterceptor: RequestInterceptor {
    private let config: RetryConfiguration
    private let networkLayer: NetworkLayerProtocol
    private var attempts: [URLRequest: Int] = [:]

    public init(config: RetryConfiguration = .default, networkLayer: NetworkLayerProtocol) {
        self.config = config
        self.networkLayer = networkLayer
    }

    public func process<E: NetworkLayerEndpoint>(
        _ result: Result<(Data, URLResponse), Error>,
        for endpoint: E
    ) async throws -> Result<(Data, URLResponse), Error> {

        guard case let .failure( error ) = result, let request = endpoint.asURLRequest,
              shouldRetry(error: error, request: request)
        else { return result }

        attempts.updateValue((attempts[request] ?? 0) + 1, forKey: request)

        do {
            let result = try await networkLayer.execute(request: request)
            switch result {
            case .success(let response):
                attempts.removeValue(forKey: request)
                return .success(response)
            case .failure(let error):
                if shouldRetry(error: error, request: request) {
                    return try await process(.failure(error), for: endpoint)
                } else {
                    throw error
                }
            }
        } catch {
            throw error
        }
    }

    // MARK: – Helpers

    private func shouldRetry(
        error: Error, request: URLRequest
    ) -> Bool {
        if let urlErr = error as? URLError, attempts[request] ?? 0 < config.maxAttempts {
            return config.retryableURLErrors.contains(urlErr.code)
        }
        return false
    }
}
