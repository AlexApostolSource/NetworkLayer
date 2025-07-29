//
//  MockRequestInterceptorAdapter.swift
//  NetworkLayer
//
//  Created by Alex.personal on 10/7/25.
//

import Foundation
import NetworkLayer
import NLCore

class MockRequestInterceptorAdapter: RequestInterceptorAdapterProtocol, @unchecked Sendable {
     public let interceptors: [RequestInterceptor]
     var callOrder: [MockRequestInterceptorAdapterCallOrder] = []

    init(interceptors: [RequestInterceptor] = []) {
        self.interceptors = interceptors
    }

    func adapt(endpoint: NetworkLayerEndpoint) async throws -> URLRequest {
        callOrder.append(.adapt)
        guard var request = endpoint.asURLRequest else { throw NetworkLayerError.malformedRequest }
        for interceptor in interceptors {
            try Task.checkCancellation()
            request = try await interceptor.adapt(request, for: endpoint)
        }
        return request
    }

    func process(_ result: NetworkResponse, for endpoint: NetworkLayerEndpoint) async throws -> NetworkResponse {
        callOrder.append(.process)
        var current = result
        for interceptor in interceptors.reversed() {
            try Task.checkCancellation()
            current = try await interceptor.process(current, for: endpoint)
        }
        return current
    }
}

enum MockRequestInterceptorAdapterCallOrder: Equatable {
    case adapt
    case process
}
