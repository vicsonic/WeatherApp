//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Victor Soto on 24/02/24.
//

import Foundation

struct WeatherData: Decodable {
    let identifier: Int
    let main: String
    let description: String
    let icon: String

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case main
        case description
        case icon
    }
}
