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
    
    // 전체 화면 배경 (영상용)
    private let playerBackgroundView = UIView()
        
    // UI를 올릴 컨테이너
    private let overlayContainerView = UIView()
    
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
    // MARK: - 속도 조절 버튼 업데이트
    private var selectedSpeed: Float = 1.0 {
        didSet {
            if isPlaying {
                player?.playImmediately(atRate: selectedSpeed)
            }
            updateSpeedButtons()
        }
    }
    
    private var isMuted = false
    private var previousVolume: Float = 0.5
    
    private let infoBackgroundView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: .none)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.sizeToFit()
        return view
    }()
    
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
    
    private let progressSlider = UISlider()
    private let volumeSlider = UISlider()
    private let speedStackView = UIStackView()
    
    // A-B 반복용 텍스트 필드
    private let startTimeField = UITextField()
    private let endTimeField = UITextField()
  
  
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.additionalSafeAreaInsets.bottom = 0 // safeArea 하단 없애기
        self.edgesForExtendedLayout = [.bottom] // 전체 화면까지 확장
        
        titleLabel.text = videoTitle ?? "제목 없음"
        uploaderLabel.text = uploader ?? "알 수 없음"
        
        setupPlayer()
        setupUI()
        setupLoopInputFields()
        addPeriodicTimeObserver()
        setupGestureRecognizers()
        setupVolumeIconTap()
    }

    
    //MARK: - View DidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer?.frame = view.bounds
        
        //margin - 뷰끼리의 간격
        let margin: CGFloat = 20
        let spacing: CGFloat = 8
        let sliderHeight: CGFloat = 30
        let maxWidth = view.bounds.width - margin * 2
        let safeAreaBottom = view.safeAreaInsets.bottom
        
        let titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth - 12, height: .greatestFiniteMagnitude))
        let uploaderSize = uploaderLabel.sizeThatFits(CGSize(width: maxWidth - 12, height: .greatestFiniteMagnitude))
        let infoHeight = titleSize.height + uploaderSize.height + spacing
        let infoWidth = titleSize.width + uploaderSize.width + spacing
        
        let speedStackHeight: CGFloat = 40
        let speedStackY = view.bounds.height - safeAreaBottom - speedStackHeight
        
        speedStackView.frame = CGRect(
            x: margin,
            y: speedStackY,
            width: maxWidth,
            height: speedStackHeight
        )
        
        let progressSliderY = speedStackY - sliderHeight - spacing
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
        
        // 콜백이 호출되는 주기(0.1초 마다)
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
        
        // 속도 조절 버튼 위치 조정
        speedStackView.axis = .horizontal
        speedStackView.spacing = 8
        speedStackView.distribution = .fillEqually
        speedStackView.translatesAutoresizingMaskIntoConstraints = false
        
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
        view.addSubview(speedStackView)
        
        progressSlider.minimumTrackTintColor = .white
        progressSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        progressSlider.thumbTintColor = .appPink
        progressSlider.addTarget(self, action: #selector(progressSliderChanged), for: .valueChanged)
        
        volumeSlider.minimumTrackTintColor = .appPink
        volumeSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        volumeSlider.thumbTintColor = .white
        volumeSlider.value = 1.0
        volumeSlider.addTarget(self, action: #selector(volumeSliderChanged), for: .valueChanged)
        
        selectedSpeed = 1.0
        updateSpeedButtons()

        
        // 속도 조절 버튼 레이아웃
        NSLayoutConstraint.activate([
            speedStackView.heightAnchor.constraint(equalToConstant: 36),
            speedStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            speedStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            speedStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // MARK: - 레이아웃 설정
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(uploaderLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        uploaderLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            uploaderLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            uploaderLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            uploaderLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
    }
    // MARK: - A-B 반복 입력 필드

        private func setupLoopInputFields() {
            [startTimeField, endTimeField].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.borderStyle = .roundedRect
                $0.keyboardType = .decimalPad
                $0.backgroundColor = .white
                $0.textAlignment = .center
                $0.font = .systemFont(ofSize: 13)
                view.addSubview($0)
            }

            startTimeField.placeholder = "시작(초)"
            endTimeField.placeholder = "종료(초)"

            NSLayoutConstraint.activate([
                startTimeField.bottomAnchor.constraint(equalTo: volumeSlider.topAnchor, constant: -16),
                startTimeField.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: -150),
                startTimeField.widthAnchor.constraint(equalToConstant: 60),

                endTimeField.centerYAnchor.constraint(equalTo: startTimeField.centerYAnchor),
                endTimeField.leadingAnchor.constraint(equalTo: startTimeField.trailingAnchor, constant: 12),
                endTimeField.widthAnchor.constraint(equalToConstant: 60)
            ])
        }
    // MARK: - 타임 옵저버 (A-B 반복 기능)

        private func addPeriodicTimeObserver() {
            let interval = CMTime(seconds: 1, preferredTimescale: 60)
            timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                guard let self = self else { return }

                guard let startText = self.startTimeField.text,
                      let endText = self.endTimeField.text,
                      let start = Double(startText),
                      let end = Double(endText),
                      end > start else {
                    return
                }
                
                let currentSeconds = time.seconds
                if currentSeconds >= end {
                    let seekTime = CMTime(seconds: start, preferredTimescale: 60)
                    self.player?.seek(to: seekTime) { _ in
                        if self.isPlaying {
                            self.player?.playImmediately(atRate: self.selectedSpeed)
                    }
                }
            }
        }
    }
    
    private func setupGestureRecognizers() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(togglePlayPause)))
    }
    
    private func setupVolumeIconTap() {
        volumeIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(volumeIconTapped)))
    }
    
    @objc private func playerDidFinishPlaying() {
        player?.seek(to: .zero)
        isPlaying = false
    }
    
    @objc private func progressSliderChanged() {
            guard let duration = player?.currentItem?.duration.seconds, duration > 0 else { return }
            let value = Double(progressSlider.value) * duration
            let rounded = value
            player?.seek(to: CMTime(seconds: rounded, preferredTimescale: 1000))
        }
    
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
    
    @objc private func speedSelected(_ sender: UIButton) {
        selectedSpeed = Float(sender.tag) / 10.0
    }
    
    @objc private func togglePlayPause() {
        guard let player = player,
                      let item = player.currentItem else { return }

                if player.timeControlStatus == .paused && player.currentTime() >= item.duration {
                    player.seek(to: .zero)
                }
                isPlaying.toggle()
    }
    
    private func updateTimeLabel(currentTime: Double, duration: Double) {
        let current = Int(currentTime.rounded())
        let total = Int(duration.rounded())
        timeLabel.text = "\(current)초 | \(total)초"
    }
    
    private func updateSpeedButtons() {
        for case let button as UIButton in speedStackView.arrangedSubviews {
            let speed = Float(button.tag) / 10.0
            button.backgroundColor = (speed == selectedSpeed) ? .appPink : UIColor.white.withAlphaComponent(0.2)
        }
    }

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
}

@available(iOS 17.0, *)
#Preview {
    UINavigationController(rootViewController: PlayerViewController())
}
