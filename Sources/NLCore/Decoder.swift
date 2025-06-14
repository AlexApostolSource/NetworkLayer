//
//  Decoder.swift
//  NetworkLayer
//
//  Created by Alex.personal on 14/6/25.
//
import Foundation

public protocol NetworkLayerDecoder {
    func attemptToDecode<T: Decodable>(type: T.Type, from: Data) throws -> T
}

extension JSONDecoder: NetworkLayerDecoder {
    public func attemptToDecode<T: Decodable>(type: T.Type, from: Data) throws -> T {
        return try self.decode(type, from: from)
    }
}
