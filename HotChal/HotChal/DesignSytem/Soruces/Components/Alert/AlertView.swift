import UIKit

// MARK: - AlertViewState

struct AlertViewState {
    let title: String
    let message: String?
    let showAlertIcon: Bool
    let buttons: [ButtonState]

    struct ButtonState {
        enum Style {
            case primary
            case secondary
        }

        let title: String
        let style: Style
        let action: () -> Void
    }
}

// MARK: - AlertView
final class AlertView: UIView {
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let buttonStackView = UIStackView()

    // MARK: - Init
    init(state: AlertViewState) {
        super.init(frame: .zero)
        setupUI()
        configure(with: state)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(with state: AlertViewState) {
        iconImageView.isHidden = !state.showAlertIcon
        iconImageView.image = state.showAlertIcon ? UIImage(systemName: "exclamationmark.triangle") : nil
        iconImageView.tintColor = .red
        
        titleLabel.text = state.title
        messageLabel.text = state.message

        buttonStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        state.buttons.forEach { buttonState in
            let button = makeButton(with: buttonState)
            buttonStackView.addArrangedSubview(button)
        }
    }

    func dismiss(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        } else {
            removeFromSuperview()
        }
    }

    // MARK: - Private

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        let contentStack = UIStackView(arrangedSubviews: [
            iconImageView, titleLabel, messageLabel, buttonStackView
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),

            contentStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),

            iconImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    private func makeButton(with state: AlertViewState.ButtonState) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(state.title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true

        switch state.style {
        case .primary:
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .black
        case .secondary:
            button.setTitleColor(.gray, for: .normal)
            button.backgroundColor = .lightGray.withAlphaComponent(0.3)
        }

        button.addAction(UIAction { [weak self] _ in
            state.action()
            self?.dismiss()
        }, for: .touchUpInside)

        return button
    }
}

// MARK: - UIViewController Extension

extension UIViewController {
    func showAlert(state: AlertViewState) {
        let alertView = AlertView(state: state)
        alertView.translatesAutoresizingMaskIntoConstraints = false
        alertView.alpha = 0

        self.view.addSubview(alertView)

        NSLayoutConstraint.activate([
            alertView.topAnchor.constraint(equalTo: view.topAnchor),
            alertView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        UIView.animate(withDuration: 0.25) {
            alertView.alpha = 1
        }
    }
}
