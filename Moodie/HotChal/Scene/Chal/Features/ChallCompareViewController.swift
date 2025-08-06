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

    private var videoURL: URL?
    public var incomingVideoFilename: String?

    private let challCompareMainView = makeView(backgroundColor: .systemBackground)
    private let challCompareSubView = ChallComparSubView()

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

        mainVideoPlayer = ChallCompareLoopedVideoPlayer(containerView: challCompareMainView, isMuted: false, isMain: true)

        if let url = videoURL {
            mainVideoPlayer.setupVideo(url) { [weak self] aspectRatio in
                guard let self = self else { return }
            }
        } else {
            playCameraResultVideo(url: nil)
        }

        challCompareSubView.setupVideo(named: "asepa1.mp4") { [weak self] aspectRatio in
            guard let self = self else { return }
            let width: CGFloat = 140
            let height = width * aspectRatio
            let safeFrame = self.view.safeAreaLayoutGuide.layoutFrame
            self.challCompareSubView.frame = CGRect(x: safeFrame.maxX - width - 10, y: safeFrame.minY + 10, width: width, height: height)
        }
    }

    private func setupViews() {
        view.addSubview(challCompareMainView)
        view.addSubview(challCompareSubView)
        view.addSubview(bottomBarView)
        [pauseButton, deleteButton, shareButton].forEach { bottomBarView.addSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            challCompareMainView.topAnchor.constraint(equalTo: view.topAnchor),
            challCompareMainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            challCompareMainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            challCompareMainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

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

        challCompareMainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(swapVideoLayers)))
        challCompareSubView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(swapVideoLayers)))
    }

    @objc private func togglePlayPause() {
        mainVideoPlayer.togglePlayPause()
        challCompareSubView.videoPlayer.togglePlayPause()
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
        guard let videoURL = videoURL else { return }
        let activityVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = shareButton
        present(activityVC, animated: true)
    }

    @objc private func swapVideoLayers() {
        let tempMain = mainVideoPlayer!
        let tempSub = challCompareSubView.videoPlayer

        DispatchQueue.main.async {
            tempMain.playerLayer?.removeFromSuperlayer()
            tempSub.playerLayer?.removeFromSuperlayer()

            tempSub.containerView = self.challCompareMainView
            tempMain.containerView = self.challCompareSubView

            tempMain.setMuted(true)
            tempSub.setMuted(false)
            tempMain.isMain = false
            tempSub.isMain = true

            if let subLayer = tempSub.playerLayer {
                self.challCompareMainView.layer.addSublayer(subLayer)
            }

            if let mainLayer = tempMain.playerLayer {
                self.challCompareSubView.layer.addSublayer(mainLayer)
            }

            tempMain.updateFrame()
            tempSub.updateFrame()

            // 참조 교체
            self.mainVideoPlayer = tempSub
            self.challCompareSubView.videoPlayer = tempMain
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainVideoPlayer.updateFrame()
        challCompareSubView.videoPlayer.updateFrame()
    }

    func playCameraResultVideo(url: URL?) {
        mainVideoPlayer.playerLayer?.removeFromSuperlayer()
        challCompareMainView.subviews.forEach { $0.removeFromSuperview() }

        if let url = url {
            self.videoURL = url
            mainVideoPlayer.setupVideo(url)
        } else {
            challCompareMainView.backgroundColor = .black

            let label = UILabel()
            label.text = "파일을 불러 올 수 없습니다"
            label.textAlignment = .center
            label.textColor = .white
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false

            challCompareMainView.addSubview(label)

            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: challCompareMainView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: challCompareMainView.centerYAnchor)
            ])

            challCompareMainView.layoutIfNeeded()
        }
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
