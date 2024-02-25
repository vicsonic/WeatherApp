//
//  APIClient.swift
//  WeatherApp
//
//  Created by Victor Soto on 24/02/24.
//

import Foundation

enum APIError: Error {
    case invalidResource
}

protocol APIClient {
    var performer: RequestPerforming { get set }
    func requestCurrentWeather(latitude: Float, longitude: Float) async throws -> CurrentWeather
}

private extension APIClient {
    func requestAPI<T: Decodable>(resource: APIResource, method: HTTPMethod, performer: RequestPerforming) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            guard let url = resource.url else {
                continuation.resume(throwing: APIError.invalidResource)
                return
            }
            let request = RequestBuilder().buildRequest(url: url, method: method)
            performer.perform(request: request) { (result: Result<T, Error>) in
                switch result {
                case .success(let weather):
                    continuation.resume(returning: weather)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

final class WeatherAPIClient: APIClient {
    var performer: RequestPerforming

    init(performer: RequestPerforming = RequestPerformer()) {
        self.performer = performer
    }

    func requestCurrentWeather(latitude: Float, longitude: Float) async throws -> CurrentWeather {
        let resource: WeatherAPIResource = .init(queryItems: [
            .init(name: "lat", value: String(describing: latitude)),
            .init(name: "lon", value: String(describing: longitude)),
            .init(name: "appid", value: "4004cc94b747d2389a9e8a5fe7dc8ca6")
        ])
        let currentWeather: CurrentWeather = try await requestAPI(resource: resource,
                                                                  method: .get,
                                                                  performer: performer)
        return currentWeather
    }
}

final class MockAPIClient: APIClient {
    var performer: RequestPerforming = RequestPerformer()

    func requestCurrentWeather(latitude: Float, longitude: Float) async throws -> CurrentWeather {
        let currentWeather: CurrentWeather = try await requestAPI(resource: MockAPIResource(),
                                                                  method: .get,
                                                                  performer: performer)
        return currentWeather
    }
}
