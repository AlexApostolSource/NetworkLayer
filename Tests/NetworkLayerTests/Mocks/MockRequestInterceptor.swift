//
//  MockRequestInterceptor.swift
//  NetworkLayer
//
//  Created by Alex.personal on 11/7/25.
//
import Foundation
import NetworkLayer
import NLCore

class MockRequestInterceptor: RequestInterceptor, @unchecked Sendable {
    var adaptCallCount = 0
    var processCallCount = 0

    func adapt(
        _ request: URLRequest,
        for endpoint: any NetworkLayerEndpoint
    ) async throws -> URLRequest {
        adaptCallCount += 1
        return request
    }

    func process(
        _ result: NetworkResponse,
        for endpoint: NetworkLayerEndpoint
    ) async throws -> NetworkResponse {
        processCallCount += 1
        return result
    }
}
