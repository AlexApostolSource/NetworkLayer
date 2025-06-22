//
//  File.swift
//  NetworkLayer
//
//  Created by Alex.personal on 2/10/24.
//

import Foundation

public protocol NetworkLayerEndpoint {
    var queryItems: [URLQueryItem] { get}
    var path: String { get }
    var method: URLRequestMethod { get }
    var asURLRequest: URLRequest? { get }
    var host: String { get }
    var scheme: String { get }
    var timeout: TimeInterval { get }
    var headers: [String: String]? { get }
    var requiredAuth: Bool { get }
}

extension NetworkLayerEndpoint {
    var host: String {
        NetworkLayerConfig.host
    }

    var timeout: TimeInterval {
        60
    }

    var scheme: String {
        "https"
    }

    var requiredAuth: Bool { false }
    var headers: [String: String]? { nil }

    var asURLRequest: URLRequest? {
        var urlComponent = URLComponents()
        urlComponent.host = host
        urlComponent.path = path
        urlComponent.queryItems = queryItems
        urlComponent.scheme = scheme

        guard let url = urlComponent.url else { return nil }
        var  request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeout
        if let headers {
            headers.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        return request
    }
}

public enum URLRequestMethod: String {
    case GET
    case POST
    case PUT
}
