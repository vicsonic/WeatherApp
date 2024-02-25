//
//  RequestBuilder.swift
//  WeatherApp
//
//  Created by Victor Soto on 24/02/24.
//

import Foundation

protocol RequestBuilding {
    func buildRequest(url: URL,
                      method: HTTPMethod) -> URLRequest
}

final class RequestBuilder: RequestBuilding {
    func buildRequest(url: URL, method: HTTPMethod) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}
