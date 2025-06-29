//
//  RequestInterceptor.swift
//  NetworkLayer
//
//  Created by Alex.personal on 15/6/25.
//

import Foundation

public protocol RequestInterceptor: Sendable {
    func adapt(
        _ request: URLRequest,
        for endpoint: any NetworkLayerEndpoint
    ) async throws -> URLRequest

    func process

    (
        _ result: Result<(Data, URLResponse), Error>,
        for endpoint: any NetworkLayerEndpoint
    ) async throws -> Result<(Data, URLResponse), Error>
}

public extension RequestInterceptor {
    func adapt(
        _ request: URLRequest,
        for endpoint: any NetworkLayerEndpoint
    ) async throws -> URLRequest { request }

    func process(
        _ result: Result<(Data, URLResponse), Error>,
        for endpoint: any NetworkLayerEndpoint
    ) async throws -> Result<(Data, URLResponse), Error> { result }
}
