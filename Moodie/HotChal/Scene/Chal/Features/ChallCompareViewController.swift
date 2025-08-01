//
//  ChallCompareViewController.swift
//  HotChal
//
//  Created by 이지훈 on 8/1/25.
//

// 주석은 공부용으로 GPT한테 달아달라고 한거니 신경 ㄴㄴ

import UIKit
import AVFoundation

// UIViewController를 상속받은 비교 영상 재생 화면 컨트롤러
class ChallCompareViewController: UIViewController {
    
    // 메인 영상 재생용 AVPlayer와 화면에 보여주기 위한 AVPlayerLayer
    private var playerMain: AVPlayer?
    private var playerLayerMain: AVPlayerLayer?
    
    // 서브(보조) 영상 재생용 AVPlayer와 AVPlayerLayer
    private var playerSub: AVPlayer?
    private var playerLayerSub: AVPlayerLayer?
    
    // 서브 영상 뷰의 높이를 조절하기 위한 제약조건
    private var challCompareSubViewHeightConstraint: NSLayoutConstraint?
    
    // 메인 영상이 보여질 뷰
    private let challCompareMainView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground // 시스템 기본 배경색
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 서브 영상이 보여질 뷰 (모서리를 둥글게 처리)
    private let challCompareSubView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true // 둥근 모서리를 적용하기 위해 필요
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 재생/일시정지 토글 버튼
    private let pauseButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let image = UIImage(systemName: "pause.circle", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - 생명주기 함수: 뷰가 로드될 때 실행
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // 하위 뷰 및 오토레이아웃 설정
        setupViews()
        setupConstraints()
        setupActions()

        // 영상 재생 시작
        playVideoOnMainView(named: "nemonemo.mp4")
        playVideoOnSubViewWithDynamicAspectRatio(named: "nemonemo2.mp4")

        // 영상이 끝났을 때 반복 재생 설정
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(replayVideos(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    // 뷰컨트롤러가 메모리에서 해제될 때 노티 제거
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 하위 뷰 추가
    private func setupViews() {
        view.addSubview(challCompareMainView)
        view.addSubview(challCompareSubView)
        view.addSubview(pauseButton)
    }

    // MARK: - 오토레이아웃 설정
    private func setupConstraints() {
        // 서브 뷰의 높이 초기 고정값 설정 (후에 동적으로 조정)
        challCompareSubViewHeightConstraint = challCompareSubView.heightAnchor.constraint(equalToConstant: 100)
        challCompareSubViewHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            challCompareMainView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            challCompareMainView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            challCompareMainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            challCompareMainView.topAnchor.constraint(equalTo: view.topAnchor),

            challCompareSubView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            challCompareSubView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            challCompareSubView.widthAnchor.constraint(equalToConstant: 150),

            pauseButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pauseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    // MARK: - 사용자 동작 연결 (버튼, 탭 제스처)
    private func setupActions() {
        // 버튼 클릭 시 재생/정지
        pauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)

        // 메인/서브 뷰 탭 시 레이어 교환
        let mainTap = UITapGestureRecognizer(target: self, action: #selector(swapVideoLayers))
        challCompareMainView.addGestureRecognizer(mainTap)
        challCompareMainView.isUserInteractionEnabled = true

        let subTap = UITapGestureRecognizer(target: self, action: #selector(swapVideoLayers))
        challCompareSubView.addGestureRecognizer(subTap)
        challCompareSubView.isUserInteractionEnabled = true
    }

    // MARK: - 재생/일시정지 토글 함수
    @objc private func togglePlayPause() {
        guard let playerMain = playerMain, let playerSub = playerSub else { return }

        let isPlaying = playerMain.timeControlStatus == .playing
        if isPlaying {
            playerMain.pause()
            playerSub.pause()
        } else {
            playerMain.play()
            playerSub.play()
        }
        updatePauseToPlay(isPlaying: !isPlaying)
    }

    // MARK: - 버튼 이미지 업데이트
    private func updatePauseToPlay(isPlaying: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let imageName = isPlaying ? "pause.circle" : "play.circle"
        let image = UIImage(systemName: imageName, withConfiguration: config)
        pauseButton.setImage(image, for: .normal)
    }

    // MARK: - 메인/서브 영상 위치 교환 및 사운드 처리
    @objc private func swapVideoLayers() {
        guard let mainLayer = playerLayerMain, let subLayer = playerLayerSub else { return }

        mainLayer.removeFromSuperlayer()
        subLayer.removeFromSuperlayer()

        challCompareMainView.layer.addSublayer(subLayer)
        challCompareSubView.layer.addSublayer(mainLayer)

        subLayer.frame = challCompareMainView.bounds
        mainLayer.frame = challCompareSubView.bounds

        swap(&playerLayerMain, &playerLayerSub)
        swap(&playerMain, &playerSub)

        playerMain?.isMuted = false
        playerSub?.isMuted = true
    }

    // MARK: - 메인 영상의 비율에 맞춰 AVPlayerLayer 크기 조정
    private func updateMainPlayerAspectRatio(from url: URL) {
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
            DispatchQueue.main.async {
                guard let videoTrack = asset.tracks(withMediaType: .video).first else { return }
                let size = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
                let aspectRatio = abs(size.height / size.width)
                let width = self.challCompareMainView.bounds.width
                let height = width * aspectRatio
                let y = (self.challCompareMainView.bounds.height - height) / 2
                self.playerLayerMain?.frame = CGRect(x: 0, y: y, width: width, height: height)
            }
        }
    }

    // MARK: - 메인 영상 재생 (사운드 ON)
    private func playVideoOnMainView(named fileName: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            print("❌ 메인 영상 파일을 찾을 수 없음")
            return
        }
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        player.isMuted = false

        let layer = AVPlayerLayer(player: player)
        layer.frame = challCompareMainView.bounds
        layer.videoGravity = .resizeAspect
        challCompareMainView.layer.addSublayer(layer)
        player.play()

        self.playerMain = player
        self.playerLayerMain = layer

        updateMainPlayerAspectRatio(from: url)
    }

    // MARK: - 서브 영상 재생 (사운드 OFF + 비율 기반 높이 자동 조정)
    private func playVideoOnSubViewWithDynamicAspectRatio(named fileName: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            print("❌ 서브 영상 파일을 찾을 수 없음")
            return
        }

        let url = URL(fileURLWithPath: path)
        let asset = AVAsset(url: url)

        asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
            DispatchQueue.main.async {
                guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                    print("❌ 비디오 트랙 없음")
                    return
                }
                let size = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
                let aspectRatio = abs(size.height / size.width)

                // 기존 높이 제약 제거 후 새로운 비율로 재설정
                self.challCompareSubViewHeightConstraint?.isActive = false
                self.challCompareSubViewHeightConstraint = self.challCompareSubView.heightAnchor.constraint(equalTo: self.challCompareSubView.widthAnchor, multiplier: aspectRatio)
                self.challCompareSubViewHeightConstraint?.isActive = true

                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()

                let player = AVPlayer(url: url)
                player.isMuted = true

                let layer = AVPlayerLayer(player: player)
                layer.frame = self.challCompareSubView.bounds
                layer.videoGravity = .resizeAspect
                self.challCompareSubView.layer.addSublayer(layer)
                player.play()

                self.playerSub = player
                self.playerLayerSub = layer
            }
        }
    }

    // MARK: - 영상 반복 재생 처리
    @objc private func replayVideos(_ notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            if playerMain?.currentItem === playerItem {
                playerMain?.seek(to: .zero)
                playerMain?.play()
            }
            if playerSub?.currentItem === playerItem {
                playerSub?.seek(to: .zero)
                playerSub?.play()
            }
        }
    }

    // MARK: - 뷰 크기 변경 시 영상 레이어 크기 업데이트
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let url = playerMain?.currentItem?.asset as? AVURLAsset {
            updateMainPlayerAspectRatio(from: url.url)
        }
        playerLayerSub?.frame = challCompareSubView.bounds
    }
}

@available(iOS 17.0, *)
#Preview {
    UINavigationController(rootViewController: ChallCompareViewController())
}
