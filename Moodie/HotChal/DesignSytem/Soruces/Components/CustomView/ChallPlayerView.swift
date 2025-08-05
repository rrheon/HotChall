//
//  ChallPlayerView.swift
//  HotChal
//
//  Created by 최용헌 on 7/31/25.
//

import UIKit


/// 플레이어 액션 Delegate
protocol ChallengePlayerViewDelegate: AnyObject {
  func navToLearnChallenge(with data: ChallengeVideo)
  func navToShowChallenge(with data: ChallengeVideo)
  func navToTakeChallenge(with data: ChallengeVideo)
  func saveChallenge(with data: ChallengeVideo)
  func closePlayerUI()
}

extension ChallengePlayerViewDelegate {
  func closePlayerUI(){
    ChallengePlayerUIManager.shared.closeChallPlayer()
  }
}

/// 챌린지 영상 플레이어 UIView
final class ChallPlayerView: UIView {
  
  weak var delegate: ChallengePlayerViewDelegate?
  
  var challengeData: ChallengeVideo?
  
  /// 챌린지 배우기 버튼
  private lazy var learnChallengeButton: UIButton = makeChallengeButton(title: "배우기",
                                                                        imageName: "figure.dance")
  
  /// 챌린지 저장하기 버튼
  lazy var saveChallengeButton: UIButton = makeChallengeButton(title: "즐겨찾기",
                                                               imageName: "star")
  /// 챌린지 촬영하기하기 버튼
  lazy var takeChallengeButton: UIButton = makeChallengeButton(title: "찍어보기",
                                                               imageName: "camera.shutter.button")
  /// 챌린지 보기 버튼
  private lazy var showChallengeButton: UIButton = makeChallengeButton(title: "보기",
                                                                       imageName: "play.rectangle")
  
  
  /// 플레이어 view 내리기 버튼
  private let closePlayerButton: UIButton = {
    let button = UIButton(configuration: UIButton.Configuration.plain())
    button.setTitleColor(.black, for: .normal)
    button.setImage(UIImage(systemName: "xmark"), for: .normal)
    button.tintColor = .black
    
    return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .appPink
    
    setupLayout()
    setupButtonActions()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  /// UI 설정
  private func setupLayout(){
    let views: [UIView] = [
      learnChallengeButton,
      saveChallengeButton,
      takeChallengeButton,
      showChallengeButton,
      closePlayerButton
    ]
    
    let buttonStackView: UIStackView = UIStackView(arrangedSubviews: views)
    
    buttonStackView.axis = .horizontal
    buttonStackView.distribution = .fillProportionally
    buttonStackView.alignment = .fill
    
    self.addSubview(buttonStackView)
    buttonStackView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      buttonStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
      buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
      buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
      buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
    ])
  }
  
  
  /// 버튼의 액션 설정
  private func setupButtonActions(){
    guard let mockupData = MockupDataManager.shared.challengeVideos.first else { return }
    
    learnChallengeButton.addAction(UIAction { [weak self] _ in
      guard let self = self else { return }
      self.delegate?.navToLearnChallenge(with: self.challengeData ?? mockupData)
    }, for: .touchUpInside)
    
    saveChallengeButton.addAction(UIAction { [weak self] _ in
      guard let self = self else { return }
      self.delegate?.saveChallenge(with: self.challengeData ?? mockupData)
    }, for: .touchUpInside)
    
    takeChallengeButton.addAction(UIAction { [weak self] _ in
      guard let self = self else { return }
      self.delegate?.navToTakeChallenge(with: self.challengeData ?? mockupData)
    }, for: .touchUpInside)
    
    showChallengeButton.addAction(UIAction { [weak self] _ in
      guard let self = self else { return }
      self.delegate?.navToShowChallenge(with: self.challengeData ?? mockupData)
    }, for: .touchUpInside)
    
    closePlayerButton.addAction(UIAction { [weak self] _ in
      guard let self = self else { return }
      self.delegate?.closePlayerUI()
    }, for: .touchUpInside)
  }
  
  
  /// 플레이어 버튼 만들기
  private func makeChallengeButton(title: String, imageName: String) -> UIButton {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(systemName: imageName)
    config.imagePadding = 10
    config.baseForegroundColor = .black
    
    // 이미지 크기 줄이기
    let imageSize = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
    config.preferredSymbolConfigurationForImage = imageSize
    
    // 텍스트 크기 줄이기
    let font = UIFont.systemFont(ofSize: 14)
    let attributes: [NSAttributedString.Key: Any] = [ .font: font ]
    config.attributedTitle = AttributedString(NSAttributedString(string: title, attributes: attributes))
    
    let button = UIButton(configuration: config)
    button.semanticContentAttribute = .forceRightToLeft
    button.configuration?.imagePlacement = .top
    button.configuration?.imagePadding = 10
    button.tintColor = .white
    
    return button
  }
  
  
  /// 버튼 타이틀 변경  - 저장하기 / 삭제하기
  /// - Parameter title: 변경할 타이틀
  func changeButtonTitle(title: String){
    let font = UIFont.systemFont(ofSize: 14)
    let attributes: [NSAttributedString.Key: Any] = [.font: font]
    let newTitle = NSAttributedString(string: title, attributes: attributes)
    saveChallengeButton.configuration?.attributedTitle = AttributedString(newTitle)

  }
  
}
