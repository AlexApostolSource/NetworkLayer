//
//  Test.swift
//  NetworkLayer
//
//  Created by Alex.personal on 22/6/25.
//

import Foundation
import Testing

@testable import NetworkLayer

struct RequestInterceptorTests {
    let endpoint = MockEndpoint()
    let mockKey = "mockKey"
    let mockValue = "mockValue"
    private var interceptor: MockInterceptor
    let sut: RequestInterceptorAdapter

    init() {
        interceptor = MockInterceptor(key: mockKey, value: mockValue)
        sut = RequestInterceptorAdapter(interceptors: [interceptor])
    }

    @Test func adapterAddsHeader() async throws {
        let request = try await sut.adapt(endpoint: endpoint)

        let headers = request.allHTTPHeaderFields
        #expect(headers?[mockKey] as? String == mockValue)
    }

    @Test("") func testAdapterProcessRequest() async throws {
        // Given
        let url = try #require(endpoint.asURLRequest?.url)
        let initialMockValue = "Initial Value"
        let modifiedValue = "Modified Value"
        let data = try JSONEncoder().encode(MockData(value: initialMockValue))

        let result = (
            data,
            URLResponse(
                url: url,
                mimeType: nil,
                expectedContentLength: 100,
                textEncodingName: nil
            )
        )

        var interceptor = MockInterceptor(key: mockKey, value: mockValue)

        interceptor.manipulateData = { data in
            let mockData = try? JSONDecoder().decode(MockData.self, from: data)
            #expect(mockData?.value == initialMockValue)

            let mockDataModified = try? JSONEncoder().encode(
                MockData(value: modifiedValue)
            )
            return  mockDataModified ?? Data()
        }

        let sut = RequestInterceptorAdapter(interceptors: [interceptor])

        // When
        let updatedResult = try await sut.process(.success(result), for: endpoint)

        let dataResult = try #require(updatedResult.get().0)
        let decodedData = try JSONDecoder().decode(MockData.self, from: dataResult)

        // Then
        #expect(decodedData.value == modifiedValue)

    }
}

private struct MockInterceptor: @unchecked Sendable, RequestInterceptor {
    let key: String?
    let value: String?
    var manipulateData: ((Data) -> Data)?
    var manipulateError: ((Error) -> Error)?
    func adapt(_ request: URLRequest, for endpoint: any NetworkLayerEndpoint)
        async throws -> URLRequest {
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
        case .success(let (data, response)):
            if let manipulateData = manipulateData {
                return .success((manipulateData(data), response))
            }
            return .success((data, response))
        case .failure(let error):
            if let manipulateError = manipulateError {
                return .failure(manipulateError(error))
            }
            return .failure(error)
        }
    }
}

private struct MockData: Codable {
    let value: String
}
