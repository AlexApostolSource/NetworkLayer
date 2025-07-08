//
//  RetryConfiguration+Extensions.swift
//  NetworkLayer
//
//  Created by Alex.personal on 7/7/25.
//
import Foundation
import NetworkLayer

public extension RetryConfiguration {

    /// Returns the standard retry configuration used across the SDK.
    static func asMock(
        maxAttempts: Int = 3,
        baseDelay: Duration = .milliseconds(50),
        maxDelay: Duration = .seconds(0.5),
        exponentialFactor: Double = 2.0,
        jitter: Duration = .milliseconds(100),
        retryableStatusCodes: Set<Int> = Set(500...599).union([408, 429]),
        retryableURLErrors: [URLError.Code] = [
            .timedOut, .cannotFindHost, .networkConnectionLost,
            .cannotConnectToHost, .dnsLookupFailed
        ],
        retryableMethods: [URLRequestMethod] = [.DELETE, .GET, .HEAD, .POST, .PUT, .PATCH]
    ) -> RetryConfiguration {

        RetryConfiguration(
            maxAttempts: maxAttempts,
            baseDelay: baseDelay,
            maxDelay: maxDelay,
            exponentialFactor: exponentialFactor,
            jitter: jitter,
            retryableStatusCodes: retryableStatusCodes,
            retryableURLErrors: retryableURLErrors,
            retryableMethods: retryableMethods
        )
    }
}
