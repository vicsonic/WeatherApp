//
//  APIResource.swift
//  WeatherApp
//
//  Created by Victor Soto on 24/02/24.
//

import Foundation

enum APIConstants {
    static let baseURL: String = "https://api.openweathermap.org"

    enum Paths: String {
        case weather = "/data/2.5/weather"
    }
}

protocol APIResource {
    var baseURL: String { get }
    var path: String? { get }
    var queryItems: [URLQueryItem] { get set }

    var url: URL? { get }
}

extension APIResource {
    var baseURL: String {
        APIConstants.baseURL
    }

    var url: URL? {
        guard var components: URLComponents = .init(string: baseURL) else { return nil }
        if let path {
            components.path = path
        }
        components.queryItems = queryItems
        return components.url
    }
}

struct WeatherAPIResource: APIResource {
    var path: String? {
        APIConstants.Paths.weather.rawValue
    }

    var queryItems: [URLQueryItem]
}

struct MockAPIResource: APIResource {
    var baseURL: String = ""
    var path: String? = nil
    var queryItems: [URLQueryItem] = []

    var url: URL? {
        Bundle.main.url(forResource: "weather", withExtension: "json")
    }
}

