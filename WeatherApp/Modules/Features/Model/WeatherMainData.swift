//
//  WeatherMainData.swift
//  WeatherApp
//
//  Created by Victor Soto on 24/02/24.
//

import Foundation

struct WeatherMainData: Decodable {
    let temperature: Float
    let feelsLike: Float
    let maxTemperature: Float
    let minTemperature: Float
    let pressure: Int
    let humidity: Int
    let seaLevel: Int
    let groundLevel: Int

    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLike = "feels_like"
        case maxTemperature = "temp_max"
        case minTemperature = "temp_min"
        case pressure
        case humidity
        case seaLevel = "sea_level"
        case groundLevel = "grnd_level"
    }
}
