//
//  Player.swift
//  HotChal
//
//  Created by jonghyuck on 8/1/25.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlayerViewController: UIViewController {

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    
    // 전체 화면 배경(영상용)
    private let playerBackgroundView = UIView()
        
    // UI를 올릴 컨테이너
    private let overlayContainerView = UIView()
    
    private let progressSlider = UISlider()
    private let volumeSlider = UISlider()
    private let speedStackView = UIStackView()
    
    // A-B 반복용 변수 선언
    private var loopStart: Double?
    private var loopEnd: Double?
    
    var videoFilename: String?
    var videoTitle: String?
    var uploader: String?
    
    
    private var isPlaying = true {
        didSet {
            guard let player = player else { return }
            isPlaying ? player.playImmediately(atRate: selectedSpeed) : player.pause()
        }
    }
    
    private let speeds: [Float] = [0.5, 1.0, 1.5, 2.0]
    private var isMuted = false
    private var previousVolume: Float = 0.5
    
    // 타이틀 + 업로더 라벨 배경 설정
    private let infoBackgroundView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: .none)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.sizeToFit()
        return view
    }()
    
    // 속도 조절 버튼 업데이트
    private var selectedSpeed: Float = 1.0 {
        didSet {
            if isPlaying {
                player?.playImmediately(atRate: selectedSpeed)
            }
            updateSpeedButtons()
        }
    }
    
    //MARK: - 라벨 설정
    
    // 챌린지 타이틀
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.shadowColor = .darkGray
        label.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()
    
    // 업로더
    private let uploaderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.shadowColor = .darkGray
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }()
    
    // 재생 시간 | 남은 시간
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .monospacedDigitSystemFont(ofSize: 11.5, weight: .regular)
        label.textAlignment = .right
        label.text = "00"
        label.shadowColor = .darkGray
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }()
    
    private let volumeIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "speaker.fill"))
        imageView.tintColor = .appPink
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.additionalSafeAreaInsets.bottom = 0 // safeArea 하단 없애기
        self.edgesForExtendedLayout = [.bottom] // 전체 화면까지 확장
        
        titleLabel.text = videoTitle ?? "None Title"
        uploaderLabel.text = uploader ?? "Unknown Uploader"
        
        setupPlayer()
        setupUI()
        addPeriodicTimeObserver()
        setupGestureRecognizers()
        setupVolumeIconTap()
        setupNavigationButton()
        
        // 반복 재생 세팅 버튼
        let button: UIButton = {
           let button = UIButton(type: .system)
            button.addTarget(self, action: #selector(handleShowModal), for: .touchUpInside)
            button.setTitle("Loop Setting", for: .normal)
            return button
        }()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: volumeSlider.topAnchor, constant: -16),
            button.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: -115),
            button.widthAnchor.constraint(equalToConstant: 115),
        ])
    }

    
    //MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer?.frame = view.bounds
        
        //margin - 뷰끼리의 간격
        let margin: CGFloat = 20
        let spacing: CGFloat = 8
        let sliderHeight: CGFloat = 30
        let maxWidth = view.bounds.width - margin * 2
        let safeAreaBottom = view.safeAreaInsets.bottom
        
        let titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth - 14, height: .greatestFiniteMagnitude))
        let uploaderSize = uploaderLabel.sizeThatFits(CGSize(width: maxWidth - 13, height: .greatestFiniteMagnitude))
        let infoHeight = titleSize.height + uploaderSize.height + spacing
        let infoWidth = titleSize.width + uploaderSize.width + spacing
        
        let speedStackHeight: CGFloat = 40
        let speedStackY = view.bounds.height - safeAreaBottom - speedStackHeight
        let progressSliderY = speedStackY - sliderHeight - spacing
        
        speedStackView.frame = CGRect(
            x: margin,
            y: speedStackY,
            width: maxWidth,
            height: speedStackHeight
        )
        
        progressSlider.frame = CGRect(
            x: margin,
            y: progressSliderY,
            width: maxWidth - 60,
            height: sliderHeight
        )
        
        timeLabel.frame = CGRect(
            x: progressSlider.frame.maxX + 5,
            y: progressSliderY,
            width: 100,
            height: sliderHeight
        )
        
        volumeIcon.frame = CGRect(
            x: margin,
            y: progressSlider.frame.minY - sliderHeight - spacing,
            width: sliderHeight,
            height: sliderHeight
        )
        
        volumeSlider.frame = CGRect(
            x: volumeIcon.frame.maxX + 8,
            y: volumeIcon.frame.minY,
            width: maxWidth - volumeIcon.frame.width - 8,
            height: sliderHeight
        )
        
        infoBackgroundView.frame = CGRect(
            x: margin,
            y: volumeSlider.frame.minY - infoHeight - spacing,
            width: infoWidth,
            height: infoHeight
        )
        
        titleLabel.frame = CGRect(x: 12, y: 6, width: maxWidth - 24, height: titleSize.height)
        uploaderLabel.frame = CGRect(x: 12, y: titleLabel.frame.maxY + 2, width: maxWidth - 24, height: uploaderSize.height)
        
        timeLabel.frame = CGRect(
            x: view.bounds.width - margin - 100,
            y: progressSlider.frame.minY - -5,
            width: 100,
            height: 20
        )
    }
    
    // MARK: - setupPlayer
   func setupPlayer() {
       guard let filename = videoFilename,
       let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
               print("❌ Invalid video filename: \(String(describing: videoFilename))")
               return
           }
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspect
               if let layer = playerLayer {
                   view.layer.insertSublayer(layer, at: 0)
               }
        
       // 0.1초 마다 슬라이더 업데이트 주기 설정
       // interval - 콜백이 호출되는 주기(n초 마다)
        let interval = CMTime(seconds: 0.1, preferredTimescale: 60)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let duration = self.player?.currentItem?.duration.seconds ?? 1
            if duration.isFinite && duration > 0 {
                let current = time.seconds
                self.progressSlider.value = Float(current / duration)
                self.updateTimeLabel(currentTime: current, duration: duration)
            }
        }
       // 선택된 속도로 영상 재생
        player?.playImmediately(atRate: selectedSpeed)
    }
    
    // MARK: - setupUI
    private func setupUI() {
        view.addSubview(infoBackgroundView)
        infoBackgroundView.contentView.addSubview(titleLabel)
        infoBackgroundView.contentView.addSubview(uploaderLabel)
        
        view.addSubview(progressSlider)
        view.addSubview(timeLabel)
        view.addSubview(volumeIcon)
        view.addSubview(volumeSlider)
        view.addSubview(speedStackView)

        // 재생 바 슬라이더
        progressSlider.minimumTrackTintColor = .white
        progressSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        progressSlider.thumbTintColor = .appPink
        progressSlider.addTarget(self, action: #selector(progressSliderChanged), for: .valueChanged)
        
        // 볼륨 바 슬라이더
        volumeSlider.minimumTrackTintColor = .appPink
        volumeSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        volumeSlider.thumbTintColor = .white
        volumeSlider.value = 1.0
        volumeSlider.addTarget(self, action: #selector(volumeSliderChanged), for: .valueChanged)
        
        // 속도 조절 뷰 위치 조정
        speedStackView.axis = .horizontal
        speedStackView.spacing = 8
        speedStackView.distribution = .fillEqually
        speedStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 속도 조절 뷰 UI
        for speed in speeds {
            let button = UIButton(type: .system)
            button.setTitle("\(speed)x", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            button.tag = Int(speed * 10)
            button.addTarget(self, action: #selector(speedSelected(_:)), for: .touchUpInside)
            speedStackView.addArrangedSubview(button)
        }
        // 기본 선택된 속도
        selectedSpeed = 1.0
        updateSpeedButtons()
        
        // 속도 조절 뷰 레이아웃
        NSLayoutConstraint.activate([
            speedStackView.heightAnchor.constraint(equalToConstant: 36),
            speedStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            speedStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            speedStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // MARK: - 라벨 레이아웃 설정
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(uploaderLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        uploaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 타이틀, 업로더 라벨 레이아웃
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            uploaderLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            uploaderLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            uploaderLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
    }
    
    // MARK: - 타임 옵저버 (A-B 반복 기능)

    private func addPeriodicTimeObserver() {
        // 기존 옵저버 제거
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

            // 재생 바 & 시간 라벨 업데이트
            if duration.isFinite && duration > 0 {
                self.progressSlider.value = Float(currentSeconds / duration)
                self.updateTimeLabel(currentTime: currentSeconds, duration: duration)
            }

            // A-B 반복 처리
            if let start = loopStart,
            let end = loopEnd,
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

  
    // 탭해서 재생, 일시정지 오버레이
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(togglePlayPause))
        tapGesture.cancelsTouchesInView = false

        // ⚠️ overlayContainerView 또는 playerBackgroundView 등 적절한 백그라운드 뷰에만 추가
        view.insertSubview(overlayContainerView, at: 1) // 필요한 경우 초기화와 위치 추가
        overlayContainerView.frame = view.bounds
        overlayContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayContainerView.backgroundColor = .clear
        overlayContainerView.addGestureRecognizer(tapGesture)
    }

    
    // 볼륨 버튼 탭(뮤트)
    private func setupVolumeIconTap() {
        volumeIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(volumeIconTapped)))
    }
    
    // 영상 재생 종료 후
    @objc private func playerDidFinishPlaying() {
        player?.seek(to: .zero)
        isPlaying = false
    }
    
    // 재생 슬라이더 변화 감지
    @objc private func progressSliderChanged() {
        guard let duration = player?.currentItem?.duration.seconds, duration > 0 else { return }
        let value = Double(progressSlider.value) * duration
        let rounded = value
        player?.seek(to: CMTime(seconds: rounded, preferredTimescale: 1000))
        }
    
    // 볼륨 슬라이더 변화 감지
    @objc private func volumeSliderChanged() {
        player?.volume = volumeSlider.value
        if volumeSlider.value == 0 {
            isMuted = true
            volumeIcon.image = UIImage(systemName: "speaker.slash.fill")
        } else {
            isMuted = false
            volumeIcon.image = UIImage(systemName: "speaker.fill")
            previousVolume = volumeSlider.value
        }
    }
    
    // 볼륨 아이콘 눌렀을때(뮤트 설정)
    @objc private func volumeIconTapped() {
        guard let player = player else { return }
        if isMuted {
            isMuted = false
            player.volume = previousVolume
            volumeSlider.value = previousVolume
            volumeIcon.image = UIImage(systemName: "speaker.fill")
        } else {
            isMuted = true
            previousVolume = player.volume
            player.volume = 0
            volumeSlider.value = 0
            volumeIcon.image = UIImage(systemName: "speaker.slash.fill")
        }
    }
    
    // 재생 속도 선택 버튼
    @objc private func speedSelected(_ sender: UIButton) {
        selectedSpeed = Float(sender.tag) / 10.0
    }
    
    // 탭해서 재생, 일시정지 설정
    @objc private func togglePlayPause() {
        guard let player = player else { return }

        if player.timeControlStatus == .paused {
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
            player.pause()
        }
    }
    
    // 재생 시간 업데이트
    private func updateTimeLabel(currentTime: Double, duration: Double) {
        let current = Int(currentTime.rounded())
        let total = Int(duration.rounded())
        timeLabel.text = "\(current)s | \(total)s"
    }
    
    // 속도 버튼 업데이트
    private func updateSpeedButtons() {
        for case let button as UIButton in speedStackView.arrangedSubviews {
            let speed = Float(button.tag) / 10.0
            button.backgroundColor = (speed == selectedSpeed) ? .appPink : UIColor.white.withAlphaComponent(0.2)
        }
    }

    // 찍어보기 버튼
    private func setupNavigationButton() {
        let button = UIButton(type: .system)
        button.setTitle("챌린지 찍기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .appPink .withAlphaComponent(1)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(navToTakeChallengeViewController), for: .touchUpInside)
        
        view.addSubview(button)
        
        // 우측 상단에 위치 (Safe Area 기준)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            button.widthAnchor.constraint(equalToConstant: 80),
            button.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    // 찍어보기(카메라)화면으로 전환 버튼
    @objc func navToTakeChallengeViewController() {
            let vc = CameraViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    
    // 텍스트 필드 모달 뷰
    @objc func handleShowModal() {
        let modalViewController = ModalViewController()
        modalViewController.delegate = self
        if let sheet = modalViewController.sheetPresentationController {
            if let sheet = modalViewController.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom(resolver: { _ in return 170 })] // 약 1/3 높이
                } else {
                    sheet.detents = [.medium()]
                }
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
            self.present(modalViewController, animated: true)
        }
    }

    //MARK: - 뷰 이동시 숨김/나타냄 처리
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        additionalSafeAreaInsets.bottom = 0
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    // 메모리 누수 문제로 추가(디버깅까지)
    deinit {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
            print("🗑️ Time observer removed")
        }
    }
}

extension PlayerViewController: ModalViewControllerProtocol {
    func willDismissModalView(_ viewController: ModalViewController, startTime: Double?, endTime: Double?) {
        if let start = startTime, let end = endTime, end > start {
            print("🔁 반복 설정됨: \(start)s ~ \(end)s")
            self.loopStart = start
            self.loopEnd = end
        } else {
            print("🛑 반복 해제됨")
            self.loopStart = nil
            self.loopEnd = nil
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    UINavigationController(rootViewController: PlayerViewController())
}
