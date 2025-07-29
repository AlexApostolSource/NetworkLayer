//
//  Test.swift
//  NetworkLayer
//
//  Created by Alex.personal on 12/7/25.
//

import Foundation
import NLCore
import Testing

struct Test {

    @Test(
        "test execute on 200..299 status code range  returnsExpectedResponse",
        arguments: [200, 250, 299]
    ) func testExecuteOnSuccessReturnsExpectedResponse(statusCode: Int) async throws {
        let session = MockNetworkLayerSession()
        let url = try #require(URL(string: "https://example.com"))
        let request = URLRequest(url: url)
        session.data = Data("{\"key\":\"value\"}".utf8)
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        session.urlResponse = response

        let sut = makeSUT(session: session)

        let result = try await sut.execute(request: request)
        #expect(result.data == session.data)
        #expect(result.response as? HTTPURLResponse == session.urlResponse)
        #expect(result.statusCode == response?.statusCode)
        switch result.result {
        case .success:
            #expect(true, "Expected success result")
        case .failure(let failure):
            #expect(Bool(false), "Expected success but got failure: \(failure)")
        }
    }

    @Test(
        "test execute on non 200..299 status code range  returnsExpectedResponse",
        arguments: [301, 199, 404, 500]
    ) func testExecuteOnNon200To299StatusCode(statusCode: Int) async throws {
        let session = MockNetworkLayerSession()
        let url = try #require(URL(string: "https://example.com"))
        let request = URLRequest(url: url)
        session.data = Data("{\"key\":\"value\"}".utf8)
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        session.urlResponse = response

        let sut = makeSUT(session: session)

        let result = try await sut.execute(request: request)
        #expect(result.data == session.data)
        #expect(result.response as? HTTPURLResponse == session.urlResponse)
        #expect(result.statusCode == response?.statusCode)
        switch result.result {
        case .success:
            #expect(Bool(false), "Expected failure result for status code \(statusCode)")
        case .failure(let failure):
            #expect(true, "Expected failure result for status code \(statusCode): \(failure)")
        }
    }

    @Test(
        "test execute urlError throws correct Error")  func testExecuteOnURLError() async throws {
            let session = MockNetworkLayerSession()
            let url = try #require(URL(string: "https://example.com"))
            let request = URLRequest(url: url)
            session.error = URLError(.cancelled)
            let sut = makeSUT(session: session)

            do {
                 _ = try await sut.execute(request: request)
                #expect(Bool(false), "Expected URLError to be thrown")
            } catch let error as NetworkError {
                switch error {
                case .transport(let uRLError):
                    #expect(uRLError.code == .cancelled, "Expected URLError with code .cancelled but got: \(uRLError)")
                default:
                    #expect(Bool(false), "Expected URLError but got: \(error)")
                }
            }
        }

    @Test(
        "test execute unknown throws correct Error")  func testExecuteOnUnknownError() async throws {
            let session = MockNetworkLayerSession()
            let url = try #require(URL(string: "https://example.com"))
            let request = URLRequest(url: url)
            let sut = makeSUT(session: session)

            do {
                _ = try await sut.execute(request: request)
                #expect(Bool(false), "Expected URLError to be thrown")
            } catch let error as NetworkError {
                switch error {
                case .unknown:
                    #expect(true, "Expected unknown error")
                default:
                    #expect(Bool(false), "Expected URLError but got: \(error)")
                }
            }
        }

    private func makeSUT(
        session: MockNetworkLayerSession = MockNetworkLayerSession()
    ) -> NetworkLayerProtocol {
        NetworkLayer(session: session)
    }
}
