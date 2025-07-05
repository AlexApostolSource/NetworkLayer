//
//  InterceptorPipeline.swift
//  NetworkLayer
//
//  Created by Alex.personal on 15/6/25.
//
import Foundation
import NLCore

public struct RequestInterceptorAdapter: Sendable {
    private let interceptors: [RequestInterceptor]

    public init(interceptors: [RequestInterceptor]) {
        self.interceptors = interceptors
    }

    public func adapt(endpoint: NetworkLayerEndpoint) async throws -> URLRequest {
        guard var request = endpoint.asURLRequest else { throw NetworkLayerError.malformedRequest }
        for interceptor in interceptors {
            try Task.checkCancellation()
            request = try await interceptor.adapt(request, for: endpoint)
        }
        return request
    }

    func process(
        _ result: NetworkResponse,
        for endpoint: NetworkLayerEndpoint
    ) async throws -> NetworkResponse {
        var current = result

        for interceptor in interceptors.reversed() {
            try Task.checkCancellation()
            current = try await interceptor.process(current, for: endpoint)
        }
        return current
    }
}
