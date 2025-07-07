//
//  Test.swift
//  NetworkLayer
//
//  Created by Alex.personal on 22/6/25.
//

import Foundation
@testable import NetworkLayer
import NLCore
import Testing

@Suite
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

    @Test(
        "Adds header for a urlRequest of a given Endpoint",
        .tags(.Interceptor.adapt)
    ) func adapterAddsHeader() async throws {
        let request = try await sut.adapt(endpoint: endpoint)

        let headers = request.allHTTPHeaderFields
        #expect(headers?[mockKey] as? String == mockValue)
    }

    @Test(
        "If no interceptor does not adapt a given Endpoint",
        .tags(.Interceptor.adapt)
    ) func doesNotModifyHeader() async throws {
        let sut = RequestInterceptorAdapter(interceptors: [])
        let request = try await sut.adapt(endpoint: endpoint)

        let headers = try #require(request.allHTTPHeaderFields)
        #expect(headers.isEmpty)
    }

    @Test(
        "If no interceptor does not process a given Endpoint",
        .tags(.Interceptor.adapt)
    ) func doesNotModifySuccess() async throws {
        let url = try #require(endpoint.asURLRequest?.url)
        let initialMockValue = "Initial Value"
        let data = try JSONEncoder().encode(MockData(value: initialMockValue))
        let response =  URLResponse(
            url: url,
            mimeType: nil,
            expectedContentLength: 100,
            textEncodingName: nil
        )
        let sut = RequestInterceptorAdapter(interceptors: [])

        let updatedResult = try await sut.process(
            NetworkResponse.asMock(data: data, response: response),
            for: endpoint
        )
        #expect(updatedResult.data == data)
        #expect(updatedResult.response == response)
    }

    @Test(
        "Processes an success response for a given Endpoint",
        .tags(
            .Interceptor.process
        )
    ) func testAdapterProcessSuccessRequest() async throws {
        // Given
        let url = try #require(endpoint.asURLRequest?.url)
        let initialMockValue = "Initial Value"
        let modifiedValue = "Modified Value"
        let data = try JSONEncoder().encode(MockData(value: initialMockValue))
        let response =  URLResponse(
            url: url,
            mimeType: nil,
            expectedContentLength: 100,
            textEncodingName: nil
        )
        let interceptor = MockInterceptor(key: mockKey, value: mockValue)

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
        let updatedResult = try await sut.process(
            NetworkResponse.asMock(data: data, response: response),
            for: endpoint
        )

        let dataResult = try #require(updatedResult.data)
        let decodedData = try JSONDecoder().decode(MockData.self, from: dataResult)

        // Then
        #expect(decodedData.value == modifiedValue)
    }

    @Test(
        "Processes an failure response does not modify failure if no interceptor for a given Endpoint",
        .tags(.Interceptor.process)
    ) func testProcessDoesNotProcessfailure() async throws {
        // Given

        let sut = RequestInterceptorAdapter(interceptors: [])

        // When
        let result  = try await sut.process(
            NetworkResponse
                .asMock(),
            for: endpoint
        )

        // Then
        if case .failure = result.result {
            #expect(Bool(false), "No interceptor should not modify failure result")
        } else {
            #expect(true, "Expected a failure result")
        }
    }

    @Test(
        "Processes an failure response for a given Endpoint",
        .tags(.Interceptor.process)
    ) func testAdapterProcessFailureRequest() async throws {
        // Given
        let interceptor = MockInterceptor(key: mockKey, value: mockValue)
        let sut = RequestInterceptorAdapter(interceptors: [interceptor])

        // When
        let result = try await sut.process(
            NetworkResponse
                .asMock(result: .failure(.transport(URLError(.badURL)))),
            for: endpoint
        )

        // Then
        if case .failure = result.result {
            #expect(true, "Expected the interceptor to process the failure")
        } else {
            #expect(Bool(false), "Interceptor should process failure result")
        }
    }
}

private final class MockInterceptor: @unchecked Sendable, RequestInterceptor {
    let key: String?
    let value: String?
    var manipulateData: ((Data) -> Data)?
    var manipulateError: ((Error) -> Error)?

    init(
        key: String? = nil,
        value: String? = nil,
        on403Error: Bool = false,
        manipulateData: ( (Data) -> Data)? = nil,
        manipulateError: ( (Error) -> Error)? = nil
    ) {
        self.key = key
        self.value = value
        self.manipulateData = manipulateData
        self.manipulateError = manipulateError
    }

    func adapt(_ request: URLRequest, for endpoint: any NetworkLayerEndpoint)
        async throws -> URLRequest {
        guard let key = key, let value = value else { return request }
        var mutableRequest = request
        mutableRequest.addValue(value, forHTTPHeaderField: key)
        return mutableRequest
    }

    func process(
        _ result: NetworkResponse,
        for endpoint: NetworkLayerEndpoint
    ) async throws -> NetworkResponse {
        switch result.result {
        case .success:
            if let manipulateData = manipulateData {
                let modifiedData = manipulateData(result.data)
                return NetworkResponse.asMock(
                    data: modifiedData,
                    response: result.response,
                    result: .success(()),
                    statusCode: result.statusCode
                )
            }
            return result

        case .failure(let error):
                return NetworkResponse.asMock(
                    data: result.data,
                    response: result.response,
                    result:
                            .failure(
                                error
                            ),
                    statusCode: result.statusCode
                )

        }
    }
}

private struct MockData: Codable {
    let value: String
}
