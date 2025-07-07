//
//  Test.swift
//  NetworkLayer
//
//  Created by Alex.personal on 6/7/25.
//

import Foundation
@testable import NetworkLayer
import NLCore
import Testing

struct RetryInterceptorTests {

    @Test(
        "Test_process_with_200StatusCode_shouldNotRetry"
    ) func test_shouldNotRetryVariants() async throws {
        let nlMock = MockNetworkLayerCore()
        let data = Data("Test data".utf8)
        let statusCode = 200
        let url = try #require(URL(string: "https://example.com"))
        let httpResponse = try #require(HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        ))
        let response = NetworkResponse.asMock(
            result: .failure(
                NetworkError.http(
                    data: data,
                    response: httpResponse
                )
            )
        )

        let mockEndpoint = MockEndpoint()

        let sut = makeSUT(networkLayer: nlMock)

        try await _ = sut.process(response, for: mockEndpoint)
        #expect(nlMock.executeCallCount == 0, "Should not retry \(statusCode) statusCode")
    }

    @Test(
        "Test_process_with_403StatusCode_shoulRetryOnce"
    ) func test_shouldRetryVariants() async throws {
        let nlMock = MockNetworkLayerCore()
        let data = Data("Test data".utf8)
        let statusCode = 403
        let url = try #require(URL(string: "https://example.com"))
        let httpResponse = try #require(HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        ))
        let response = NetworkResponse.asMock(
            result: .failure(
                NetworkError.http(
                    data: data,
                    response: httpResponse
                )
            ),
            statusCode: statusCode
        )

        let mockEndpoint = MockEndpoint()

        let config = RetryConfiguration.asMock(
            retryableStatusCodes: [statusCode]
        )

        let sut = makeSUT(config: config, networkLayer: nlMock)

        try await _ = sut.process(response, for: mockEndpoint)
        #expect(nlMock.executeCallCount == 1, "Should retry \(statusCode) statusCode")
    }

    @Test(
        "Test_process_with_URLStatusCode_shouldRetryNTimes on error"
    ) func test_shouldRetryVariantsOnURLError() async throws {
        let nlMock = MockNetworkLayerCore()
        let maxAttempts = 4
        let statusCode = 403
        let response = NetworkResponse.asMock(
            result: .failure(.transport(URLError(.badServerResponse))),
            statusCode: statusCode
        )

        nlMock.error = NetworkError.transport(URLError(.badServerResponse))

        let mockEndpoint = MockEndpoint()

        let config = RetryConfiguration.asMock(
            maxAttempts: maxAttempts,
            retryableStatusCodes: [statusCode],
            retryableURLErrors: [.badServerResponse]

        )

        let sut = makeSUT(config: config, networkLayer: nlMock)
        do {
            try await _ = sut.process(response, for: mockEndpoint)
        } catch {
            #expect(nlMock.executeCallCount == maxAttempts, "Should retry \(statusCode) statusCode for \(maxAttempts) times")
        }
    }

    private func makeSUT(
        config: RetryConfiguration = RetryConfiguration.default,
        networkLayer: NetworkLayerProtocol = MockNetworkLayerCore()
    ) -> RetryInterceptor {
        RetryInterceptor(networkLayer: networkLayer, config: config)
    }

}

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
