import UIKit
import AVFoundation
import RxSwift
import RxCocoa

protocol CameraViewControllerDelegate: AnyObject {
    func cameraViewControllerDidFinishRecording(videoURL: URL)
    func cameraViewControllerDidCancel()
}

final class CameraViewController: UIViewController {

    weak var delegate: CameraViewControllerDelegate?

    var audioFileName: String?

    var reactor: CameraReactor? = nil
    private let disposeBag = DisposeBag()

    // MARK: - Services (하드웨어 관련만 유지)
    private let cameraService = CameraService()
    private lazy var recordingService = RecordingService(session: cameraService.session)

    // 오디오 재생용
    private var audioPlayer: AVAudioPlayer?
    private var audioURL: URL?  // 원본 오디오 URL (녹화 후 합성용)

    // MARK: - UI Components
    private var resultView: ChallCameraResultView?
    private let recordButton = RecordButton()
    private let flipCameraButton = UIButton(type: .system)
    private let timerCameraButton = UIButton(type: .system)
    private let countdownLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.progress = 0.0
        progress.trackTintColor = .lightGray
        progress.progressTintColor = .red
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.clipsToBounds = true
        progress.layer.cornerRadius = 4
        return progress
    }()

    private let recordingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "00:15"
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let cameraControlStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let cameraControlWrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Loading Overlay (저장 중 표시)
    private lazy var loadingOverlayView: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true

        // 컨테이너
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(container)

        // 스피너
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(spinner)

        // 라벨
        let label = UILabel()
        label.text = "저장 중..."
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 140),
            container.heightAnchor.constraint(equalToConstant: 120),

            spinner.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),

            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16),
        ])

        return overlay
    }()

    // MARK: - Lifecycle
  override func viewDidLoad() {
        super.viewDidLoad()

        recordButton.delegate = self
        recordingService.delegate = self

        requestCameraPermission()
        setupUI()

        let reactor = reactor ?? CameraReactor()
        self.reactor = reactor
        bind(with: reactor)

        // Reactor에 오디오 파일 찾기 요청
        reactor.action.onNext(.findAudioFile(fileName: audioFileName))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Audio Setting
    /// Reactor에서 audioURL을 받아 AVAudioPlayer 설정
    private func setupAudioPlayer(with url: URL) {
        self.audioURL = url
        prepareAudio(url: url)
    }

    // MARK: - Permissions
    private func requestCameraPermission() {
        CameraPermissionService.requestCameraAndMicPermissions { [weak self] granted in
            guard let self = self else { return }

            if granted {
                self.cameraService.configureSession()

                let previewLayer = AVCaptureVideoPreviewLayer(session: self.cameraService.session)
                previewLayer.videoGravity = .resizeAspectFill
                self.attachPreview(previewLayer, to: self.view)
            } else {
                self.showPermissionAlert()
            }
        }
    }

    private func attachPreview(_ previewLayer: AVCaptureVideoPreviewLayer, to view: UIView) {
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
    }

    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "\u{1F6AB} 카메라 접근 불가",
            message: "설정 > 개인정보 보호에서 카메라 권한을 허용해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UI
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(recordingTimeLabel)
        view.addSubview(closeButton)

        [recordButton, countdownLabel, progressView, cameraControlWrapperView].forEach { view.addSubview($0) }
        [flipCameraButton, timerCameraButton].forEach { cameraControlStackView.addArrangedSubview($0) }
        cameraControlWrapperView.addSubview(cameraControlStackView)

        // 로딩 오버레이 추가 (가장 위에 표시되도록 마지막에 추가)
        view.addSubview(loadingOverlayView)

        configureFlipButton()
        configureTimerButton()

        recordButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.heightAnchor.constraint(equalToConstant: 80),

            cameraControlWrapperView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cameraControlWrapperView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            cameraControlStackView.topAnchor.constraint(equalTo: cameraControlWrapperView.topAnchor, constant: 12),
            cameraControlStackView.bottomAnchor.constraint(equalTo: cameraControlWrapperView.bottomAnchor, constant: -12),
            cameraControlStackView.leadingAnchor.constraint(equalTo: cameraControlWrapperView.leadingAnchor, constant: 12),
            cameraControlStackView.trailingAnchor.constraint(equalTo: cameraControlWrapperView.trailingAnchor, constant: -12),

            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),

            progressView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 10),

            recordingTimeLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 4),
            recordingTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // 로딩 오버레이 전체 화면
            loadingOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func configureFlipButton() {
        flipCameraButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera"), for: .normal)
        flipCameraButton.tintColor = .white
    }

    private func configureTimerButton() {
        timerCameraButton.setImage(UIImage(systemName: "gauge.with.needle"), for: .normal)
        timerCameraButton.tintColor = .white
    }

    // MARK: - Bind

  @available(iOS 18.0, *)
  private func bind(with reactor: CameraReactor) {
        // 카메라 전환 버튼
        flipCameraButton.rx.tap
            .map { CameraReactor.Action.flipCamera }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 타이머 버튼
        timerCameraButton.rx.tap
            .map { CameraReactor.Action.showTimerSettings }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 닫기 버튼
        closeButton.rx.tap
            .map { CameraReactor.Action.close }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State 바인딩 - 진행률
        reactor.state.map { $0.progress }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] progress in
                self?.progressView.setProgress(progress, animated: false)
            })
            .disposed(by: disposeBag)

        // State 바인딩 - 남은 시간
        reactor.state.map { $0.remainingTime }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] seconds in
                let minutes = seconds / 60
                let secs = seconds % 60
                self?.recordingTimeLabel.text = String(format: "%02d:%02d", minutes, secs)
            })
            .disposed(by: disposeBag)

        // State 바인딩 - 녹화 상태
        reactor.state.map { $0.recordingState }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.handleRecordingStateChange(state)
            })
            .disposed(by: disposeBag)

        // State 바인딩 - 네비게이션
        reactor.state.map { $0.navigation }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                self?.handleNavigation(event)
            })
            .disposed(by: disposeBag)

        // State 바인딩 - 오디오 URL (Reactor에서 파일 찾은 후)
        reactor.state.map { $0.audioURL }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] url in
                self?.setupAudioPlayer(with: url)
            })
            .disposed(by: disposeBag)
    }

    private func handleRecordingStateChange(_ state: CameraReactor.RecordingState) {
        switch state {
        case .idle:
            countdownLabel.alpha = 0
            countdownLabel.text = ""
            setUIForRecording(isRecording: false)
            recordButton.setState(.ready)

        case .countdown(let remaining):
            countdownLabel.alpha = 1
            countdownLabel.text = "\(remaining)"
            recordButton.setState(.countdown)

        case .recording:
            countdownLabel.alpha = 0
            setUIForRecording(isRecording: true)
            recordButton.setState(.recording)

        case .paused:
            // 일시정지 상태 - UI는 녹화 중과 유사하지만 버튼에 재생 아이콘 표시
            countdownLabel.alpha = 0
            setUIForRecording(isRecording: true)
            recordButton.setState(.paused)  // 재생 아이콘 표시

        case .result(let url):
            showResultView(url: url)
        }
    }

  @available(iOS 18.0, *)
  private func handleNavigation(_ event: CameraReactor.CameraNavigationEvent) {
        switch event {
        case .flipCamera:
            cameraService.switchCamera()

        case .showTimerBottomSheet:
            showTimerBottomSheet()

        case .close:
            delegate?.cameraViewControllerDidCancel()

        case .saveVideo(let url):
            delegate?.cameraViewControllerDidFinishRecording(videoURL: url)

        case .startRecordingFromCountdown:
            // 카운트다운 완료 후 실제 녹화 시작
            startCameraRecording()

        case .stopRecordingFromProgress:
            // 진행률 100% 도달 - 녹화 중지
            stopCameraRecording()

        case .pauseRecording:
            // 녹화 일시정지
            pauseCameraRecording()

        case .resumeRecording:
            // 녹화 재개
            resumeCameraRecording()
        }
    }

    private func showTimerBottomSheet() {
        let timerView = TimerSelectView()
        let bottomSheet = BaseBottomSheetViewController(
            title: "타이머 설정",
            contentView: timerView,
            onDismiss: {}
        )

        timerView.onStart = { [weak self] selected in
            guard let self = self else { return }
            bottomSheet.dismiss(animated: true) {
                // Reactor에 카운트다운 시작 요청
                self.reactor?.action.onNext(.startCountdown(seconds: selected))
            }
        }

        present(bottomSheet, animated: true)
    }

    private func showResultView(url: URL) {
        let resultView = ChallCameraResultView(videoURL: url)
        resultView.delegate = self
        resultView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(resultView)
        NSLayoutConstraint.activate([
            resultView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultView.topAnchor.constraint(equalTo: view.topAnchor),
            resultView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.resultView = resultView
    }

    // MARK: - Recording Control (카메라 하드웨어 제어만)

    /// 실제 카메라 녹화 시작 (하드웨어 제어)
    private func startCameraRecording() {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
        recordingService.startRecording(to: fileURL)

        // 오디오 재생 시작
        if let player = audioPlayer {
            player.currentTime = 0
            let success = player.play()
            print("🔊 오디오 재생 시작: \(success), duration: \(player.duration)초")
        } else {
            print("⚠️ audioPlayer가 nil입니다")
        }
    }

    /// 실제 카메라 녹화 중지 (하드웨어 제어)
    private func stopCameraRecording() {
        recordingService.stopRecording()
        audioPlayer?.stop()
    }

    /// 녹화 일시정지 (하드웨어 제어)
  @available(iOS 18.0, *)
  private func pauseCameraRecording() {
        recordingService.pauseRecording()
        audioPlayer?.pause()
        print("⏸️ 녹화 일시정지")
    }

    /// 녹화 재개 (하드웨어 제어)
  @available(iOS 18.0, *)
  private func resumeCameraRecording() {
        recordingService.resumeRecording()
        audioPlayer?.play()
        print("▶️ 녹화 재개")
    }

    private func setUIForRecording(isRecording: Bool) {
        closeButton.isHidden = isRecording
        recordingTimeLabel.isHidden = !isRecording
        cameraControlWrapperView.isHidden = isRecording
    }

    private func prepareAudio(url: URL) {
        do {
            // AVAudioSession 설정 - 녹화 중에도 스피커로 소리 출력
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 1.0
            print("오디오 준비 완료: \(url.lastPathComponent)")
        } catch {
            print("오디오 준비 실패: \(error)")
        }
    }
}

// MARK: - RecordButton Delegate
extension CameraViewController: RecordButtonDelegate {
    func recordButtonDidTapStart(_ button: RecordButton) {
        guard let reactor = reactor else { return }

        // 현재 상태에 따른 분기 처리
        if reactor.currentState.isPaused {
            // 일시정지 상태 → 재개
            reactor.action.onNext(.togglePause)
        } else {
            // idle 상태 → 녹화 시작
            reactor.action.onNext(.startRecording)
            startCameraRecording()
        }
    }

    func recordButtonDidTapStop(_ button: RecordButton) {
        guard let reactor = reactor else { return }

        if reactor.currentState.isRecording {
            // 녹화 중 → 일시정지
            reactor.action.onNext(.togglePause)
        } else {
            // 그 외 (수동 중지)
            stopCameraRecording()
            reactor.action.onNext(.stopRecording)
        }
    }

    func recordButtonDidTapCancelDuringCountdown(_ button: RecordButton) {
        // 카운트다운 중 취소
        reactor?.action.onNext(.cancelCountdown)
    }
}

// MARK: - RecordingService Delegate
extension CameraViewController: RecordingManagerDelegate {
    func recordingDidFinish(url: URL) {
        // Reactor의 isRecordingComplete로 자연 종료 여부 확인
        guard reactor?.currentState.isRecordingComplete == true else { return }

        // 원본 오디오가 있으면 합성, 없으면 그대로 사용
        guard let audioURL = audioURL else {
            reactor?.action.onNext(.recordingFinished(url: url))
            return
        }

        // 로딩 오버레이 표시
        loadingOverlayView.isHidden = false

        // 오디오 합성 진행
        VideoAudioMergeService.mergeVideoWithAudio(videoURL: url, audioURL: audioURL) { [weak self] result in
            // 로딩 오버레이 숨기기
            self?.loadingOverlayView.isHidden = true

            switch result {
            case .success(let mergedURL):
                print("오디오 합성 완료: \(mergedURL)")
                self?.reactor?.action.onNext(.recordingFinished(url: mergedURL))
            case .failure(let error):
                print("오디오 합성 실패: \(error.localizedDescription)")
                // 합성 실패 시 원본 비디오 사용
                self?.reactor?.action.onNext(.recordingFinished(url: url))
            }
        }
    }
}

// MARK: - Result View Delegate
extension CameraViewController: ChallCameraResultViewDelegate {
    func cameraResultViewClose(_ view: ChallCameraResultView) {
        view.removeFromSuperview()
        resultView = nil
        reactor?.action.onNext(.closeResultView)
    }

    func cameraResultViewSave(_ view: ChallCameraResultView, didTapSaveWith videoURL: URL) {
        reactor?.action.onNext(.saveVideo)
    }
}
