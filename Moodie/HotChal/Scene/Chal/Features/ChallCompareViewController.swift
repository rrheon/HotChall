//
//  ChallCompareViewController.swift
//  HotChal
//
//  Created by 이지훈 on 8/1/25.
//

import UIKit
import AVFoundation
import Photos

class ChallCompareViewController: UIViewController {

    var subVideoFilename: String?
    var coordinator: ChalCoordinator?
    var videoURL: URL?

    private var mainVideoPlayer: ChallCompareLoopedVideoPlayer!
    private var isPlaying = true

    private let challCompareMainView = makeView(backgroundColor: .systemBackground)
    private let challCompareSubView = ChallComparSubView()

    private let bottomBarView = makeView(backgroundColor: .appPink.withAlphaComponent(0.8))
    private let pauseButton = makeButton(icon: "pause", title: "일시정지", color: .appCharcoal)
    private let deleteButton = makeButton(icon: "camera", title: "다시찍기", color: .appCharcoal)
    private let shareButton = makeButton(icon: "square.and.arrow.up", title: "공유하기", color: .appCharcoal)
    private let savedButton = makeButton(icon: "square.and.arrow.down", title: "저장하기", color: .appCharcoal)
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        let image = UIImage(systemName: "chevron.backward", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .appPink.withAlphaComponent(0.8)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true

        return button
    }()

    // ✅ 네비게이션 바 숨기기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupViews()
        setupConstraints()
        setupActions()

        mainVideoPlayer = ChallCompareLoopedVideoPlayer(containerView: challCompareMainView, isMuted: false, isMain: true)

        if let url = videoURL {
            mainVideoPlayer.setupVideo(url) { [weak self] _ in
                self?.mainVideoPlayer.updateFrame()
            }
        } else {
            playCameraResultVideo(url: nil)
        }

        if let filename = subVideoFilename {
            challCompareSubView.setupVideo(named: filename) { [weak self] aspectRatio in
                guard let self = self else { return }
                let width: CGFloat = 140
                let height = width * aspectRatio
                let safeFrame = self.view.safeAreaLayoutGuide.layoutFrame
                self.challCompareSubView.frame = CGRect(x: safeFrame.maxX - width - 10,
                                                        y: safeFrame.minY + 10,
                                                        width: width,
                                                        height: height)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainVideoPlayer.updateFrame()
        challCompareSubView.videoPlayer.updateFrame()
        backButton.layer.cornerRadius = backButton.bounds.width / 2

    }

    private func setupViews() {
        view.addSubview(challCompareMainView)
        view.addSubview(challCompareSubView)
        view.addSubview(bottomBarView)
        view.addSubview(backButton)
        [pauseButton, deleteButton, shareButton, savedButton].forEach { bottomBarView.addSubview($0) }
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
            bottomBarView.heightAnchor.constraint(equalToConstant: 90),

            deleteButton.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor, constant: -13),
            deleteButton.trailingAnchor.constraint(equalTo: savedButton.leadingAnchor, constant: -24),

            savedButton.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor, constant: -13),
            savedButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -12),

            pauseButton.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor, constant: -13),
            pauseButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 12),
            pauseButton.widthAnchor.constraint(equalToConstant: 70),

            shareButton.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor, constant: -13),
            shareButton.leadingAnchor.constraint(equalTo: pauseButton.trailingAnchor, constant: 24),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func setupActions() {
        pauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        savedButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        challCompareMainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(swapVideoLayers)))
        challCompareSubView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(swapVideoLayers)))
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func togglePlayPause() {
        mainVideoPlayer.togglePlayPause()
        challCompareSubView.videoPlayer.togglePlayPause()
        isPlaying.toggle()

        let iconName = isPlaying ? "pause" : "play"
        let title = isPlaying ? "일시정지" : "재생"

        if var config = pauseButton.configuration {
            config.image = UIImage(systemName: iconName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .regular))
            var titleContainer = AttributeContainer()
            titleContainer.font = UIFont.systemFont(ofSize: 12)
            config.attributedTitle = AttributedString(title, attributes: titleContainer)
            pauseButton.configuration = config
        }
    }

    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(title: "다시 촬영하시겠습니까?", message: "저장하지 않은 영상은 삭제됩니다", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "재촬영", style: .destructive) { [weak self] _ in
            guard let self = self else { return }

            self.coordinator?.currentSubVideoFilename = self.subVideoFilename
            self.navigationController?.popViewController(animated: false)
            self.coordinator?.navToTakeChallengeViewController()
        })
        present(alert, animated: true)
    }

    @objc private func shareButtonTapped() {
        guard let videoURL = videoURL else { return }
        let activityVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = shareButton
        present(activityVC, animated: true)
    }

    @objc private func saveButtonTapped() {
        guard let url = videoURL else {
            showAlert(title: "오류", message: "저장할 영상이 없습니다.")
            return
        }
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized, .limited:
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .video, fileURL: url, options: options)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            self.showAlert(title: "저장 완료", message: "영상이 저장되었습니다.")
                        } else {
                            self.showAlert(title: "저장 실패", message: error?.localizedDescription ?? "알 수 없는 오류가 발생했습니다.")
                        }
                    }
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.showAlert(title: "권한 필요", message: "사진 앱 접근 권한이 필요합니다. 설정에서 허용해주세요.")
                }
            default:
                break
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "확인", style: .default))
        present(alertVC, animated: true)
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

            self.mainVideoPlayer = tempSub
            self.challCompareSubView.videoPlayer = tempMain
        }
    }

    func playCameraResultVideo(url: URL?) {
        mainVideoPlayer.playerLayer?.removeFromSuperlayer()
        challCompareMainView.subviews.filter { $0 is UILabel }.forEach { $0.removeFromSuperview() }

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
    config.image = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
    config.title = title
    config.imagePlacement = .top
    config.imagePadding = 5
    config.baseForegroundColor = color

    var container = AttributeContainer()
    container.font = UIFont.systemFont(ofSize: 13)
    config.attributedTitle = AttributedString(title, attributes: container)

    return config
}

@available(iOS 17.0, *)
#Preview {
    UINavigationController(rootViewController: ChallCompareViewController())
}
