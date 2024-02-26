//
//  ErrorView.swift
//  WeatherApp
//
//  Created by Victor Soto on 25/02/24.
//

import UIKit
import SnapKit

typealias ErrorViewConfiguration = ErrorView.Configuration

final class ErrorView: UIView {

    struct Configuration {
        let message: String
        let icon: UIImage?
        let actionTitle: String
    }

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.spacing = 15
        return view
    }()

    private let icon: UIImageView = {
        let view = UIImageView()
        view.tintColor = .systemGray3
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(for: .headline, weight: .medium)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()

    private let actionButton: UIButton = {
        var configuration = UIButton.Configuration.borderedProminent()
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
        let button = UIButton(configuration: configuration)
        button.titleLabel?.font = .preferredFont(for: .callout, weight: .medium)
        return button
    }()

    var onButtonTapEvent: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSelf()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ErrorView {
    func setupSelf() {
        setupHierarchy()
        setupLayout()
    }

    func setupHierarchy() {
        addSubview(stackView)
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(actionButton)
    }

    func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
        }
        icon.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(icon.snp.width)
        }
        actionButton.snp.makeConstraints { make in
            make.height.equalTo(33)
        }
    }
}

extension ErrorView {
    func update(configuration: ErrorViewConfiguration) {
        messageLabel.text = configuration.message
        icon.image = configuration.icon
        actionButton.setTitle(configuration.actionTitle, for: .normal)
        actionButton.addAction(UIAction(handler: { [weak self] action in
            self?.onButtonTapEvent?()
        }), for: .touchUpInside)
    }
}
