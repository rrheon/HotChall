//
//  ChallCompareViewController.swift
//  HotChal
//
//  Created by 이지훈 on 8/1/25.
//

import UIKit
import AVFoundation
import Photos
import RxSwift
import RxCocoa

class ChallCompareViewController: UIViewController {

    var subVideoFilename: String?
    weak var coordinator: ChallengeNavigationDelegate?
    var videoURL: URL?

    var reactor: ChallCompareReactor? = nil
    private let disposeBag: DisposeBag = DisposeBag()

    private var mainVideoPlayer: ChallCompareLoopedVideoPlayer!

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

        mainVideoPlayer = ChallCompareLoopedVideoPlayer(containerView: challCompareMainView, isMuted: false, isMain: true)

        print("🎯 subVideoFilename:", subVideoFilename ?? "nil")
        print("🎯 videoURL:", videoURL?.absoluteString ?? "nil")

        if let url = videoURL {
            mainVideoPlayer.setupVideo(url) { [weak self] _ in
                self?.mainVideoPlayer.updateFrame()
            }
        } else {
            playCameraResultVideo(url: nil)
        }

        if let filename = subVideoFilename, !filename.isEmpty {
            challCompareSubView.setupVideo(named: filename) { [weak self] aspectRatio in
                guard let self = self else { return }
                let width: CGFloat = 140
                let height = width * aspectRatio
                let safeFrame = self.view.safeAreaLayoutGuide.layoutFrame
                self.challCompareSubView.frame = CGRect(
                    x: safeFrame.maxX - width - 10,
                    y: safeFrame.minY + 10,
                    width: width,
                    height: height
                )
            }
        } else {
            // [FIX] 파일명이 없더라도 서브뷰가 0사이즈가 되지 않도록 기본 프레임 지정
            let width: CGFloat = 140
            let height: CGFloat = 200
            let safeFrame = self.view.safeAreaLayoutGuide.layoutFrame
            self.challCompareSubView.frame = CGRect(
                x: safeFrame.maxX - width - 10,
                y: safeFrame.minY + 10,
                width: width,
                height: height
            )
        }

        let reactor = reactor ?? ChallCompareReactor()
        self.reactor = reactor
        bind(with: reactor)
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

    // MARK: bind

    private func bind(with reactor: ChallCompareReactor) {
        // 초기 데이터 로드
        Observable.just(())
            .map { [weak self] in
                ChallCompareReactor.Action.setupInitialData(
                    videoURL: self?.videoURL,
                    subVideoFilename: self?.subVideoFilename
                )
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 재생/일시정지 버튼
        pauseButton.rx.tap
            .map { ChallCompareReactor.Action.togglePlayPause }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 다시찍기 버튼
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showRetakeAlert()
            })
            .disposed(by: disposeBag)

        // 공유하기 버튼
        shareButton.rx.tap
            .map { ChallCompareReactor.Action.requestShare }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 저장하기 버튼
        savedButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.saveButtonTapped()
            })
            .disposed(by: disposeBag)

        // 뒤로가기 버튼
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        // 비디오 스왑 제스처
        let mainTap = UITapGestureRecognizer()
        challCompareMainView.addGestureRecognizer(mainTap)
        mainTap.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.swapVideoLayers()
            })
            .disposed(by: disposeBag)

        let subTap = UITapGestureRecognizer()
        challCompareSubView.addGestureRecognizer(subTap)
        subTap.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.swapVideoLayers()
            })
            .disposed(by: disposeBag)

        // State 바인딩 - 재생 상태
        reactor.state.map { $0.isPlaying }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isPlaying in
                self?.updatePlayPauseUI(isPlaying: isPlaying)
                self?.mainVideoPlayer.togglePlayPause()
                self?.challCompareSubView.videoPlayer.togglePlayPause()
            })
            .disposed(by: disposeBag)

        // State 바인딩 - 네비게이션
        reactor.state.compactMap { $0.navigation }
            .subscribe(onNext: { [weak self] event in
                self?.handleNavigation(event)
            })
            .disposed(by: disposeBag)

        // State 바인딩 - 알림
        reactor.state
            .filter { $0.alertTitle != nil && $0.alertMessage != nil }
            .subscribe(onNext: { [weak self] state in
                if let title = state.alertTitle, let message = state.alertMessage {
                    self?.showAlert(title: title, message: message)
                    reactor.action.onNext(.clearAlert)
                }
            })
            .disposed(by: disposeBag)
    }

    private func updatePlayPauseUI(isPlaying: Bool) {
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

    private func handleNavigation(_ event: ChallCompareReactor.ChallCompareNavigationEvent) {
        switch event {
        case .retake(let subVideoFilename):
            mainVideoPlayer?.queuePlayer?.pause()
            challCompareSubView.videoPlayer.queuePlayer?.pause()

            guard let coordinator = coordinator else { return }

            DispatchQueue.main.async {
                CATransaction.begin()
                CATransaction.setCompletionBlock { [weak self] in
                    guard self != nil else { return }
                    coordinator.navToTakeChallengeViewController(
                        audioFileName: "",
                        subVideoFilename: subVideoFilename
                    )
                }
                self.navigationController?.popViewController(animated: true)
                CATransaction.commit()
            }

        case .share(let videoURL):
            let activityVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = shareButton
            present(activityVC, animated: true)

        case .back:
            navigationController?.popViewController(animated: true)
        }
    }

    private func showRetakeAlert() {
        let alert = UIAlertController(title: "다시 촬영하시겠습니까?", message: "저장하지 않은 영상은 삭제됩니다", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        alert.addAction(UIAlertAction(title: "재촬영", style: .destructive) { [weak self] _ in
            self?.reactor?.action.onNext(.requestRetake)
        })
        present(alert, animated: true)
    }

    private func saveButtonTapped() {
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

    private func swapVideoLayers() {
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
