//
//  RetryInterceptor.swift
//  NetworkLayer
//
//  Created by Alex.personal on 1/7/25.
//

import Foundation
import NLCore

public final actor RetryInterceptor: RequestInterceptor {
    private let config: RetryConfiguration
    private let networkLayer: NetworkLayerProtocol
    private var attempts: [UUID: Int] = [:]
    private let retryableMethods: [String]

    public init(networkLayer: NetworkLayerProtocol, config: RetryConfiguration = .default) {
        self.config = config
        self.networkLayer = networkLayer
        self.retryableMethods = config.retryableMethods.map({ $0.lowercased() })
    }

    public func process(
        _ result: NetworkResponse,
        for endpoint: NetworkLayerEndpoint
    ) async throws -> NetworkResponse {
        let id = UUID()
        guard
            case .failure(let initialError) = result.result,
            let request = endpoint.asURLRequest,
            retryableMethods
                .contains(endpoint.method.rawValue.lowercased()),
            shouldRetry(
                error: initialError,
                urlKey: id,
                statusCode: result.statusCode)
        else { return result }

        defer { attempts.removeValue(forKey: id) }

        var currentError = initialError
        var statusCode = result.statusCode

        while shouldRetry(
            error: currentError,
            urlKey: id,
            statusCode: statusCode) {
            attempts[id, default: 0] += 1

            guard let attempt = attempts[id] else {
                throw NetworkLayerError.cannotIdentifyRetryRequest(key: id)
            }
            let delay = jitter(attempt: attempt)

            try await Task.sleep(nanoseconds: delay)

            if Task.isCancelled { throw CancellationError() }

            do {
                return try await networkLayer.execute(request: request)
            } catch let error as NetworkError {
                currentError = error
                switch error {
                case let .http(_, response):
                    statusCode = response.statusCode
                default:
                    statusCode = nil
                }
            }
        }

        return result
    }

    // MARK: - Helpers
    private func shouldRetry(error: Error, urlKey: UUID, statusCode: Int?) -> Bool {

       guard attempts[urlKey, default: 0] < config.maxAttempts else { return false }

        switch (error, statusCode) {
        case (let networkError as NetworkError, let code?):
            if case .http = networkError {
                return config.retryableStatusCodes.contains(code)
            }
        case (let urlErr as URLError, _):
            return config.retryableURLErrors.contains(urlErr.code)
        default:
            return false
        }
        return false
    }

    private func jitter(attempt: Int) -> UInt64 {
        let base   = config.baseDelay.asDoubleValue      // base delay (e.g. 0.5 s)
        let delay  = base * pow(2.0, Double(attempt - 1)) // exponential back-off
        let jitter = config.jitter.asDoubleValue
        let random = Double.random(in: -jitter...jitter)
        let jittered = delay * (1 + random)
        let capped = min(jittered, config.maxDelay.asDoubleValue)
        return UInt64(capped * 1_000_000_000)
    }
}
