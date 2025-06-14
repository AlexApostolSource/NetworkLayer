//
//  File.swift
//  NetworkLayer
//
//  Created by Alex.personal on 2/10/24.
//

import Foundation

protocol NetworkLayerCoreProtocol {
    func execute(request: URLRequest) async throws -> (Data, URLResponse)
}

final class NetworkLayerCore: NetworkLayerCoreProtocol {
    private let session: URLSession
    private let logger: NetworkLayerLogger?
    
    init(session: URLSession, logger: NetworkLayerLogger?) {
        self.session = session
        self.logger = logger
    }
    
    public func execute(request: URLRequest) async throws -> (Data, URLResponse)  {
        do {
            return try await session.data(for: request)
        } catch {
            logger?.log(
                logMetadata: NetworkLayerLogMetadata(
                    logLevel: .error,
                    subsystem: .urlRequestFailing(error)
                )
            )
            throw error
        }
    }
}
