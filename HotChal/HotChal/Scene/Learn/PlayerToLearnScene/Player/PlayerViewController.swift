//
//  PlayerViewController.swift
//  HotChal
//
//  Created by jonghyuck on 8/1/25.
//

import UIKit
import AVFoundation
import MediaPlayer
import ReactorKit
import RxSwift
import RxCocoa


/// 챌린지 배우기 화면
final class PlayerViewController: UIViewController, ModalViewControllerProtocol,
                                  View, UIGestureRecognizerDelegate {
  
  // MARK: - Properties
  
  weak var coordinator: HotChallLearnCoordinator?
  var disposeBag = DisposeBag()
  
  private let controlsView = PlayerManager()
  private var playerService: VideoPlayerService?
  private var playerLayer: AVPlayerLayer?
  
  var challengeData: ChallengeVideo?
  
  private let speeds: [Float] = [0.5, 1.0, 1.5, 2.0]
  
  // Tap gesture for play/pause
  private lazy var playPauseTapGesture: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer()
    gesture.delegate = self
    return gesture
  }()
  
  // MARK: - UI Components
  
  private let overlayContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.isUserInteractionEnabled = true
    return view
  }()
  
  private let centerIconView: UIImageView = {
    let imageView = UIImageView()
    imageView.tintColor = .appPink
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.alpha = 0
    return imageView
  }()
  
  private let buttonStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.alignment = .fill
    stackView.spacing = 10
    stackView.backgroundColor = .backgroundColor.withAlphaComponent(0.6)
    stackView.layer.cornerRadius = 8
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    return stackView
  }()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    self.additionalSafeAreaInsets.bottom = 0
    self.edgesForExtendedLayout = [.bottom]
    
    setupUI()
    setupGestureRecognizers()
    setupPlayerButtons()
    setupConstraints()
    
    // Reactor 생성 및 바인딩
    if reactor == nil {
      reactor = PlayerViewReactor(challengeData: challengeData)
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    playerLayer?.frame = view.bounds
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.prefersLargeTitles = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // 화면을 나갈 때 재생 중이면 일시정지
    if reactor?.currentState.isPlaying == true {
      reactor?.action.onNext(.togglePlayPause)
    }
    playerService?.player.pause()
  }
  
  deinit {
    // 메모리 해제 시 플레이어 정리
    playerService?.player.pause()
    playerLayer?.removeFromSuperlayer()
  }
  
  // MARK: - Reactor Binding
  
  func bind(reactor: PlayerViewReactor) {
    // Action: Challenge 데이터 설정
    if let challengeData = challengeData {
      reactor.action.onNext(.setChallenge(challengeData))
    }
    
    // Action: 재생/일시정지 토글
    overlayContainerView.addGestureRecognizer(playPauseTapGesture)
    playPauseTapGesture.rx.event
      .map { _ in Reactor.Action.togglePlayPause }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // Action: 진행 슬라이더 변경 (사용자가 드래그할 때만)
    controlsView.progressSlider.rx.controlEvent(.valueChanged)
      .withLatestFrom(controlsView.progressSlider.rx.value)
      .map { Reactor.Action.seek(progress: $0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // Action: 볼륨 슬라이더 변경
    controlsView.volumeSlider.rx.value
      .skip(1)
      .map { Reactor.Action.changeVolume($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // Action: 볼륨 아이콘 탭
    let volumeTapGesture = UITapGestureRecognizer()
    controlsView.volumeIcon.addGestureRecognizer(volumeTapGesture)
    controlsView.volumeIcon.isUserInteractionEnabled = true
    volumeTapGesture.rx.event
      .map { _ in Reactor.Action.toggleMute }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // Action: 속도 버튼 선택
    for case let button as UIButton in controlsView.speedStackView.arrangedSubviews {
      let buttonTag = button.tag
      button.rx.tap
        .map { Float(buttonTag) / 10.0 }
        .map { Reactor.Action.selectSpeed($0) }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
    }
    
    // State: 챌린지 데이터 변경
    reactor.state.map { $0.videoURL }
      .distinctUntilChanged { $0?.absoluteString == $1?.absoluteString }
      .compactMap { $0 }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] url in
        self?.setupPlayer(with: url, reactor: reactor)
      })
      .disposed(by: disposeBag)
    
    // State: Seek 처리
    reactor.state.map { $0.seekProgress }
      .distinctUntilChanged()
      .compactMap { $0 }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] progress in
        self?.playerService?.seek(to: progress)
      })
      .disposed(by: disposeBag)
    
    // State: 제목 업데이트
    reactor.state.map { $0.title }
      .distinctUntilChanged()
      .bind(to: controlsView.titleLabel.rx.text)
      .disposed(by: disposeBag)
    
    // State: 업로더 업데이트
    reactor.state.map { $0.uploader }
      .distinctUntilChanged()
      .bind(to: controlsView.uploaderLabel.rx.text)
      .disposed(by: disposeBag)
    
    // State: 재생/일시정지 상태
    reactor.state.map { $0.isPlaying }
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] isPlaying in
        guard let self = self else { return }
        self.handlePlaybackStateChange(isPlaying: isPlaying, speed: reactor.currentState.selectedSpeed)
        self.showCenterIcon(type: isPlaying ? .play : .pause)
      })
      .disposed(by: disposeBag)
    
    // State: 진행 상태 (슬라이더 업데이트 - 재생 중에만)
    reactor.state.map { $0.progress }
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] progress in
        // 사용자가 슬라이더를 조작중이 아닐 때만 업데이트
        if self?.controlsView.progressSlider.isTracking == false {
          self?.controlsView.progressSlider.value = progress
        }
      })
      .disposed(by: disposeBag)
    
    // State: 시간 텍스트
    reactor.state.map { $0.timeText }
      .distinctUntilChanged()
      .bind(to: controlsView.timeLabel.rx.text)
      .disposed(by: disposeBag)
    
    // State: 볼륨 변경
    reactor.state.map { $0.volume }
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] volume in
        self?.playerService?.setVolume(volume)
        self?.controlsView.volumeSlider.value = volume
      })
      .disposed(by: disposeBag)
    
    // State: 음소거 상태
    reactor.state.map { $0.isMuted }
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] isMuted in
        let iconName = isMuted ? "speaker.slash.fill" : "speaker.fill"
        self?.controlsView.volumeIcon.image = UIImage(systemName: iconName)
      })
      .disposed(by: disposeBag)
    
    // State: 속도 변경
    reactor.state.map { $0.selectedSpeed }
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] speed in
        guard let self = self else { return }
        if reactor.currentState.isPlaying {
          self.playerService?.play(atRate: speed)
        }
        self.updateSpeedButtons(selectedSpeed: speed)
      })
      .disposed(by: disposeBag)
    
    // State: 일시정지 아이콘 표시
    reactor.state.map { $0.isPlaying }
      .distinctUntilChanged()
  
      .map { !$0 ? CGFloat(1) : CGFloat(0) }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] alpha in
        UIView.animate(withDuration: 0.25) {
          self?.controlsView.pauseIconView.alpha = alpha
        }
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup Player
  
  private func setupPlayer(with url: URL, reactor: PlayerViewReactor) {
    // 기존 player 정리
    playerLayer?.removeFromSuperlayer()
    
    // 새 player 생성
    playerService = VideoPlayerService(url: url)
    guard let playerService = playerService else { return }
    
    // PlayerLayer 설정
    playerLayer = AVPlayerLayer(player: playerService.player)
    playerLayer?.videoGravity = .resizeAspectFill
    if let layer = playerLayer {
      view.layer.insertSublayer(layer, at: 0)
      layer.frame = view.bounds
    }
    
    // 시간 업데이트 구독
    playerService.timeUpdate
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self, weak reactor] current, duration in
        guard let reactor = reactor else { return }
        reactor.action.onNext(.updateTime(current: current, duration: duration))
        
        // A-B 반복 체크
        let state = reactor.currentState
        self?.playerService?.checkAndHandleLoop(
          loopStart: state.loopStart,
          loopEnd: state.loopEnd,
          rate: state.selectedSpeed
        )
      })
      .disposed(by: disposeBag)
    
    // 재생 종료 구독
    playerService.playbackEnded
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self, weak reactor] in
        guard let self = self, let reactor = reactor else { return }
        if reactor.currentState.isPlaying {
          self.playerService?.replayFromBeginning(atRate: reactor.currentState.selectedSpeed)
        }
      })
      .disposed(by: disposeBag)
    
    // 초기 재생
    playerService.play(atRate: reactor.currentState.selectedSpeed)
  }
  
  private func handlePlaybackStateChange(isPlaying: Bool, speed: Float) {
    guard let playerService = playerService else { return }
    
    if isPlaying {
      if playerService.isAtEnd() {
        playerService.replayFromBeginning(atRate: speed)
      } else {
        playerService.play(atRate: speed)
      }
    } else {
      playerService.pause()
    }
  }
  
  // MARK: - Setup UI
  
  func setupUI() {
    controlsView.translatesAutoresizingMaskIntoConstraints = false
    overlayContainerView.addSubview(controlsView)
    
    overlayContainerView.addSubview(centerIconView)
    
    NSLayoutConstraint.activate([
      centerIconView.centerXAnchor.constraint(equalTo: overlayContainerView.centerXAnchor),
      centerIconView.centerYAnchor.constraint(equalTo: overlayContainerView.centerYAnchor),
      centerIconView.widthAnchor.constraint(equalToConstant: 56),
      centerIconView.heightAnchor.constraint(equalToConstant: 56),
    ])
  }
  
  func setupConstraints() {
    NSLayoutConstraint.activate([
      controlsView.topAnchor.constraint(greaterThanOrEqualTo: buttonStackView.bottomAnchor, constant: 10),
      controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      controlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
    ])
  }
  
  // MARK: - Gesture Setup
  
  private func setupGestureRecognizers() {
    view.insertSubview(overlayContainerView, at: 1)
    overlayContainerView.frame = view.bounds
    overlayContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    overlayContainerView.backgroundColor = .clear
  }
  
  // MARK: - UI Helpers
  
  private enum CenterIconType {
    case play, pause
    
    var systemImageName: String {
      switch self {
      case .play: return "play.fill"
      case .pause: return "pause.fill"
      }
    }
  }
  
  private func showCenterIcon(type: CenterIconType) {
    let image = UIImage(systemName: type.systemImageName)
    centerIconView.image = image
    centerIconView.alpha = 1
    centerIconView.transform = .identity
    UIView.animate(withDuration: 0.6, animations: {
      self.centerIconView.alpha = 0
      self.centerIconView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
    }) { _ in
      self.centerIconView.transform = .identity
    }
  }
  
  private func updateSpeedButtons(selectedSpeed: Float) {
    for case let button as UIButton in controlsView.speedStackView.arrangedSubviews {
      let speed = Float(button.tag) / 10.0
      button.backgroundColor = (speed == selectedSpeed) ? .appPink : UIColor.white.withAlphaComponent(0.2)
    }
  }
  
  // MARK: - Button Setup
  
  private func setupPlayerButtons() {
    view.addSubview(buttonStackView)
    buttonStackView.translatesAutoresizingMaskIntoConstraints = false
    let saveChallengeButton = ChallengeButton(type: .saveChallenge)
    let takeChallengeButton = ChallengeButton(type: .takeChallenge)
    let repeatChallengeButton = ChallengeButton(type: .repeatChallenge)
    
    saveChallengeButton.addAction(UIAction { [weak self] _ in
      guard let self = self,
            let data = self.challengeData else { return }
      CoreDataManager.shared.saveChallenge(with: data) { result in
        let comment = result ? "챌린지가 저장되었습니다." : "이미 저장된 챌린지입니다."
        ToastPopupManager.shared.showToast(message: comment, from: self)
      }
    }, for: .touchUpInside)
    
    takeChallengeButton.addTarget(self,
                                  action: #selector(navToTakeChallengeViewController),
                                  for: .touchUpInside)
    
    repeatChallengeButton.addAction(UIAction { _ in
      self.coordinator?.handleShowModal(from: self)
    }, for: .touchUpInside)
    
    [saveChallengeButton, takeChallengeButton, repeatChallengeButton].forEach {
      buttonStackView.addArrangedSubview($0)
    }
    
    NSLayoutConstraint.activate([
      buttonStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
      buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
    ])
  }
  
  // MARK: - Button Actions
  
  @objc func navToTakeChallengeViewController() {
    guard let reactor = reactor else { return }
    let state = reactor.currentState
    coordinator?.navToTakeChallengeViewController(
      audioFileName: state.audioFileName,
      subVideoFilename: state.subVideoFilename
    )
  }
  
  // MARK: - Modal Handling
  
  func willDismissModalView(_ viewController: ModalViewController, startTime: Double?, endTime: Double?) {
    print("🎬 구간 반복 설정: \(startTime ?? 0)초 ~ \(endTime ?? 0)초")
    reactor?.action.onNext(.setLoopRange(start: startTime, end: endTime))
    
    if let start = startTime,
       let end = endTime,
       end > start {
      print("🎯 루프 범위 설정됨: \(start)초 ~ \(end)초")
    } else {
      print("🔄 루프 범위 초기화 또는 무효")
    }
  }
}

// MARK: - Extension

extension PlayerViewController {
  func didSetLoopRange(startTime: Double, endTime: Double) {
    reactor?.action.onNext(.setLoopRange(start: startTime, end: endTime))
  }
}

