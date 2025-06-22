//
//  Test.swift
//  NetworkLayer
//
//  Created by Alex.personal on 22/6/25.
//

import Foundation
@testable import NetworkLayer
import Testing

internal struct Test {
    @Test func testAdapterAddsHeader() async throws {
        let endpoint = MockEndpoint()
        let mockKey = "mockKey"
        let mockValue = "mockValue"
        let interceptor = MockInterceptor(key: mockKey, value: mockValue)
        let sut = RequestInterceptorAdapter(interceptors: [interceptor])
        let request = try await sut.adapt(endpoint: endpoint)

        let headers = request.allHTTPHeaderFields
        #expect(headers?[mockKey] as? String ==  mockValue)
    }
    
    @Test func testAdapterProcessRequest() async throws {
        
    }
}

internal struct MockInterceptor: RequestInterceptor {
    let key: String
    let value: String
    func adapt( _ request: URLRequest, for endpoint: any NetworkLayerEndpoint) async throws -> URLRequest {
        var mutableRequest = request
        mutableRequest.addValue(value, forHTTPHeaderField: key)
        return mutableRequest
    }
}
