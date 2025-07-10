//
//  Test.swift
//  NetworkLayer
//
//  Created by Alex.personal on 10/7/25.
//

import Foundation
@testable import NetworkLayer
import NLCore
import Testing

struct RequestProviderTests {

    @Test func testRequestProviderParsesDataCorrectly() async throws {
        let mockResult = MockResult(value: "test")
        let nlMock = try makeMockNL(data: mockResult)
        let sut = makeSUT(mockNL: nlMock)

        let mockResultDecoded: MockResult = try await sut.execute(endpoint: MockEndpoint())

        #expect(mockResultDecoded.value == mockResult.value)
        #expect(nlMock.executeCallCount == 1)
    }

    @Test func testRequestProviderDecodeError() async throws {
        let mockResult = Data()
        let nlMock = try makeMockNL(data: mockResult)
        let sut = makeSUT(mockNL: nlMock)

        do {
            let _: MockResult = try await sut.execute(endpoint: MockEndpoint())
            #expect(Bool(false), "Error expected but not thrown.")
        } catch let error as NetworkLayerError {
            switch error {
            case .decodingFailed:
                #expect(true, "NetworkLayerError thrown as expected.")
            default:
                #expect(Bool(false), "Unexpected error type thrown: \(error)")
            }
        } catch {
            #expect(Bool(false), "Unexpected error type thrown: \(error)")
        }
    }

    @Test func testRequestProviderCallsAdaptAndProcessInRightOrder() async throws {
        let mockResult = MockResult(value: "test")
        let nlMock = try makeMockNL(data: mockResult)
        let sut = makeSUT(mockNL: nlMock)

        let mockResultDecoded: MockResult = try await sut.execute(endpoint: MockEndpoint())

        #expect(mockResultDecoded.value == mockResult.value)
        #expect(nlMock.executeCallCount == 1)
    }

    private func makeSUT(
        mockNL: NetworkLayerProtocol = MockNetworkLayerCore(),
        interceptor: RequestInterceptorAdapterProtocol = MockRequestInterceptorAdapter(
            interceptors: []
        ),
        logger: NetworkLayerLogger? = nil
    ) -> RequestProvider {
        RequestProvider(
            networkLayer: mockNL,
            requestInterceptorAdapter: interceptor,
            logger: logger
        )
    }

    private func makeMockNL(data: Codable) throws -> MockNetworkLayerCore {
        let mockData = try JSONEncoder().encode(data)
        let mockResponse = NetworkResponse.asMock(data: mockData)
        let nlMock = MockNetworkLayerCore(response: mockResponse)
        return nlMock
    }
}

struct MockResult: Codable {
    let value: String
}
