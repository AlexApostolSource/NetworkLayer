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
        let mockInterceptor = MockRequestInterceptor()
        let mockAdapter = MockRequestInterceptorAdapter(interceptors: [mockInterceptor])
        let sut = makeSUT(mockNL: nlMock, interceptor: mockAdapter)

        let _: MockResult = try await sut.execute(endpoint: MockEndpoint())

        #expect(mockAdapter.callOrder == [.adapt, .process])
    }

    @Test() func testRequestProviderOnDecodingErrorLogsError() async throws {
        let mockResult = Data()
        let nlMock = try makeMockNL(data: mockResult)
        let logger = MockNetworkLogger()
        let sut = makeSUT(mockNL: nlMock, logger: logger)

        do {
            let _: MockResult = try await sut.execute(endpoint: MockEndpoint())
            #expect(Bool(false), "Error expected but not thrown.")
        } catch let error as NetworkLayerError {
            switch error {
            case .decodingFailed:
                #expect(logger.logCallCount == 1, "Logger should log the error.")
            default:
                #expect(Bool(false), "Unexpected error type thrown: \(error)")
            }
        } catch {
            #expect(Bool(false), "Unexpected error type thrown: \(error)")
        }
    }

    @Test() func testRequestProviderOnUnknownErrorLogsError() async throws {
        let mockResult = Data()
        let error = MockError.network
        let nlMock = try makeMockNL(data: mockResult)
        nlMock.error = NetworkLayerError.unknown(error: error)
        let logger = MockNetworkLogger()
        let sut = makeSUT(mockNL: nlMock, logger: logger)

        do {
            let _: MockResult = try await sut.execute(endpoint: MockEndpoint())
            #expect(Bool(false), "Error expected but not thrown.")
        } catch let error as NetworkLayerError {
            switch error {
            case .decodingFailed:
                #expect(Bool(false), "Unexpected error type thrown: \(error)")
            default:
                #expect(logger.logCallCount == 1, "Logger should log the error.")
            }
        } catch {
            #expect(Bool(false), "Unexpected error type thrown: \(error)")
        }
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

    private func makeMockNL(data: Codable = Data()) throws -> MockNetworkLayerCore {
        let mockData = try JSONEncoder().encode(data)
        let mockResponse = NetworkResponse.asMock(data: mockData)
        let nlMock = MockNetworkLayerCore(response: mockResponse)
        return nlMock
    }
}

struct MockResult: Codable {
    let value: String
}

enum MockError: Error {
    case decoding
    case network
}
