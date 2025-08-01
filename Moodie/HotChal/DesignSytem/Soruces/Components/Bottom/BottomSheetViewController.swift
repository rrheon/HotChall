import UIKit

final class BaseBottomSheetViewController: UIViewController {

    var onDismiss: (() -> Void)?
    private let titleText: String
    private let contentView: UIView

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let headerStack = UIStackView()
    private let containerStack = UIStackView()

    // MARK: - Init
    init(title: String, contentView: UIView, onDismiss: (() -> Void)? = nil) {
        self.titleText = title
        self.contentView = contentView
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            if #available(iOS 16.0, *) {
                   let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("customHeight")) { context in
                       return 250
                   }
                   sheet.detents = [customDetent]
                   sheet.selectedDetentIdentifier = customDetent.identifier
               } else {
                   sheet.detents = [.medium()]
               }
            
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    // MARK: - UI Setup
    private func setupLayout() {
        view.backgroundColor = .systemBackground
        
        titleLabel.text = titleText
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .left
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .label
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        closeButton.setContentHuggingPriority(.required, for: .horizontal)
        
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.distribution = .equalSpacing
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(closeButton)
        
        containerStack.axis = .vertical
        containerStack.spacing = 20
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.addArrangedSubview(headerStack)
        containerStack.addArrangedSubview(contentView)
        
        view.addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            containerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerStack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -24),
        ])
    }
    @objc private func closeButtonTapped() {
        dismiss(animated: true) {
            self.onDismiss?()
        }
    }
}
