//
//  NetworkLayerCore.swift
//  NetworkLayer
//
//  Created by Alex.personal on 2 Oct 2024.
//
// MARK: Overview
//  -------------
//  `NetworkLayerCore` is the low-level component that actually performs the
//  `URLSession` request.  It **always** returns a `NetworkResponse` container
//  so that callers have access to the raw `Data` and `URLResponse` regardless
//  of whether the HTTP status code is deemed “successful”.
//
//  Why convert non-2xx codes into `.failure`?
//  -----------------------------------------
//  • According to RFC 9110, every status in **200-299** is “Successful”; anything
//    outside that range still arrives via valid TCP/HTTP but usually indicates
//    a business-level error (301, 401, 500…).
//  • `URLSession` throws only on *transport* failures (`URLError`).  Without our
//    own filter a 404 or 500 would reach the upper layers as `.success`, forcing
//    each caller to duplicate status-code validation.
//  • The block below wraps any non-2xx response in
//      `NetworkError.http(data:response:)`,
//    preserving the body and headers so that interceptors, retry policies, or
//    presentation layers can react intelligently.
//

import Foundation

// MARK: - Response & Error Types

/// A single, uniform return type for every request.
///
/// Upper layers can rely on `data` and `response` **always** being present,
/// similar to Alamofire’s `DataResponse`.
public struct NetworkResponse {
    public let data: Data
    public let response: URLResponse
    public let result: Result<Void, NetworkError>
    public let statusCode: Int?

    public init(data: Data, response: URLResponse, result: Result<Void, NetworkError>, statusCode: Int? = nil) {
        self.data = data
        self.response = response
        self.result = result
        self.statusCode = statusCode
    }
}

/// Domain-specific error enumeration that keeps transport and HTTP semantics
/// separate while never discarding the server payload.
public enum NetworkError: Error {
    /// Failure at the transport layer (DNS, TLS handshake, timeout…).
    case transport(URLError)

    /// HTTP status code outside `200…299`.  Includes the raw body so the caller
    /// can parse server-side error objects (e.g. `{ "error": "token_expired" }`).
    case http(data: Data, response: HTTPURLResponse)

    case unknown(Error)
}

// MARK: - Protocol

public protocol NetworkLayerCoreProtocol {
    /// Executes the request and classifies the outcome.
    ///
    /// - Returns: A `NetworkResponse` whose `result` is `.success` for HTTP
    ///            2xx and `.failure` for every other status.
    /// - Throws:  `NetworkError.transport` if the underlying `URLSession`
    ///            raises an `URLError` (no `URLResponse` available).
    func execute(request: URLRequest) async throws -> NetworkResponse
}

// MARK: - Concrete Implementation

final class NetworkLayerCore: NetworkLayerCoreProtocol, Sendable {
    private let session: NetworkLayerSession

    init(session: NetworkLayerSession) {
        self.session = session
    }

    /// Performs the `URLSession` call, maps non-2xx statuses to `.failure`,
    /// and preserves the response for later inspection.
    func execute(request: URLRequest) async throws -> NetworkResponse {
        do {
            let (data, response) = try await session.data(for: request)

            /// If the response is a `HTTPURLResponse`, check the status code.
            /// If it is not in the 2xx range, log it and return a failure.
            if let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode) {
                return NetworkResponse(
                    data: data,
                    response: http,
                    result: .failure(.http(data: data, response: http)),
                    statusCode: http.statusCode
                )
            }

            // Successful transport *and* 2xx status.
            return NetworkResponse(
                data: data,
                response: response,
                result: .success(()),
                statusCode: (response as? HTTPURLResponse)?.statusCode
            )

        } catch let urlError as URLError {
            // Pure transport failure: propagate as `NetworkError.transport`.
            throw NetworkError.transport(urlError)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
