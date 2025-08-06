//
//  ChallCompareViewController.swift
//  HotChal
//
//  Created by 이지훈 on 8/1/25.
//

import UIKit
import AVFoundation

class ChallCompareViewController: UIViewController {

    private var mainVideoPlayer: ChallCompareLoopedVideoPlayer!
    private var isPlaying = true

    private let challComparMainView = makeView(backgroundColor: .systemBackground)
    private let challComparSubView = ChallComparSubView()
    private let bottomBarView = makeView(backgroundColor: UIColor(red: 255/255, green: 199/255, blue: 194/255, alpha: 0.8))

    private let pauseButton = makeButton(icon: "pause.circle", title: "일시정지", color: .systemBlue)
    private let deleteButton = makeButton(icon: "trash.circle", title: "삭제", color: .systemRed)
    private let shareButton = makeButton(icon: "square.and.arrow.up.circle", title: "공유하기", color: .systemBlue)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupViews()
        setupConstraints()
        setupActions()

        mainVideoPlayer = ChallCompareLoopedVideoPlayer(containerView: challComparMainView, isMuted: false, isMain: true)
        mainVideoPlayer.setupVideo(named: "karina1.mp4")

        challComparSubView.setupVideo(named: "asepa1.mp4") { [weak self] aspectRatio in
            guard let self = self else { return }
            let width: CGFloat = 140
            let height = width * aspectRatio
            let safeFrame = self.view.safeAreaLayoutGuide.layoutFrame
            self.challComparSubView.frame = CGRect(x: safeFrame.maxX - width - 10, y: safeFrame.minY + 10, width: width, height: height)
        }
    }

    private func setupViews() {
        view.addSubview(challComparMainView)
        view.addSubview(challComparSubView)
        view.addSubview(bottomBarView)
        [pauseButton, deleteButton, shareButton].forEach { bottomBarView.addSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            challComparMainView.topAnchor.constraint(equalTo: view.topAnchor),
            challComparMainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            challComparMainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            challComparMainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: 85),

            pauseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            pauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: pauseButton.centerYAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            shareButton.centerYAnchor.constraint(equalTo: pauseButton.centerYAnchor),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
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
        mainVideoPlayer.togglePlayPause()
        challComparSubView.videoPlayer.togglePlayPause()
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

        activityVC.popoverPresentationController?.sourceView = shareButton
        present(activityVC, animated: true)
    }

    @objc private func swapVideoLayers() {
        let tempMain = mainVideoPlayer!
        let tempSub = challComparSubView.videoPlayer

        tempMain.playerLayer?.removeFromSuperlayer()
        tempSub.playerLayer?.removeFromSuperlayer()

        tempMain.setMuted(true)
        tempSub.setMuted(false)

        tempMain.isMain = false
        tempSub.isMain = true

        tempSub.containerView = challComparMainView
        tempMain.containerView = challComparSubView

        challComparMainView.layer.addSublayer(tempSub.playerLayer!)
        challComparSubView.layer.addSublayer(tempMain.playerLayer!)

        tempMain.updateFrame()
        tempSub.updateFrame()

        mainVideoPlayer = tempSub
        challComparSubView.videoPlayer = tempMain
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainVideoPlayer.updateFrame()
        challComparSubView.videoPlayer.updateFrame()
    }
}

private func makeView(backgroundColor: UIColor, cornerRadius: CGFloat = 0) -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = backgroundColor
    view.layer.cornerRadius = cornerRadius
    view.layer.masksToBounds = cornerRadius > 0
    return view
}

private func makeButton(icon: String, title: String, color: UIColor) -> UIButton {
    let config = makeButtonConfig(icon: icon, title: title, color: color)
    let button = UIButton(configuration: config)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
}

private func makeButtonConfig(icon: String, title: String, color: UIColor) -> UIButton.Configuration {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular))
    config.title = title
    config.imagePlacement = .top
    config.imagePadding = 5
    config.baseForegroundColor = color

    var container = AttributeContainer()
    container.font = UIFont.systemFont(ofSize: 15)
    config.attributedTitle = AttributedString(title, attributes: container)

    return config
}

@available(iOS 17.0, *)
#Preview {
    UINavigationController(rootViewController: ChallCompareViewController())
}
