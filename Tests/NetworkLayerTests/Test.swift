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
    let endpoint = MockEndpoint()
    let mockKey = "mockKey"
    let mockValue = "mockValue"
    let interceptor: MockInterceptor
    let sut: RequestInterceptorAdapter

    init() {
        interceptor = MockInterceptor(key: mockKey, value: mockValue)
        sut         = RequestInterceptorAdapter(interceptors: [interceptor])
    }
    @Test func testAdapterAddsHeader() async throws {
        let request = try await sut.adapt(endpoint: endpoint)

        let headers = request.allHTTPHeaderFields
        #expect(headers?[mockKey] as? String ==  mockValue)
    }

//    @Test func testAdapterProcessRequest() async throws {
//        let url = try #require(endpoint.asURLRequest?.url)
//        let result = (
//            Data(),
//            URLResponse(
//                url: url,
//                mimeType: nil ,
//                expectedContentLength: 100,
//                textEncodingName: nil
//            )
//        )
//
//        let updatedResult = try await interceptor.process(.success(result), for: endpoint)
//        let sut = RequestInterceptorAdapter(interceptors: [interceptor])
//    }
}

internal struct MockInterceptor: RequestInterceptor {
    let key: String?
    let value: String?
    func adapt( _ request: URLRequest, for endpoint: any NetworkLayerEndpoint) async throws -> URLRequest {
        guard let key = key, let value = value else { return request }
        var mutableRequest = request
        mutableRequest.addValue(value, forHTTPHeaderField: key)
        return mutableRequest
    }

    public func process(
        _ result: Result<(Data, URLResponse), Error>,
        for endpoint: any NetworkLayerEndpoint
    ) async throws -> Result<(Data, URLResponse), Error> {

        switch result {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            return .failure(failure)
        }
    }
}
