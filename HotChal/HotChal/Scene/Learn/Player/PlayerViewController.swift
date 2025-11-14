//
//  PlayerViewController.swift
//  HotChal
//
//  Created by jonghyuck on 8/1/25.
//

import UIKit
import AVFoundation
import MediaPlayer

final class PlayerViewController: UIViewController, ModalViewControllerProtocol {

    weak var coordinator: ChallengeNavigationDelegate?
    
    private let controlsView = PlayerManager()
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    
    // A-B 반복용 변수
    private var loopStart: Double?
    private var loopEnd: Double?
    
  var challengeData: ChallengeVideo?
    
    private var isPlaying = true {
        didSet {
            guard let player = player else { return }
            isPlaying ? player.playImmediately(atRate: selectedSpeed) : player.pause()
        }
    }
    
    private var isMuted = false
    private var previousVolume: Float = 0.5
    
    private var selectedSpeed: Float = 1.0 {
        didSet {
            if isPlaying {
                player?.playImmediately(atRate: selectedSpeed)
            }
            updateSpeedButtons()
        }
    }
    
    private let speeds: [Float] = [0.5, 1.0, 1.5, 2.0]
    
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
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.additionalSafeAreaInsets.bottom = 0
        self.edgesForExtendedLayout = [.bottom]
        
        setupPlayer()
        setupUI()
        addPeriodicTimeObserver()
        setupGestureRecognizers()
        setupVolumeIconTap()
        setupPlayerButtons()
        setupConstraints()
        
        // 초기 텍스트 세팅
      controlsView.titleLabel.text = challengeData?.title ?? "None Title"
      controlsView.uploaderLabel.text = challengeData?.uploader ?? "Unknown Uploader"
        
        // 기본 선택 속도 세팅
        selectedSpeed = 1.0
        updateSpeedButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - setupPlayer
    func setupPlayer() {
        guard let filename = challengeData?.videoFilename,
              let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
          print("❌ Invalid video filename: \(String(describing: challengeData?.videoFilename))")
            return
        }
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        if let layer = playerLayer {
            view.layer.insertSublayer(layer, at: 0)
        }
        
        // 타임 옵저버 0.1초마다 호출
        let interval = CMTime(seconds: 0.1, preferredTimescale: 60)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let duration = self.player?.currentItem?.duration.seconds ?? 1
            if duration.isFinite && duration > 0 {
                let current = time.seconds
                self.controlsView.progressSlider.value = Float(current / duration)
                self.updateTimeLabel(currentTime: current, duration: duration)
            }
        }
        player?.playImmediately(atRate: selectedSpeed)
    }
    
    // MARK: - setupUI
    func setupUI() {
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsView)
        
        // 각 UI 컨트롤에 액션 연결
        controlsView.progressSlider.addTarget(self, action: #selector(progressSliderChanged), for: .valueChanged)
        controlsView.volumeSlider.addTarget(self, action: #selector(volumeSliderChanged), for: .valueChanged)
        controlsView.volumeIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(volumeIconTapped)))
        
        for case let button as UIButton in controlsView.speedStackView.arrangedSubviews {
            button.addTarget(self, action: #selector(speedSelected(_:)), for: .touchUpInside)
            
            overlayContainerView.addSubview(centerIconView)

            NSLayoutConstraint.activate([
                centerIconView.centerXAnchor.constraint(equalTo: overlayContainerView.centerXAnchor),
                centerIconView.centerYAnchor.constraint(equalTo: overlayContainerView.centerYAnchor),
                centerIconView.widthAnchor.constraint(equalToConstant: 56),
                centerIconView.heightAnchor.constraint(equalToConstant: 56),
            ])
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
          controlsView.topAnchor.constraint(greaterThanOrEqualTo: buttonStackView.bottomAnchor, constant: 10),
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 타임 옵저버 (A-B 반복 기능)
    private func addPeriodicTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
            print("🧹 Remove existing time observer")
        }
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: 60)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            
            let currentSeconds = time.seconds
            let duration = self.player?.currentItem?.duration.seconds ?? 0
            
            if duration.isFinite && duration > 0 {
                self.controlsView.progressSlider.value = Float(currentSeconds / duration)
                self.updateTimeLabel(currentTime: currentSeconds, duration: duration)
            }
            
            let isPaused = self.player?.rate == 0
            UIView.animate(withDuration: 0.25) {
                self.controlsView.pauseIconView.alpha = isPaused ? 1 : 0
            }
            
            // A-B 반복 재생 처리
            if let start = self.loopStart,
               let end = self.loopEnd,
               end > start,
               currentSeconds >= end {
                
                let seekTime = CMTime(seconds: start, preferredTimescale: 60)
                self.player?.seek(to: seekTime) { [weak self] _ in
                    guard let self = self else { return }
                    if self.isPlaying {
                        self.player?.playImmediately(atRate: self.selectedSpeed)
                    }
                }
            }
        }
        print("✅ New Time observer added")
    }
    
    // MARK: - 제스처 및 이벤트
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(togglePlayPause))
        tapGesture.cancelsTouchesInView = false
        
        view.insertSubview(overlayContainerView, at: 1)
        overlayContainerView.frame = view.bounds
        overlayContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayContainerView.backgroundColor = .clear
        overlayContainerView.addGestureRecognizer(tapGesture)
    }
    
    private func setupVolumeIconTap() {
        controlsView.volumeIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(volumeIconTapped)))
    }
    
    // MARK: - 함수들
    
    @objc func progressSliderChanged() {
        guard let duration = player?.currentItem?.duration.seconds, duration > 0 else { return }
        let value = Double(controlsView.progressSlider.value) * duration
        player?.seek(to: CMTime(seconds: value, preferredTimescale: 1000))
    }
    
    @objc func volumeSliderChanged() {
        player?.volume = controlsView.volumeSlider.value
        if controlsView.volumeSlider.value == 0 {
            isMuted = true
            controlsView.volumeIcon.image = UIImage(systemName: "speaker.slash.fill")
        } else {
            isMuted = false
            controlsView.volumeIcon.image = UIImage(systemName: "speaker.fill")
            previousVolume = controlsView.volumeSlider.value
        }
    }
    
    @objc func volumeIconTapped() {
        guard let player = player else { return }
        if isMuted {
            isMuted = false
            player.volume = previousVolume
            controlsView.volumeSlider.value = previousVolume
            controlsView.volumeIcon.image = UIImage(systemName: "speaker.fill")
        } else {
            isMuted = true
            previousVolume = player.volume
            player.volume = 0
            controlsView.volumeSlider.value = 0
            controlsView.volumeIcon.image = UIImage(systemName: "speaker.slash.fill")
        }
    }
    
    @objc func speedSelected(_ sender: UIButton) {
        selectedSpeed = Float(sender.tag) / 10.0
    }
    
    @objc func togglePlayPause() {
        guard let player = player else { return }

        if player.timeControlStatus == .paused {
            showCenterIcon(type: .play)
            if let duration = player.currentItem?.duration,
               abs(player.currentTime().seconds - duration.seconds) < 0.3 {
                print("🔁 끝까지 재생된 상태, 처음부터 다시 재생")
                player.seek(to: .zero) { [weak self] _ in
                    guard let self = self else { return }
                    self.player?.playImmediately(atRate: self.selectedSpeed)
                }
            } else {
                player.playImmediately(atRate: selectedSpeed)
            }
        } else {
            showCenterIcon(type: .pause)
            player.pause()
        }
    }
    
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
    
    // MARK: - UI 업데이트
    
    private func updateTimeLabel(currentTime: Double, duration: Double) {
        let current = Int(currentTime.rounded())
        let total = Int(duration.rounded())
        controlsView.timeLabel.text = "\(current)s | \(total)s"
    }
    
    private func updateSpeedButtons() {
        for case let button as UIButton in controlsView.speedStackView.arrangedSubviews {
            let speed = Float(button.tag) / 10.0
            button.backgroundColor = (speed == selectedSpeed) ? .appPink : UIColor.white.withAlphaComponent(0.2)
        }
    }
    
    // MARK: - 버튼 설정
    
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
//          ChallengePlayerUIManager.shared.closeChallPlayer()
          let comment = result ? "챌린지가 저장되었습니다." : "이미 저장된 챌린지입니다."
          
          ToastPopupManager.shared.showToast(message: comment, from: self)
        }
      }, for: .touchUpInside)

      
      takeChallengeButton.addTarget(self,
                                    action: #selector(navToTakeChallengeViewController),
                                    for: .touchUpInside)
      
      repeatChallengeButton.addTarget(self, action: #selector(handleShowModal), for: .touchUpInside)
      
      [saveChallengeButton,takeChallengeButton,repeatChallengeButton].forEach {
        buttonStackView.addArrangedSubview($0)
      }
      NSLayoutConstraint.activate([
        buttonStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
      ])
    }

    // MARK: - 찍어보기 버튼 액션
    
    @objc func navToTakeChallengeViewController() {
        let audioName = challengeData?.mp4FilenameWithoutExtension ?? ""
        let subFilename = challengeData?.videoFilename
        coordinator?.navToTakeChallengeViewController(audioFileName: audioName,
                                                      subVideoFilename: subFilename)
    }
    
    // MARK: - 모달 관련
    
    func willDismissModalView(_ viewController: ModalViewController, startTime: Double?, endTime: Double?) {
            loopStart = startTime
            loopEnd = endTime
            
            if let start = startTime, let end = endTime, end > start {
                print("🎯 루프 범위 설정됨: \(start)초 ~ \(end)초")
            } else {
                print("🔄 루프 범위 초기화 또는 무효")
                loopStart = nil
                loopEnd = nil
            }
        }
    
    @objc func handleShowModal() {
            let modalVC = ModalViewController()
            modalVC.delegate = self
            modalVC.modalPresentationStyle = .pageSheet
            
            if let sheet = modalVC.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom { _ in return 220 }]
                } else {
                    sheet.detents = [.medium()]
                }
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
            present(modalVC, animated: true)
        }
}

extension PlayerViewController {
    func didSetLoopRange(startTime: Double, endTime: Double) {
        loopStart = startTime
        loopEnd = endTime
    }
}

@available(iOS 17.0, *)
#Preview {
    UINavigationController(rootViewController: PlayerViewController())
}
