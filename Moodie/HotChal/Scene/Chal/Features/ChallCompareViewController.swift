//
//  ChallCompareViewController.swift
//  HotChal
//
//  Created by 이지훈 on 8/1/25.
//

import UIKit
import AVFoundation

class LoopedVideoPlayer {
    var queuePlayer: AVQueuePlayer?
    var looper: AVPlayerLooper?
    var playerLayer: AVPlayerLayer?
    var containerView: UIView
    var isMuted: Bool
    var isMain: Bool

    init(containerView: UIView, isMuted: Bool = true, isMain: Bool = false) {
        self.containerView = containerView
        self.isMuted = isMuted
        self.isMain = isMain
    }

    func setupVideo(named fileName: String, completion: ((CGFloat) -> Void)? = nil) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else { return }
        let url = URL(fileURLWithPath: path)
        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: item)
        let looper = AVPlayerLooper(player: player, templateItem: item)
        let layer = AVPlayerLayer(player: player)

        layer.frame = containerView.bounds
        layer.videoGravity = isMain ? .resizeAspectFill : .resizeAspect

        containerView.layer.addSublayer(layer)

        self.queuePlayer = player
        self.looper = looper
        self.playerLayer = layer

        player.isMuted = isMuted
        player.play()

        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
            guard let track = asset.tracks(withMediaType: .video).first else { return }
            let size = track.naturalSize.applying(track.preferredTransform)
            let aspectRatio = abs(size.height / size.width)
            DispatchQueue.main.async {
                completion?(aspectRatio)
            }
        }
    }

    func updateFrame() {
        guard let layer = playerLayer else { return }
        DispatchQueue.main.async {
            layer.frame = self.containerView.bounds
            layer.videoGravity = self.isMain ? .resizeAspectFill : .resizeAspect
        }
    }

    func togglePlayPause() {
        guard let player = queuePlayer else { return }
        player.timeControlStatus == .playing ? player.pause() : player.play()
    }

    func setMuted(_ muted: Bool) {
        queuePlayer?.isMuted = muted
        isMuted = muted
    }
}

class ChallCompareViewController: UIViewController {

    private var mainVideoPlayer: LoopedVideoPlayer!
    private var subVideoPlayer: LoopedVideoPlayer!
    private var challComparSubViewHeightConstraint: NSLayoutConstraint?
    private var isPlaying: Bool = true

    private let challComparMainView = makeView(backgroundColor: .systemBackground)
    private let challComparSubView = makeView(backgroundColor: .systemBackground, cornerRadius: 15)
    private let bottomBarView = makeView(backgroundColor: UIColor(red: 255/255, green: 199/255, blue: 194/255, alpha: 0.8))

    private let pauseButton = makeBottomButton(icon: "pause.circle", title: "일시정지", color: .systemBlue)
    private let deleteButton = makeBottomButton(icon: "trash.circle", title: "삭제", color: .systemRed)
    private let shareButton = makeBottomButton(icon: "square.and.arrow.up.circle", title: "공유하기", color: .systemBlue)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupViews()
        setupConstraints()
        setupActions()

        mainVideoPlayer = LoopedVideoPlayer(containerView: challComparMainView, isMuted: false, isMain: true)
        subVideoPlayer = LoopedVideoPlayer(containerView: challComparSubView, isMuted: true, isMain: false)

        mainVideoPlayer.setupVideo(named: "nemonemo.mp4")
        subVideoPlayer.setupVideo(named: "nemonemo2.mp4") { aspectRatio in
            self.challComparSubViewHeightConstraint?.isActive = false
            self.challComparSubViewHeightConstraint = self.challComparSubView.heightAnchor.constraint(equalTo: self.challComparSubView.widthAnchor, multiplier: aspectRatio)
            self.challComparSubViewHeightConstraint?.isActive = true
            self.view.layoutIfNeeded()
        }
    }

    private func setupViews() {
        [challComparMainView, challComparSubView, bottomBarView].forEach { view.addSubview($0) }
        [pauseButton, deleteButton, shareButton].forEach { bottomBarView.addSubview($0) }
    }

    private func setupConstraints() {
        challComparSubViewHeightConstraint = challComparSubView.heightAnchor.constraint(equalToConstant: 100)
        challComparSubViewHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            challComparMainView.topAnchor.constraint(equalTo: view.topAnchor),
            challComparMainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            challComparMainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            challComparMainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            challComparSubView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            challComparSubView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            challComparSubView.widthAnchor.constraint(equalToConstant: 150),

            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: 85),

            pauseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            pauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: pauseButton.centerYAnchor),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -view.bounds.width * 0.28),
            shareButton.centerYAnchor.constraint(equalTo: pauseButton.centerYAnchor),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.bounds.width * 0.28),
        ])
    }

    private func setupActions() {
        pauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)

        challComparMainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(swapVideoLayers)))
        challComparSubView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(swapVideoLayers)))
    }

    @objc private func togglePlayPause() {
        [mainVideoPlayer, subVideoPlayer].forEach { $0?.togglePlayPause() }
        isPlaying.toggle()
        let icon = isPlaying ? "pause.circle" : "play.circle"
        let title = isPlaying ? "일시정지" : "재생"
        pauseButton.configuration = makeButtonConfig(icon: icon, title: title, color: .systemBlue)
    }

    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(title: "정말로 삭제하시겠습니까?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive))
        present(alert, animated: true)
    }

    @objc private func shareButtonTapped() {
        guard let path = Bundle.main.path(forResource: "nemonemo", ofType: "mp4") else { return }
        let videoURL = URL(fileURLWithPath: path)
        let activityVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = shareButton.frame
        }

        present(activityVC, animated: true)
    }

    @objc private func swapVideoLayers() {
        mainVideoPlayer.playerLayer?.removeFromSuperlayer()
        subVideoPlayer.playerLayer?.removeFromSuperlayer()
        challComparMainView.layer.addSublayer(subVideoPlayer.playerLayer!)
        challComparSubView.layer.addSublayer(mainVideoPlayer.playerLayer!)

        mainVideoPlayer.isMain = false
        subVideoPlayer.isMain = true
        swap(&mainVideoPlayer.containerView, &subVideoPlayer.containerView)
        swap(&mainVideoPlayer, &subVideoPlayer)
        mainVideoPlayer.setMuted(false)
        subVideoPlayer.setMuted(true)

        mainVideoPlayer.updateFrame()
        subVideoPlayer.updateFrame()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainVideoPlayer.updateFrame()
        subVideoPlayer.updateFrame()
    }
}

private func makeView(backgroundColor: UIColor, cornerRadius: CGFloat = 0) -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = backgroundColor
    if cornerRadius > 0 {
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
    }
    return view
}

private func makeBottomButton(icon: String, title: String, color: UIColor) -> UIButton {
    let config = makeButtonConfig(icon: icon, title: title, color: color)
    let button = UIButton(configuration: config)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
}

private func makeButtonConfig(icon: String, title: String, color: UIColor) -> UIButton.Configuration {
    var config = UIButton.Configuration.plain()
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
    config.image = UIImage(systemName: icon, withConfiguration: symbolConfig)
    config.title = title
    config.imagePlacement = .top
    config.imagePadding = 5
    config.baseForegroundColor = color
    config.attributedTitle = AttributedString(title, attributes: AttributeContainer([
        .font: UIFont.systemFont(ofSize: 15, weight: .regular)
    ]))
    return config
}

@available(iOS 17.0, *)
#Preview {
    UINavigationController(rootViewController: ChallCompareViewController())
}
