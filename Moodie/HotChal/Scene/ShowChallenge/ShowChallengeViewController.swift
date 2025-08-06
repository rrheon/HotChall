//
//  ShowChallengeViewController.swift
//  HotChal
//
//  Created by 최용헌 on 8/5/25.
//

import UIKit
import AVFoundation
import AVKit


/// HotChall - front - ShowChallengeViewController
/// 챌린지 보기 화면
final class ShowChallengeViewController: UIViewController {
    
  var challengeData: ChallengeVideo? {
    didSet{
      guard let data = challengeData else { return }
      configure(with: data)
      setupChallengePlayer(withAssetName: data.videoFilename ?? "")
    }
  }
  
  private var videoBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .appCharcoal
    return view
  }()
  
  var player: AVPlayer = AVPlayer()
  private var playerLayer: AVPlayerLayer?
  
  /// 챌린지 제목 라벨
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 15)
    label.textColor = .black
    label.numberOfLines = 1
    label.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    
    return label
  }()
  
  /// 챌린지 업로더 라벨
  private let uploaderLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 10)
    label.textColor = .black
    
    return label
  }()
  
  
  /// 챌린지 관련 버튼 스택뷰
  lazy var buttonStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.alignment = .fill
    stackView.spacing = 10
    
    return stackView
  }()
  
  /// 챌린지 배우기 버튼
  private lazy var learnChallengeButton: UIButton = makeChallengeButton(title: "배우기",
                                                                        imageName: "figure.dance")
  
  /// 챌린지 저장하기 버튼
  private lazy var saveChallengeButton: UIButton = makeChallengeButton(title: "즐겨찾기",
                                                               imageName: "star")
  /// 챌린지 촬영하기하기 버튼
  private lazy var takeChallengeButton: UIButton = makeChallengeButton(title: "찍어보기",
                                                               imageName: "camera.shutter.button")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.prefersLargeTitles = false
    
    setupLayout()
    addButtonActions()
    setupVideoTapGesture()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    player.play()

  }
  override func viewDidDisappear(_ animated: Bool) {
    player.pause()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    playerLayer?.frame = videoBackgroundView.bounds
  }
  
  /// Layout 설정
  private func setupLayout(){
    [saveChallengeButton, learnChallengeButton, takeChallengeButton]
      .forEach { buttonStackView.addArrangedSubview($0) }
    
    buttonStackView.translatesAutoresizingMaskIntoConstraints = false
    videoBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(videoBackgroundView)
    view.addSubview(buttonStackView)
    
    NSLayoutConstraint.activate([
      videoBackgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
      videoBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      videoBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      videoBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50),
      
      buttonStackView.centerYAnchor.constraint(equalTo: videoBackgroundView.centerYAnchor),
      buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
    ])
  }
  
  /// 챌린지 플레이어 셋팅
  private func setupChallengePlayer(withAssetName name: String) {
    guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
      print("❌ 로컬 비디오 파일을 찾을 수 없습니다.")
      return
    }
    
    let item = AVPlayerItem(url: url)
    self.player.replaceCurrentItem(with: item)
    
    let playerLayer = AVPlayerLayer(player: self.player)
    playerLayer.frame = self.videoBackgroundView.bounds
    playerLayer.videoGravity = .resize
    
    self.playerLayer = playerLayer
    self.videoBackgroundView.layer.addSublayer(playerLayer)
  }
  
  
  /// 버튼 액션 설정
  private func addButtonActions() {
    saveChallengeButton.addAction(UIAction { [weak self] _ in
      guard let self = self, let data = self.challengeData else { return }
      print(#fileID, #function, #line, "- 탭")

    }, for: .touchUpInside)
    
    learnChallengeButton.addAction(UIAction { [weak self] _ in
      guard let self = self, let data = self.challengeData else { return }
      print(#fileID, #function, #line, "- 탭")    }, for: .touchUpInside)
    
    takeChallengeButton.addAction(UIAction { [weak self] _ in
      guard let self = self, let data = self.challengeData else { return }
      print(#fileID, #function, #line, "- 탭")    }, for: .touchUpInside)
  }
  
  
  /// 챌린지 영상 일시정지 / 재생을 위해 재스처 달기
  private func setupVideoTapGesture() {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap))
      videoBackgroundView.isUserInteractionEnabled = true
      videoBackgroundView.addGestureRecognizer(tapGesture)
  }
  
  /// 챌린지 영상 일시정지 / 재생
  @objc private func handleVideoTap() {
      if player.timeControlStatus == .playing {
          player.pause()
      } else {
          player.play()
      }
  }

  /// 데이터 설정
  private func configure(with item: ChallengeVideo) {
    titleLabel.text = item.title
    uploaderLabel.text = item.uploader
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
  
}
