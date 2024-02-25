//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Victor Soto on 25/02/24.
//

import UIKit
import SnapKit
import Kingfisher

extension UIView {
    func debugBorders(borderColor: UIColor = .red) {
        #if DEBUG
            layer.borderWidth = 1
            layer.borderColor = borderColor.cgColor
        #endif
    }
}

typealias WeatherViewState = WeatherView.State
typealias WeatherViewConfiguration = WeatherView.Configuration

final class WeatherView: UIView {
    enum State {
        case loading
        case weather(configuration: WeatherViewConfiguration)
        case error(configuration: ErrorViewConfiguration)
    }

    struct Configuration {
        let name: String
        let icon: URL?
        let temperature: String
        let description: String?
        let temperatureConditions: String
        let windConditions: String
    }

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.tintColor = .lightGray
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let contentView = UIView()

    private let weatherView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.spacing = 15
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(for: .subheadline, weight: .medium)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()

    private let icon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(for: .largeTitle, weight: .bold)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(for: .body, weight: .medium)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()

    private let temperatureConditionsLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(for: .callout, weight: .medium)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()

    private let windConditionsLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(for: .callout, weight: .medium)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()

    private let errorView = ErrorView()

    var onRetryButtonTapEvent: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSelf()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WeatherView {
    func setupSelf() {
        backgroundColor = .systemBackground
        setupHierarchy()
        setupLayout()
        setupBindings()
    }

    func setupHierarchy() {
        addSubview(contentView)
        addSubview(activityIndicator)
        contentView.addSubview(weatherView)
        contentView.addSubview(errorView)
        weatherView.addArrangedSubview(nameLabel)
        weatherView.addArrangedSubview(icon)
        weatherView.addArrangedSubview(temperatureLabel)
        weatherView.addArrangedSubview(descriptionLabel)
        weatherView.addArrangedSubview(temperatureConditionsLabel)
        weatherView.addArrangedSubview(windConditionsLabel)
        weatherView.isHidden = false
        errorView.isHidden = true
    }

    func setupLayout() {
        contentView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.verticalEdges.equalTo(safeAreaLayoutGuide.snp.verticalEdges)
        }
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        weatherView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
        }
        errorView.snp.makeConstraints { make in
            make.verticalEdges.horizontalEdges.equalToSuperview()
        }
        icon.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.25)
            make.height.equalTo(icon.snp.width)
        }
    }

    func setupBindings() {
        errorView.onButtonTapEvent = { [weak self] in
            self?.onRetryButtonTapEvent?()
        }
    }

    func update(using errorConfiguration: ErrorViewConfiguration) {
        activityIndicator.stopAnimating()
        weatherView.isHidden = true
        errorView.update(configuration: errorConfiguration)
        errorView.isHidden = false
    }

    func update(using configuration: WeatherViewConfiguration) {
        activityIndicator.stopAnimating()
        nameLabel.text = configuration.name
        icon.kf.setImage(with: configuration.icon)
        temperatureLabel.text = configuration.temperature
        descriptionLabel.text = configuration.description
        temperatureConditionsLabel.text = configuration.temperatureConditions
        windConditionsLabel.text = configuration.windConditions
        weatherView.isHidden = false
        errorView.isHidden = true
    }

    func updateToIsLoading() {
        weatherView.isHidden = true
        errorView.isHidden = true
        activityIndicator.startAnimating()
    }
}

extension WeatherView {
    func update(using state: State) {
        DispatchQueue.main.async {
            switch state {
            case .loading:
                self.updateToIsLoading()
            case .weather(let configuration):
                self.update(using: configuration)
            case .error(let configuration):
                self.update(using: configuration)
            }
        }
    }
}
