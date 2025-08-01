//
//  Player.swift
//  HotChal
//
//  Created by jonghyuck on 8/1/25.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private let playerView = UIView()
    var videoURL: URL?
    var videoTitle: String?
    var uploaderName: String?
    
    var infoLabelAlpha: CGFloat = 0 // 기본값 (외부에서 조정 가능)
    private var hasFinishedPlaying = false
    
    private let playbackSlider = UISlider()
    private let volumeSlider = UISlider()
    private let speedSegment = UISegmentedControl(items: ["0.5x", "1.0x", "1.5x", "2.0x"])
    private let playPauseButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to set audio session: \(error)")
            }
        
        setupPlayer()
        setupControls()
        setupInfoLabels()
        startTrackingSlider()
        addTapGestureForPlayPause()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(videoDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    private func setupInfoLabels() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 12
        blurView.clipsToBounds = true
        blurView.backgroundColor = UIColor.black.withAlphaComponent(infoLabelAlpha) // 외부 조정 가능

        
        let titleLabel = UILabel()
        titleLabel.text = videoTitle ?? "제목 없음"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 1
        
        let uploaderLabel = UILabel()
        uploaderLabel.text = uploaderName ?? "업로더 없음"
        uploaderLabel.textColor = .lightGray
        uploaderLabel.font = UIFont.systemFont(ofSize: 13)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, uploaderLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.contentView.addSubview(stack)
        view.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -8),
            
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            blurView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            blurView.bottomAnchor.constraint(equalTo: playbackSlider.topAnchor, constant: -10) // 재생바 위로 16pt 올림
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = playerView.bounds
    }

    private func setupPlayer() {
        guard let url = videoURL else {
            print("videoURL이 설정되지 않았습니다.")
            return
        }

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player.volume = 1.0

        // ✅ playerLayer를 UIView 위에 붙이기
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect

        playerView.layer.addSublayer(playerLayer)
        view.addSubview(playerView)

        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 16.0/9.0) // 16:9 비율
        ])

        // Layer는 layoutSubviews에서 사이즈 맞추기
        view.setNeedsLayout()

        player.play()
    }

    private func setupControls() {
        playbackSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        volumeSlider.addTarget(self, action: #selector(volumeChanged), for: .valueChanged)
        speedSegment.addTarget(self, action: #selector(speedChanged), for: .valueChanged)
        speedSegment.selectedSegmentIndex = 1

        // 재생바 스타일
        playbackSlider.minimumTrackTintColor = UIColor.systemBlue
        playbackSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        playbackSlider.thumbTintColor = UIColor.systemBlue
        
        // 볼륨 슬라이더 스타일 & 크기 조절
        volumeSlider.minimumTrackTintColor = UIColor.systemGreen
        volumeSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        volumeSlider.thumbTintColor = UIColor.systemGreen
        volumeSlider.value = 1.0
        
        volumeSlider.transform = CGAffineTransform(scaleX: 1.0, y: 0.6) // 슬라이더 높이 축소
        
        let stack = UIStackView(arrangedSubviews: [playbackSlider, volumeSlider, speedSegment])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func addTapGestureForPlayPause() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(togglePlayPause))
            view.addGestureRecognizer(tapGesture)
        }

    @objc private func togglePlayPause() {
        if hasFinishedPlaying {
            player.seek(to: .zero)
            player.play()
            hasFinishedPlaying = false
        } else {
            if player.timeControlStatus == .playing {
                player.pause()
            } else {
                player.play()
            }
        }
    }

    @objc private func sliderValueChanged() {
        let duration = player.currentItem?.duration.seconds ?? 0
        let newTime = CMTime(seconds: Double(playbackSlider.value) * duration, preferredTimescale: 600)
        player.seek(to: newTime)
    }

    @objc private func volumeChanged() {
        player.volume = volumeSlider.value
        print("Volume changed to \(player.volume)")
    }

    @objc private func speedChanged() {
        let speeds: [Float] = [0.5, 1.0, 1.5, 2.0]
        player.rate = player.timeControlStatus == .paused ? 0 : speeds[speedSegment.selectedSegmentIndex]
    }

    private func startTrackingSlider() {
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = self.player.currentItem?.duration.seconds, duration > 0 else { return }
            self.playbackSlider.value = Float(time.seconds / duration)
        }
    }
    
    @objc private func videoDidFinishPlaying() {
        hasFinishedPlaying = true
        playbackSlider.value = 0 // 끝까지 갔다는 의미로 슬라이더 유지
    }
    
    func setVideo(url: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
    }
}


