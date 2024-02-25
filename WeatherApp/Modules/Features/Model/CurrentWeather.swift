//
//  CurrentWeather.swift
//  WeatherApp
//
//  Created by Victor Soto on 24/02/24.
//

import Foundation

struct CurrentWeather: Decodable {
    let identifier: Int
    let name: String
    let weather: [WeatherData]
    let main: WeatherMainData
    let wind: WeatherWind

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case weather
        case main
        case wind
    }
}
