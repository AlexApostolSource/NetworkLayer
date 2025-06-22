//
//  File.swift
//  NetworkLayer
//
//  Created by Alex.personal on 2/10/24.
//

import Foundation

public protocol NetworkLayerCoreProtocol {
    func execute(request: URLRequest) async throws -> Result<(Data, URLResponse), Error>
}

internal final class NetworkLayerCore: NetworkLayerCoreProtocol {
    private let session: URLSession
    private let logger: NetworkLayerLogger?

    init(session: URLSession, logger: NetworkLayerLogger?) {
        self.session = session
        self.logger = logger
    }

    public func execute(request: URLRequest) async throws -> Result<(Data, URLResponse), Error> {
        do {
            let result = try await session.data(for: request)
            return .success(result)
        } catch {
            logger?.log(
                logMetadata: NetworkLayerLogMetadata(
                    logLevel: .error,
                    subsystem: .urlRequestFailing(error)
                )
            )
            return .failure(error)
        }
    }
}
