//
//  InterceptorPipeline.swift
//  NetworkLayer
//
//  Created by Alex.personal on 15/6/25.
//
import Foundation

public struct RequestInterceptorAdapter: Sendable {
    private let interceptors: [RequestInterceptor]

    public init(interceptors: [RequestInterceptor]) {
        self.interceptors = interceptors
    }

    public func adapt<E: NetworkLayerEndpoint>(endpoint: E) async throws -> URLRequest {
        guard var request = endpoint.asURLRequest else { throw NetworkLayerError.malformedRequest }
        for interceptor in interceptors {
            try Task.checkCancellation()
            request = try await interceptor.adapt(request, for: endpoint)
        }
        return request
    }

    public func process(
        _ result: Result<(Data, URLResponse), Error>,
        for endpoint: any NetworkLayerEndpoint
    ) async throws -> Result<(Data, URLResponse), Error> {
        var current = result

        for interceptor in interceptors.reversed() {
            try Task.checkCancellation()
            current = try await interceptor.process(current, for: endpoint)
        }
        return current
    }
}
