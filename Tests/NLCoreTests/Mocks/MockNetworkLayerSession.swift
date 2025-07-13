//
//  MockNetworkLayerSession.swift
//  NetworkLayer
//
//  Created by Alex.personal on 13/7/25.
//

import Foundation
import NLCore

final class MockNetworkLayerSession: NetworkLayerSession, @unchecked Sendable {
    var dataCallCount = 0
    var error: Error?
    var data: Data?
    var urlResponse: URLResponse?
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataCallCount += 1
        if let error = error {
            throw error
        }
       if let data = data, let urlResponse = urlResponse {
           return (data, urlResponse)
       } else {
           throw NSError(
            domain: "MockNetworkLayerSession",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "No data or response provided"]
           )
       }
    }
}
