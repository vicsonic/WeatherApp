//
//  RequestPerformer.swift
//  WeatherApp
//
//  Created by Victor Soto on 24/02/24.
//

import Foundation

enum RequestError: Error {
    case taskError(error: Error)
    case invalidData
}

protocol RequestPerforming {
    func perform<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void)
}

final class RequestPerformer: RequestPerforming {
    let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func perform<T>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        urlSession.dataTask(with: request) { data, urlResponse, error in
            if let error {
                completion(.failure(RequestError.taskError(error: error)))
                return
            }
            guard let data else {
                completion(.failure(RequestError.invalidData))
                return
            }
            do {
                let decoder = JSONDecoder()
                let objectDecoded = try decoder.decode(T.self, from: data)
                completion(.success(objectDecoded))
            } catch {
                completion(.failure(RequestError.taskError(error: error)))
            }
        }.resume()
    }
}
