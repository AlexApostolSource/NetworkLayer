//
//  MockNetworkLayer.swift
//  NetworkLayer
//
//  Created by Alex.personal on 10/7/25.
//
import Foundation
import NetworkLayer
import NLCore

final class MockNetworkLayerCore: NetworkLayerProtocol {
    var response: NetworkResponse
    var error: Error?
    var executeCallCount = 0

    init(response: NetworkResponse = NetworkResponse.asMock()) {
        self.response = response
    }

    func execute(request: URLRequest) async throws -> NetworkResponse {
        executeCallCount += 1
        if let error = error {
            throw error
        }
        return response
    }
}
