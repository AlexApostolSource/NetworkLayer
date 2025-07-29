//
//  MockNetworkLayerDecoder.swift
//  NetworkLayer
//
//  Created by Alex.personal on 10/7/25.
//

import Foundation
import NetworkLayer

class MockNetworkLayerDecoder: NetworkLayerDecoder {
    var decodingCallCount = 0
    var error: Error?

    func attemptDecode<T>(type: T.Type, from: Data) throws -> T where T: Decodable {
        if let error = error {
            throw error
        }
        return try JSONDecoder().decode(T.self, from: from)
    }
}
