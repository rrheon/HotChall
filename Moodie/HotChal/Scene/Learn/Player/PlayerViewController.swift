//
//  Player.swift
//  HotChal
//
//  Created by jonghyuck on 8/1/25.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    var videoFilename: String?
    var videoTitle: String?
    var uploader: String?
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var timeObserverToken: Any?
    
    private var isPlaying = true {
        didSet {
            isPlaying ? player.playImmediately(atRate: selectedSpeed) : player.pause()
        }
    }
    
    private let speeds: [Float] = [0.5, 1.0, 1.5, 2.0]
    private var selectedSpeed: Float = 1.0 {
        didSet {
            if isPlaying {
                player.playImmediately(atRate: selectedSpeed)
            }
            updateSpeedButtons()
        }
    }
    
    private var isMuted = false
    private var previousVolume: Float = 1.0
    
    private let infoBackgroundView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blur)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private let uploaderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .right
        label.text = "00:00 / 00:00"
        return label
    }()
    
    private let volumeIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "speaker.fill"))
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let progressSlider = UISlider()
    private let volumeSlider = UISlider()
    private let speedStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupPlayer()
        setupUI()
        setupGestureRecognizers()
        setupVolumeIconTap()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let window = view.window {
            playerLayer.frame = CGRect(
                x: 0,
                y: 0,
                width: window.bounds.width,
                height: window.bounds.height
            )
        }
        
        let margin: CGFloat = 20
        let spacing: CGFloat = 8
        let sliderHeight: CGFloat = 30
        let maxWidth = view.bounds.width - margin * 2
        
        let titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth - 24, height: .greatestFiniteMagnitude))
        let uploaderSize = uploaderLabel.sizeThatFits(CGSize(width: maxWidth - 24, height: .greatestFiniteMagnitude))
        let infoHeight = titleSize.height + uploaderSize.height + spacing
        
        let speedStackHeight: CGFloat = 40
        speedStackView.frame = CGRect(
            x: margin,
            y: view.bounds.height - speedStackHeight - margin,
            width: maxWidth,
            height: speedStackHeight
        )
        
        progressSlider.frame = CGRect(
            x: margin,
            y: speedStackView.frame.minY - sliderHeight - spacing,
            width: maxWidth,
            height: sliderHeight
        )
        
        let volumeIconSize: CGFloat = sliderHeight
        volumeIcon.frame = CGRect(
            x: margin,
            y: progressSlider.frame.minY - sliderHeight - spacing,
            width: volumeIconSize,
            height: volumeIconSize
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
            width: maxWidth,
            height: infoHeight
        )
        titleLabel.frame = CGRect(x: 12, y: 6, width: maxWidth - 24, height: titleSize.height)
        uploaderLabel.frame = CGRect(x: 12, y: titleLabel.frame.maxY + 2, width: maxWidth - 24, height: uploaderSize.height)
        
        timeLabel.frame = CGRect(
            x: view.bounds.width - margin - 100,
            y: progressSlider.frame.minY - 20,
            width: 100,
            height: 20
        )
    }
    
    private func setupPlayer() {
        guard let filename = videoFilename,
              let path = Bundle.main.path(forResource: filename.replacingOccurrences(of: ".mp4", with: ""), ofType: "mp4") else {
            print("❌ 영상 파일을 찾을 수 없습니다: \(videoFilename ?? "nil")")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        view.layer.insertSublayer(playerLayer, at: 0)
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let duration = self.player.currentItem?.duration.seconds ?? 1
            if duration.isFinite && duration > 0 {
                let current = time.seconds
                self.progressSlider.value = Float(current / duration)
                self.updateTimeLabel(currentTime: current, duration: duration)
            }
        }
        
        titleLabel.text = videoTitle ?? "제목 없음"
        uploaderLabel.text = uploader ?? "알 수 없음"
        player.playImmediately(atRate: selectedSpeed)
    }
    
    private func setupUI() {
        view.addSubview(infoBackgroundView)
        infoBackgroundView.contentView.addSubview(titleLabel)
        infoBackgroundView.contentView.addSubview(uploaderLabel)
        
        view.addSubview(timeLabel)
        view.addSubview(progressSlider)
        view.addSubview(volumeIcon)
        view.addSubview(volumeSlider)
        
        speedStackView.axis = .horizontal
        speedStackView.spacing = 8
        for speed in speeds {
            let button = UIButton(type: .system)
            button.setTitle("\(speed)x", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = .systemFont(ofSize: 12)
            button.tag = Int(speed * 10)
            button.addTarget(self, action: #selector(speedSelected(_:)), for: .touchUpInside)
            speedStackView.addArrangedSubview(button)
        }
        view.addSubview(speedStackView)
        
        progressSlider.minimumTrackTintColor = .systemGreen
        progressSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        progressSlider.thumbTintColor = .white
        progressSlider.addTarget(self, action: #selector(progressSliderChanged), for: .valueChanged)
        
        volumeSlider.minimumTrackTintColor = .systemGreen
        volumeSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        volumeSlider.thumbTintColor = .white
        volumeSlider.value = 1.0
        volumeSlider.addTarget(self, action: #selector(volumeSliderChanged), for: .valueChanged)
        
        selectedSpeed = 1.0
        updateSpeedButtons()
    }
    
    private func setupGestureRecognizers() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(togglePlayPause)))
    }
    
    private func setupVolumeIconTap() {
        volumeIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(volumeIconTapped)))
    }
    
    @objc private func playerDidFinishPlaying() {
        player.seek(to: .zero)
        isPlaying = false
    }
    
    @objc private func progressSliderChanged() {
        guard let duration = player.currentItem?.duration.seconds, duration > 0 else { return }
        let value = Double(progressSlider.value) * duration
        player.seek(to: CMTime(seconds: value, preferredTimescale: 600))
    }
    
    @objc private func volumeSliderChanged() {
        player.volume = volumeSlider.value
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
        if player.timeControlStatus == .paused && player.currentTime() >= player.currentItem!.duration {
            player.seek(to: .zero)
        }
        isPlaying.toggle()
    }
    
    private func updateTimeLabel(currentTime: Double, duration: Double) {
        func format(_ sec: Double) -> String {
            let s = Int(sec)
            return String(format: "%02d:%02d", s / 60, s % 60)
        }
        timeLabel.text = "\(format(currentTime)) / \(format(duration))"
    }
    
    private func updateSpeedButtons() {
        for case let button as UIButton in speedStackView.arrangedSubviews {
            let speed = Float(button.tag) / 10.0
            button.backgroundColor = (speed == selectedSpeed) ? .systemGreen : UIColor.white.withAlphaComponent(0.2)
        }
    }
    
    deinit {
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
        }
        NotificationCenter.default.removeObserver(self)
    }
}
