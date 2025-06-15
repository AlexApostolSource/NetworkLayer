//
//  NetworkLayerLogger.swift
//  NetworkLayer
//
//  Created by Alex.personal on 14/6/25.
//

public protocol NetworkLayerLogger {
    func log(logMetadata: NetworkLayerLogMetadata)
}

public enum LoggingLevel: String {
    case warning
    case info
    case error
}

public enum NetworkLayerLoggingSubsystem {
    case decoding(Error)
    case urlRequestFailing(Error)
}

public struct NetworkLayerLogMetadata {
    public let logLevel: LoggingLevel
    public let subsystem: NetworkLayerLoggingSubsystem

    public init(logLevel: LoggingLevel, subsystem: NetworkLayerLoggingSubsystem) {
        self.logLevel = logLevel
        self.subsystem = subsystem
    }
}
