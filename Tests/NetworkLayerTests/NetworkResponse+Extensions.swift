//
//  NetworkResponse+Extensions.swift
//  NetworkLayer
//
//  Created by Alex.personal on 7/7/25.
//
import Foundation
import NLCore
public extension NetworkResponse {
     static func asMock(
        data: Data = Data(),
        response: URLResponse = URLResponse(),
        result: Result<Void, NetworkError> = .success(()),
        statusCode: Int? = nil
    ) -> NetworkResponse {
        NetworkResponse(
            data: data,
            response: response,
            result: result,
            statusCode: statusCode ?? (response as? HTTPURLResponse)?.statusCode ?? 200
        )
    }
}
