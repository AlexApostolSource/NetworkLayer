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

enum NetworkLayerLoggingSubsystem: String {
    case decoding(Error)
    case urlRequestFailing(Error)
}

public struct NetworkLayerLogMetadata {
    let logLevel: LoggingLevel
    let subsystem: NetworkLayerLoggingSubsystem
}
