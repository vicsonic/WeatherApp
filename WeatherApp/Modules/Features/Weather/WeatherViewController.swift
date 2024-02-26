//
//  ViewController.swift
//  WeatherApp
//
//  Created by Victor Soto on 24/02/24.
//

import UIKit

final class WeatherViewController: UIViewController {
    let contentView = WeatherView()
    let viewModel = WeatherViewModel()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSelf()
        loadData()
    }
}

private extension WeatherViewController {
    func setupSelf() {
        setupBindings()
    }

    func setupBindings() {
        viewModel.onState = { [weak self] state in
            self?.contentView.update(using: state)
        }
        contentView.onRetryButtonTapEvent = { [weak self] in
            self?.loadData()
        }
    }

    func loadData() {
        if viewModel.isLocationAccessEnabled {
            viewModel.loadCurrentWeather()
        } else {
            viewModel.requestLocationAccess()
        }
    }
}
