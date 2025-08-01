//
//  Player.swift
//  HotChal
//
//  Created by jonghyuck on 8/1/25.
//

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

    var videoURL: URL?
    var videoTitle: String?
    var uploaderName: String?

    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!

    private let infoStackView = UIStackView()
    private let titleLabel = UILabel()
    private let uploaderLabel = UILabel()

    private let playbackSlider = UISlider()
    private var timeObserverToken: Any?

    private let volumeViewContainer = UIView()
    private let systemVolumeView = MPVolumeView()
    private let volumeButton = UIButton(type: .system)
    private var volumeVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }

        setupPlayer()
        setupPlaybackSlider()
        setupInfoLabel()
        setupVolumeSlider()
        setupVolumeButton()
        setupTapGesture()
    }

    private func setupPlayer() {
        guard let url = videoURL else { return }
        player = AVPlayer(url: url)

        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(playerLayer, at: 0)

        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self else { return }
            let duration = self.player.currentItem?.duration.seconds ?? 0
            if duration > 0 {
                self.playbackSlider.value = Float(time.seconds / duration)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        player.play()
    }

    @objc private func playerDidFinishPlaying() {
        player.seek(to: .zero)
        playbackSlider.value = 0
    }

    private func setupInfoLabel() {
        titleLabel.text = videoTitle ?? "제목 없음"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0

        uploaderLabel.text = uploaderName ?? "업로더"
        uploaderLabel.textColor = .lightGray
        uploaderLabel.font = UIFont.systemFont(ofSize: 14)
        uploaderLabel.textAlignment = .left
        uploaderLabel.numberOfLines = 0

        infoStackView.axis = .vertical
        infoStackView.alignment = .leading
        infoStackView.spacing = 2
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        infoStackView.layer.cornerRadius = 8
        infoStackView.layoutMargins = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        infoStackView.isLayoutMarginsRelativeArrangement = true

        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(uploaderLabel)
        view.addSubview(infoStackView)

        NSLayoutConstraint.activate([
            infoStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoStackView.bottomAnchor.constraint(equalTo: playbackSlider.topAnchor, constant: -20),
        ])
    }

    private func setupPlaybackSlider() {
        playbackSlider.translatesAutoresizingMaskIntoConstraints = false
        playbackSlider.minimumTrackTintColor = .white
        playbackSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        playbackSlider.thumbTintColor = .white
        playbackSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        view.addSubview(playbackSlider)

        NSLayoutConstraint.activate([
            playbackSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playbackSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            playbackSlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func sliderValueChanged() {
        guard let duration = player.currentItem?.duration else { return }
        let newTime = CMTime(seconds: Double(playbackSlider.value) * duration.seconds, preferredTimescale: 600)
        player.seek(to: newTime)
    }

    private func setupVolumeSlider() {
        volumeViewContainer.translatesAutoresizingMaskIntoConstraints = false
        volumeViewContainer.alpha = 0
        view.addSubview(volumeViewContainer)

        NSLayoutConstraint.activate([
            volumeViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            volumeViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            volumeViewContainer.widthAnchor.constraint(equalToConstant: 150),
            volumeViewContainer.heightAnchor.constraint(equalToConstant: 40)
        ])

        systemVolumeView.translatesAutoresizingMaskIntoConstraints = false
        systemVolumeView.showsRouteButton = false
        volumeViewContainer.addSubview(systemVolumeView)

        NSLayoutConstraint.activate([
            systemVolumeView.topAnchor.constraint(equalTo: volumeViewContainer.topAnchor),
            systemVolumeView.leadingAnchor.constraint(equalTo: volumeViewContainer.leadingAnchor),
            systemVolumeView.trailingAnchor.constraint(equalTo: volumeViewContainer.trailingAnchor),
            systemVolumeView.bottomAnchor.constraint(equalTo: volumeViewContainer.bottomAnchor)
        ])

        for view in systemVolumeView.subviews {
            if let button = view as? UIButton {
                button.isHidden = true
            } else if let slider = view as? UISlider {
                slider.minimumTrackTintColor = .systemGreen
                slider.maximumTrackTintColor = .lightGray
                slider.thumbTintColor = .systemGreen
                slider.value = 1.0
                slider.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
            }
        }
    }

    private func setupVolumeButton() {
        volumeButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        volumeButton.tintColor = .white
        volumeButton.translatesAutoresizingMaskIntoConstraints = false
        volumeButton.addTarget(self, action: #selector(toggleVolumeSlider), for: .touchUpInside)
        view.addSubview(volumeButton)

        NSLayoutConstraint.activate([
            volumeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            volumeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            volumeButton.widthAnchor.constraint(equalToConstant: 30),
            volumeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    @objc private func toggleVolumeSlider() {
        UIView.animate(withDuration: 0.3) {
            self.volumeViewContainer.alpha = self.volumeVisible ? 0 : 1
        }
        volumeVisible.toggle()

        if volumeVisible {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                UIView.animate(withDuration: 0.3) {
                    self.volumeViewContainer.alpha = 0
                    self.volumeVisible = false
                }
            }
        }
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTapGesture() {
        if let player = player {
            if player.timeControlStatus == .paused {
                player.play()
            } else {
                player.pause()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }

    deinit {
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
        }
        NotificationCenter.default.removeObserver(self)
    }
}
