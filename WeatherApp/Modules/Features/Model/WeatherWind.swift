//
//  WeatherWind.swift
//  WeatherApp
//
//  Created by Victor Soto on 24/02/24.
//

import Foundation

struct WeatherWind: Decodable {
    let speed: Float
    let degrees: Int
    let gust: Float

    enum CodingKeys: String, CodingKey {
        case speed
        case degrees = "deg"
        case gust
    }
}
