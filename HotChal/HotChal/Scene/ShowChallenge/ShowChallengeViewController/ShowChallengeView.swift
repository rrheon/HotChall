import UIKit

final class ShowChallengeView: UIView {

  let videoBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .appCharcoal
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 15)
    label.textColor = .black
    label.numberOfLines = 1
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let uploaderLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 10)
    label.textColor = .black
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let labelStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 5
    stackView.alignment = .leading
    stackView.distribution = .fillProportionally
    stackView.backgroundColor = .appPink.withAlphaComponent(0.8)
    stackView.layer.cornerRadius = 8
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  let buttonStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.alignment = .fill
    stackView.spacing = 10
    stackView.backgroundColor = .backgroundColor.withAlphaComponent(0.8)
    stackView.layer.cornerRadius = 8
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  let learnChallengeButton: UIButton = ChallengeButton(type: .learnChallenge)
  let saveChallengeButton: UIButton = ChallengeButton(type: .saveChallenge)
  let takeChallengeButton: UIButton = ChallengeButton(type: .takeChallenge)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    
    [videoBackgroundView, labelStackView, buttonStackView]
      .forEach { addSubview($0) }
    
    // Add buttons to stack
    [saveChallengeButton, learnChallengeButton, takeChallengeButton]
      .forEach { buttonStackView.addArrangedSubview($0) }
    
    [titleLabel, uploaderLabel]
      .forEach { labelStackView.addArrangedSubview($0) }
    
    NSLayoutConstraint.activate([
      videoBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 50),
      videoBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
      videoBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
      videoBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 50),
      
      buttonStackView.centerYAnchor.constraint(equalTo: videoBackgroundView.centerYAnchor),
      buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
      
      labelStackView.topAnchor.constraint(equalTo: videoBackgroundView.bottomAnchor, constant: -150),
      labelStackView.leadingAnchor.constraint(equalTo: videoBackgroundView.leadingAnchor, constant: 10),
      labelStackView.trailingAnchor.constraint(equalTo: videoBackgroundView.trailingAnchor, constant: -10),
    ])
  }
  
  func configure(title: String?, uploader: String?) {
    titleLabel.text = title
    uploaderLabel.text = uploader
  }
}
