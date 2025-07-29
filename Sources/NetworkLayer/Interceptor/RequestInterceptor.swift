//
//  RequestInterceptor.swift
//  NetworkLayer
//
//  Created by Alex.personal on 15/6/25.
//

import Foundation
import NLCore

public protocol RequestInterceptor: Sendable {
    func adapt(
        _ request: URLRequest,
        for endpoint: any NetworkLayerEndpoint
    ) async throws -> URLRequest

    func process(
        _ result: NetworkResponse,
        for endpoint: NetworkLayerEndpoint
    ) async throws -> NetworkResponse

    func adapt(chain: RequestChainProtocol,
               _ request: URLRequest,
               for endpoint: any NetworkLayerEndpoint
    ) async throws -> URLRequest
}

public extension RequestInterceptor {
    func adapt(
        _ request: URLRequest,
        for endpoint: any NetworkLayerEndpoint
    ) async throws -> URLRequest { request }

    func process(
        _ result: NetworkResponse,
        for endpoint: NetworkLayerEndpoint
    ) async throws -> NetworkResponse {
        result
    }

    func adapt(chain: RequestChainProtocol,
               _ request: URLRequest,
               for endpoint: any NetworkLayerEndpoint
    ) async throws -> URLRequest {
        return request
    }
}
