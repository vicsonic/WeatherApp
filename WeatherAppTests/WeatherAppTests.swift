//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Victor Soto on 24/02/24.
//

import XCTest
@testable import WeatherApp

final class WeatherAppTests: XCTestCase {

    var apiClient: APIClient!

    override func setUpWithError() throws {
        apiClient = MockAPIClient()
    }

    override func tearDownWithError() throws {

    }

    func testCurrentWeather() async throws {
        let expectation = expectation(description: "Current Weather Load")
        Task {
            do {
                let weather = try await self.apiClient.requestCurrentWeather(latitude: 34.0194704,
                                                                             longitude: -118.4912273)
                XCTAssertNotNil(weather.main)
                XCTAssertNotNil(weather.name)
                XCTAssertNotNil(weather.wind)
                debugPrint(weather)
                expectation.fulfill()
            } catch {
                throw error
            }
        }
        await fulfillment(of: [expectation])
    }
}
