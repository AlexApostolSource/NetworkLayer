//
//  RetryConfiguration.swift
//  NetworkLayer
//
//  Created by Alex.personal on 1/7/25.
//
import Foundation

public struct RetryConfiguration: Sendable, Equatable {
    public var maxAttempts: Int                // Nº máximo de intentos
    public var baseDelay: Duration             // Retraso inicial
    public var maxDelay: Duration             // Retraso inicial
    public var exponentialFactor: Double       // Factor de back-off
    public var jitter: Duration                // Jitter aleatorio ±
    public var retryableStatusCodes: Set<Int>  // HTTP 429, 500…599 por defecto
    public var retryableURLErrors: [URLError.Code]
    public var retryableMethods: Set<String>

    public static let `default` = RetryConfiguration(
        maxAttempts: 3,
        baseDelay: .milliseconds(500),
        maxDelay: .seconds(30),
        exponentialFactor: 2.0,
        jitter: .milliseconds(100),
        retryableStatusCodes: Set(500...599).union([408, 429]),
        retryableURLErrors: [
            .timedOut, .cannotFindHost, .networkConnectionLost,
            .cannotConnectToHost, .dnsLookupFailed
        ], retryableMethods: ["GET", "HEAD", "PUT", "DELETE"]
    )

    public init(
        maxAttempts: Int,
        baseDelay: Duration,
        maxDelay: Duration,
        exponentialFactor: Double,
        jitter: Duration,
        retryableStatusCodes: Set<Int>,
        retryableURLErrors: [URLError.Code],
        retryableMethods: Set<String>
    ) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.exponentialFactor = exponentialFactor
        self.jitter = jitter
        self.retryableStatusCodes = retryableStatusCodes
        self.retryableURLErrors = retryableURLErrors
        self.retryableMethods = retryableMethods
    }
}
