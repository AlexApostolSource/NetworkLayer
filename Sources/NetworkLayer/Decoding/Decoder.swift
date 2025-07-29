//
//  Decoder.swift
//  NetworkLayer
//
//  Created by Alex.personal on 14/6/25.
//
import Foundation

public protocol NetworkLayerDecoder {
    func attemptDecode<T: Decodable>(type: T.Type, from: Data) throws -> T
}

extension JSONDecoder: NetworkLayerDecoder {
    public func attemptDecode<T: Decodable>(type: T.Type, from: Data) throws -> T {
        do {
            return try self.decode(type, from: from)

        } catch {
            throw NetworkLayerError.decodingFailed(error: error, data: from)
        }
    }
}
