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
    
  weak var delegate: ChallengeNavigationDelegate?
  
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
    stackView.backgroundColor = .backgroundColor.withAlphaComponent(0.8)
    stackView.layer.cornerRadius = 8
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    return stackView
  }()
  
  /// 챌린지 배우기 버튼
 private lazy var learnChallengeButton: UIButton = ChallengeButton(type: .learnChallenge)
  
  /// 챌린지 저장하기 버튼
    private lazy var saveChallengeButton: UIButton = ChallengeButton(type: .saveChallenge)
  /// 챌린지 촬영하기하기 버튼
    private lazy var takeChallengeButton: UIButton = ChallengeButton(type: .takeChallenge)
  
  
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
    player.seek(to: .zero)
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
    print(name)
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
      guard let self = self,
            let data = self.challengeData else { return }
      CoreDataManager.shared.saveChallenge(with: data) { result in
//        ChallengePlayerUIManager.shared.closeChallPlayer()
        let comment = result ? "챌린지가 저장되었습니다." : "이미 저장된 챌린지입니다."
        
        ToastPopupManager.shared.showToast(message: comment, from: self)
      }
    }, for: .touchUpInside)
    
    learnChallengeButton.addAction(UIAction { [weak self] _ in
      guard let self = self,
            let data = self.challengeData else { return }
      delegate?.navToLearnChallengeViewController(with: data)
    
    }, for: .touchUpInside)
    
    takeChallengeButton.addAction(UIAction { [weak self] _ in
      guard let self = self,
            let data = self.challengeData else { return }
      delegate?.navToTakeChallengeViewController(audioFileName: data.mp4FilenameWithoutExtension ?? "")
    }, for: .touchUpInside)
  }
  
  
  /// 챌린지 영상 일시정지 / 재생을 위해 재스처 달기
  private func setupVideoTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap))
    videoBackgroundView.isUserInteractionEnabled = true
    videoBackgroundView.addGestureRecognizer(tapGesture)
  }
  
  /// 챌린지 영상 일시정지 / 재생
  @objc private func handleVideoTap() {
    let imageView: UIImageView = UIImageView()
    imageView.tintColor = .appPink
    
    if player.timeControlStatus == .playing {
      imageView.image = UIImage(systemName: "pause.fill")
      player.pause()
    } else {
      imageView.image = UIImage(systemName: "play.fill")
      player.play()
    }
    
    guard let keyWindow = getKeyWindow() else { return }
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    keyWindow.addSubview(imageView)
    
    NSLayoutConstraint.activate([
      imageView.centerXAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.centerYAnchor),
      imageView.heightAnchor.constraint(equalToConstant: 56),
      imageView.widthAnchor.constraint(equalToConstant: 56)
    ])
    
    UIView.animate(withDuration: 1.0, delay: 0.3, options: .curveEaseOut, animations: {
      imageView.alpha = 0.0
    }, completion: { _ in
      imageView.removeFromSuperview()
    })
  }

  /// 데이터 설정
  private func configure(with item: ChallengeVideo) {
    titleLabel.text = item.title
    uploaderLabel.text = item.uploader
  }
}

// MARK: GetKeyWindow Protocol

extension ShowChallengeViewController: GetKeyWindowProtocol{}
