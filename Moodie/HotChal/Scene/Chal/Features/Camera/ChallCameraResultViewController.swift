//
//  ChallCamera.swift
//  HotChal
//
//  Created by heojiwoo on 8/6/25.
//

import UIKit
import AVFoundation

protocol ChallCameraResultViewDelegate: AnyObject {
    func cameraResultViewClose(_ view: ChallCameraResultView)
    func cameraResultViewSave(_ view: ChallCameraResultView, didTapSaveWith videoURL: URL)
}

final class ChallCameraResultView: UIView {
    private let videoURL: URL
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    weak var delegate: ChallCameraResultViewDelegate?

    private var isPlaying = true
    
    // MARK: - UI
    private let bottomStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints  = false
        return stack
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다시 찍기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(frame: .zero)
        setupPlayer()
        setupUI()
        setupGesture()
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }

    @objc private func replay() {
        player?.seek(to: .zero)
        player?.play()
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(playPausePressed))
        self.addGestureRecognizer(tap)
    }
    
    // MARK: - Video
    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        if let layer = playerLayer {
            self.layer.addSublayer(layer)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(replay),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )

        player?.play()
    }

    // MARK: - UI Setup
    private func setupUI() {
        addSubview(bottomStackView)
        addSubview(playPauseButton)
        bottomStackView.addArrangedSubview(closeButton)
        bottomStackView.addArrangedSubview(saveButton)
        
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPausePressed), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            bottomStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            bottomStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            bottomStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomStackView.heightAnchor.constraint(equalToConstant: 44),
            
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 50),
            playPauseButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func closePressed() {
        delegate?.cameraResultViewClose(self)
    }

    @objc private func savePressed() {
        delegate?.cameraResultViewSave(self, didTapSaveWith: videoURL)
    }
    
    @objc private func playPausePressed() {
        isPlaying.toggle()
        isPlaying ? player?.play() : player?.pause()
        
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        
        playPauseButton.setImage(UIImage(systemName: iconName), for: .normal)
        playPauseButton.isHidden = false
        
        if isPlaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                guard let self = self, self.isPlaying else { return }
                self.playPauseButton.isHidden = true
            }
        }
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



