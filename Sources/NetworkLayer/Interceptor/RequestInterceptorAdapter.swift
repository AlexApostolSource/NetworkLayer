//
//  InterceptorPipeline.swift
//  NetworkLayer
//
//  Created by Alex.personal on 15/6/25.
//
import Foundation
import NLCore

public protocol RequestInterceptorAdapterProtocol: Sendable {
    var interceptors: [RequestInterceptor] { get }
    func adapt(endpoint: NetworkLayerEndpoint) async throws -> URLRequest
    func process(
        _ result: NetworkResponse,
        for endpoint: NetworkLayerEndpoint
    ) async throws -> NetworkResponse
}

public struct RequestInterceptorAdapter: RequestInterceptorAdapterProtocol {
    public let interceptors: [RequestInterceptor]

    public init(interceptors: [RequestInterceptor]) {
        self.interceptors = interceptors
    }

    public func adapt(endpoint: NetworkLayerEndpoint) async throws -> URLRequest {
        guard let request = endpoint.asURLRequest else { throw NetworkLayerError.malformedRequest }
        let chain = RequestChain(interceptors: interceptors)
        return try await chain.proceed(request, for: endpoint)
    }

    public func process(
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

    public func process(
        chain: RequestChainProtocol,
        _ result: NetworkResponse,
        for endpoint: NetworkLayerEndpoint
    ) async throws -> NetworkResponse {
        return result
    }

    func adapt(chain: RequestChainProtocol,
               _ request: URLRequest,
               for endpoint: any NetworkLayerEndpoint
    ) async throws -> URLRequest {
        return request
    }
}
