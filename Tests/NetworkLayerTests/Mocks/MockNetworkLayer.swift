//
//  MockNetworkLayer.swift
//  NetworkLayer
//
//  Created by Alex.personal on 10/7/25.
//
import Foundation
import NetworkLayer
import NLCore

final actor MockNetworkLayerCore: NetworkLayerProtocol {
    nonisolated(unsafe) var response: NetworkResponse
    nonisolated(unsafe) var error: Error?
    let lock = NSRecursiveLock()
    private var _executeCallCount: Int = 0
    var executeCallCount: Int {
        get {
            defer { lock.unlock() }
            lock.lock()
            return _executeCallCount
        }
        set {
            defer { lock.unlock() }
            lock.lock()
            _executeCallCount = newValue
        }
    }

    init(response: NetworkResponse = NetworkResponse.asMock()) {
        self.response = response
    }

    func execute(request: URLRequest) async throws -> NetworkResponse {
        _executeCallCount += 1
        if let error = error {
            throw error
        }
        return response
    }
}
