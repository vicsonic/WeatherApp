//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Victor Soto on 25/02/24.
//

import UIKit

extension WeatherViewConfiguration {
    init(weather: CurrentWeather,
         temperatureFormatter: MeasurementFormatter,
         windFormatter: MeasurementFormatter) {

        let tempMeasurement = Measurement(value: weather.main.temperature, unit: UnitTemperature.celsius)
        let lowTempMeasurement = Measurement(value: weather.main.minTemperature, unit: UnitTemperature.celsius)
        let highTempMeasurement = Measurement(value: weather.main.maxTemperature, unit: UnitTemperature.celsius)

        let windSpeedMeasurement = Measurement(value: weather.wind.speed, unit: UnitSpeed.metersPerSecond)
        let windDegressMeasurement = Measurement(value: weather.wind.degrees, unit: UnitAngle.degrees)

        let temperatureConditions = "Low: \(temperatureFormatter.string(from: lowTempMeasurement))   High: \(temperatureFormatter.string(from: highTempMeasurement))"
        let windConditions = "Wind: \(windFormatter.string(from: windSpeedMeasurement))(\(windFormatter.string(from: windDegressMeasurement)))"

        var icon: URL?
        if let iconName = weather.weather.first?.icon {
            icon = URL(string: "https://openweathermap.org/img/wn/\(iconName)@2x.png")
        }

        self.init(name: weather.name,
                  icon: icon,
                  temperature: temperatureFormatter.string(from: tempMeasurement),
                  description: weather.weather.first?.description.capitalized,
                  temperatureConditions: temperatureConditions,
                  windConditions: windConditions)
    }
}

final class WeatherViewModel {
    private enum Constants {
        static let errorMessage = "Something unexpected happened, please try again"
    }

    private let errorViewConfiguration = ErrorViewConfiguration(message: Constants.errorMessage,
                                                                icon: UIImage(systemName: "exclamationmark.triangle"))

    private let apiClient: APIClient
    private var currentWeather: CurrentWeather? {
        didSet {
            guard let currentWeather else {
                onState?(.error(configuration: errorViewConfiguration))
                return
            }
            onState?(.weather(configuration: .init(weather: currentWeather,
                                                   temperatureFormatter: temperatureFormatter,
                                                   windFormatter: windFormatter)))
        }
    }

    private let temperatureFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .temperatureWithoutUnit
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()

    private let windFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .temperatureWithoutUnit
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter
    }()

    var onState: ((WeatherViewState) -> Void)?

    init(apiClient: APIClient = WeatherAPIClient()) {
        self.apiClient = apiClient
    }

    func loadCurrentWeather(latitude: Float, longitude: Float) {
        onState?(.loading)
        Task {
            do {
                let currentWeather = try await apiClient.requestCurrentWeather(latitude: latitude,
                                                                               longitude: longitude)
                self.currentWeather = currentWeather
            } catch {
                onState?(.error(configuration: errorViewConfiguration))
            }
        }
    }
}
