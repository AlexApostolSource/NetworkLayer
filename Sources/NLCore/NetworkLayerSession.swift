//
//  NetworkSession.swift
//  NetworkLayer
//
//  Created by Alex.personal on 13/7/25.
//
import Foundation

public protocol NetworkLayerSession: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkLayerSession {}
