//
//  MockNetworkLogger.swift
//  NetworkLayer
//
//  Created by Alex.personal on 11/7/25.
//

import NLCore

class MockNetworkLogger: NetworkLayerLogger, @unchecked Sendable {
    var logCallCount = 0
    var logMetadata: NetworkLayerLogMetadata?
    func log(logMetadata: NetworkLayerLogMetadata) {
        logCallCount += 1
        self.logMetadata = logMetadata
    }
}
