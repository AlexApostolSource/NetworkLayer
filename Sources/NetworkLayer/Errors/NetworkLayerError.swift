//
//  NetworkLayerErrors.swift
//  NetworkLayer
//
//  Created by Alex.personal on 15/6/25.
//
import Foundation

public enum NetworkLayerError: Error {
    case malformedRequest
    case cannotIdentifyRetryRequest(key: UUID)
    case unknown(error: Error)
}
