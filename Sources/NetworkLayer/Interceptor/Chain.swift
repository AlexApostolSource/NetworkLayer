//
//  Chain.swift
//  NetworkLayer
//
//  Created by Alex.personal on 19/7/25.
//

import Foundation

// MARK: - RequestChainProtocol
public protocol RequestChainProtocol: Sendable {
    func proceed(_ request: URLRequest,
                 for endpoint: any NetworkLayerEndpoint) async throws -> URLRequest
}

actor RequestChain: RequestChainProtocol {
    private let interceptors: [RequestInterceptor]
    private var index: Int = 0

    init(interceptors: [RequestInterceptor]) {
        self.interceptors = interceptors
    }

    func proceed(_ request: URLRequest,
                 for endpoint: any NetworkLayerEndpoint) async throws -> URLRequest {
        guard index < interceptors.count else { return request }
        try Task.checkCancellation()
        let current = index
        index += 1
        return try await interceptors[current]
            .adapt(chain: self, request, for: endpoint)
    }
}
