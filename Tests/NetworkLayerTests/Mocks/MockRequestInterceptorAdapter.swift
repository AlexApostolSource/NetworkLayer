//
//  MockRequestInterceptorAdapter.swift
//  NetworkLayer
//
//  Created by Alex.personal on 10/7/25.
//

import Foundation
import NetworkLayer
import NLCore

struct MockRequestInterceptorAdapter: RequestInterceptorAdapterProtocol {
     public let interceptors: [RequestInterceptor]

    func adapt(endpoint: NetworkLayerEndpoint) async throws -> URLRequest {
        guard var request = endpoint.asURLRequest else { throw NetworkLayerError.malformedRequest }
        for interceptor in interceptors {
            try Task.checkCancellation()
            request = try await interceptor.adapt(request, for: endpoint)
        }
        return request
    }

    func process(_ result: NetworkResponse, for endpoint: NetworkLayerEndpoint) async throws -> NetworkResponse {
        var current = result

        for interceptor in interceptors.reversed() {
            try Task.checkCancellation()
            current = try await interceptor.process(current, for: endpoint)
        }
        return current
    }
}
