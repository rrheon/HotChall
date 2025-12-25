//
//  ShowChallengeViewController.swift
//  HotChal
//
//  Created by 최용헌 on 8/5/25.
//

import UIKit
import AVFoundation
import AVKit
import ReactorKit


/// HotChall - front - ShowChallengeViewController
/// 챌린지 보기 화면
final class ShowChallengeViewController: UIViewController, View {
  
  weak var delegate: ChallengeNavigationDelegate?
  
  var challengeData: ChallengeVideo? {
    didSet {
      guard let data = challengeData else { return }
      if reactor == nil {
        reactor = ShowChallengeReactor(challenge: data)
      } else {
        reactor?.action.onNext(.setChallenge(data))
      }
      if let filename = data.videoFilename {
        setupChallengePlayer(withAssetName: filename)
      }
    }
  }
  
  private let contentView = ShowChallengeView()
  
  private let playerController = ChallengePlayerController()
  
  var disposeBag = DisposeBag()
  
  var reactor: ShowChallengeReactor? {
    didSet {
      guard let reactor = reactor else { return }
      bind(reactor: reactor)
    }
  }
  
  // MARK: viewDidLoad

  override func viewDidLoad() {
    super.viewDidLoad()
    setupInitialUI()
    
    playerController.setupPlayerLayer(to: contentView.videoBackgroundView)
    
    if reactor == nil { reactor = ShowChallengeReactor(challenge: challengeData) }
    reactor?.action.onNext(.viewDidLoad)
    
    addButtonActions()
    setupVideoTapGesture()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // 레이아웃이 확실히 설정된 후 재생
    playerController.updatePlayerLayerFrame(in: contentView.videoBackgroundView.bounds)
    playerController.play()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    playerController.pause()
    playerController.seekToStart()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // 레이아웃이 변경될 때마다 playerLayer의 frame 업데이트
    playerController.updatePlayerLayerFrame(in: contentView.videoBackgroundView.bounds)
  }
  
  private func setupInitialUI(){
    self.navigationController?.navigationBar.prefersLargeTitles = false
    
    contentView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(contentView)
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: view.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
  }
  
  // MARK: bind

  func bind(reactor: ShowChallengeReactor) {
    // 비디오 재생 상태 바인딩
    reactor.state.map { $0.isPlaying }
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (isPlaying: Bool) in
        guard let self = self else { return }
        if isPlaying {
          self.playerController.play()
        } else {
          self.playerController.pause()
        }
      }).disposed(by: disposeBag)
    
    // UI 업데이트
    reactor.state
      .compactMap { state -> (String, String) in
        let title: String = state.title ?? ""
        let uploader: String = state.uploader ?? ""
        return (title, uploader)
      }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (title: String, uploader: String) in
        self?.contentView.configure(title: title, uploader: uploader)
      })
      .disposed(by: disposeBag)
    
    // 토스트 메시지
    reactor.state.compactMap { $0.toastMessage }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] message in
        guard let self = self else { return }
        ToastPopupManager.shared.showToast(message: message, from: self)
      }).disposed(by: disposeBag)
    
    // 네비게이션 처리
    reactor.state.compactMap { $0.navigation }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] navigation in
        guard let self = self else { return }
        switch navigation {
        case .learn(let data):
          self.delegate?.navToLearnChallengeViewController(with: data)
        case .take(let audio):
          // audio를 subVideoFilename으로도 전달 (원본 영상에서 오디오 추출)
          self.delegate?.navToTakeChallengeViewController(audioFileName: audio, subVideoFilename: audio)
        }
        // 네비게이션 후 리셋
        self.reactor?.action.onNext(.setNavigation(nil))
      }).disposed(by: disposeBag)
  }
  
  /// 챌린지 플레이어 셋팅
  private func setupChallengePlayer(withAssetName name: String) {
    playerController.loadLocalVideo(assetName: name)
  }
  
  /// 버튼 액션 설정
  private func addButtonActions() {
    contentView.saveChallengeButton.addAction(UIAction { [weak self] _ in
      self?.reactor?.action.onNext(.tapSave)
    }, for: .touchUpInside)
    
    contentView.learnChallengeButton.addAction(UIAction { [weak self] _ in
      self?.reactor?.action.onNext(.tapLearn)
    }, for: .touchUpInside)
    
    contentView.takeChallengeButton.addAction(UIAction { [weak self] _ in
      self?.reactor?.action.onNext(.tapTake)
    }, for: .touchUpInside)
  }
  
  
  /// 챌린지 영상 일시정지 / 재생을 위해 재스처 달기
  private func setupVideoTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap))
    contentView.videoBackgroundView.isUserInteractionEnabled = true
    contentView.videoBackgroundView.addGestureRecognizer(tapGesture)
  }
  
  /// 챌린지 영상 일시정지 / 재생
  @objc private func handleVideoTap() {
    reactor?.action.onNext(.playPauseToggle)
    
    guard let reactor = reactor else { return }
    let isPlaying = !reactor.currentState.isPlaying
    makeChallengePlayPauseAnimation(isPlaying: isPlaying)
  }
  
  
  /// 챌린지 영상 일시정지 / 재생 애니메이션 만들기
  /// - Parameter isPlaying: 재생여부
  private func makeChallengePlayPauseAnimation(isPlaying: Bool) {
    let imageView = UIImageView()
    imageView.tintColor = .appPink
    imageView.image = UIImage(systemName: isPlaying ? "play.fill" : "pause.fill")

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
}

// MARK: GetKeyWindow Protocol

extension ShowChallengeViewController: GetKeyWindowProtocol{}

