//
//  ChallPlayerView.swift
//  HotChal
//
//  Created by 최용헌 on 7/31/25.
//

import UIKit


/// 플레이어 액션 Delegate
protocol PlayerButtonsDelegate: AnyObject {
  func navToLearnChallenge(with data: ChallengeVideo)
  func navToShowChallenge(with data: ChallengeVideo)
  func saveChallenge(with data: ChallengeVideo)
  func closePlayerUI()
}

extension PlayerButtonsDelegate {
  func closePlayerUI(){
    ChallengPlayerUIManager.shared.closeChallPlayer()
  }
}

/// 챌린지 영상 플레이어 UIView
final class ChallPlayerView: UIView {
  
  weak var delegate: PlayerButtonsDelegate?
  
  var challengeData: ChallengeVideo?
  
  /// 챌린지 배우기 버튼
  private lazy var learnChallengeButton: UIButton = makeChallengeButton(title: "챌린지 배우기",
                                                                        imageName: "figure.dance")
  
  /// 챌린지 저장하기 버튼
  private lazy var saveChallengeButton: UIButton = makeChallengeButton(title: "저장하기",
                                                                       imageName: "square.and.arrow.down")
  
  /// 챌린지 보기 버튼
  private lazy var showChallengeButton: UIButton = makeChallengeButton(title: "챌린지 보기",
                                                                       imageName: "play.rectangle")
  
  
  /// 플레이어 view 내리기 버튼
  private let closePlayerButton: UIButton = {
    let button = UIButton(configuration: UIButton.Configuration.plain())
    button.setTitleColor(.black, for: .normal)
    button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
    
    button.tintColor = .white
    
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
    
    let buttonStackView: UIStackView = UIStackView(
      arrangedSubviews: [learnChallengeButton, saveChallengeButton, showChallengeButton, closePlayerButton]
    )
    
    buttonStackView.axis = .horizontal
    buttonStackView.distribution = .fill
    buttonStackView.alignment = .fill
    buttonStackView.spacing = 10
    buttonStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    
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
    let button = UIButton(configuration: .plain())
    button.setTitle(title, for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.setImage(UIImage(systemName: imageName), for: .normal)
    button.configuration?.imagePlacement = .top
    button.configuration?.imagePadding = 10
    button.tintColor = .white
    return button
  }

}
