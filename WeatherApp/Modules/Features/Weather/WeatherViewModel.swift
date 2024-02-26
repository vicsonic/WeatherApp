//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Victor Soto on 25/02/24.
//

import UIKit
import CoreLocation

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

enum ViewModelError: Error {
    case `default`
    case location
}

final class WeatherViewModel: NSObject {
    private enum Constants {
        static let errorMessage = "Something unexpected happened, please try again"
        static let locationErrorMessage = "Please provide access to your location to provide current weather information"
    }

    private let errorViewConfiguration = ErrorViewConfiguration(message: Constants.errorMessage,
                                                                icon: UIImage(systemName: "exclamationmark.triangle"),
                                                                actionTitle: "Retry")

    private let locationErrorViewConfiguration = ErrorViewConfiguration(message: Constants.locationErrorMessage,
                                                                       icon: UIImage(systemName: "location"),
                                                                       actionTitle: "Enable")

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

    var lastLocation: CLLocation? {
        didSet {
            guard let lastLocation else {
                onState?(.error(configuration: locationErrorViewConfiguration))
                return
            }
            loadCurrentWeather(location: lastLocation)
        }
    }

    private let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()

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

    var isLocationAccessEnabled: Bool {
        switch locationManager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        @unknown default:
            return false
        }
    }

    init(apiClient: APIClient = WeatherAPIClient()) {
        self.apiClient = apiClient
        super.init()
        locationManager.delegate = self
    }

    func loadCurrentWeather() {
        onState?(.loading)
        locationManager.startUpdatingLocation()
    }
}

private extension WeatherViewModel {
    func loadCurrentWeather(location: CLLocation) {
        Task {
            do {
                let currentWeather = try await apiClient.requestCurrentWeather(latitude: location.coordinate.latitude,
                                                                               longitude: location.coordinate.longitude)
                self.currentWeather = currentWeather
            } catch {
                onState?(.error(configuration: errorViewConfiguration))
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension WeatherViewModel: CLLocationManagerDelegate {
    func requestLocationAccess() {
        onState?(.loading)
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            guard let urlGeneral = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            UIApplication.shared.open(urlGeneral)
        case .authorizedAlways, .authorizedWhenInUse:
            loadCurrentWeather()
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            loadCurrentWeather()
        default:
            onState?(.error(configuration: locationErrorViewConfiguration))
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else {
            onState?(.error(configuration: locationErrorViewConfiguration))
            return
        }
        self.lastLocation = userLocation
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onState?(.error(configuration: locationErrorViewConfiguration))
    }
}
