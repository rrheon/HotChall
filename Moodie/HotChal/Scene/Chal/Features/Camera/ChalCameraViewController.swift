import UIKit
import AVFoundation

protocol CameraViewControllerDelegate: AnyObject {
    func cameraViewControllerDidFinishRecording(videoURL: URL)
    func cameraViewControllerDidCancel()
}

final class CameraViewController: UIViewController {

    weak var delegate: CameraViewControllerDelegate?
    
    var audioFileName: String?
    
    // MARK: - Services & Managers
    private let cameraService = CameraService()
    private lazy var recordingService = RecordingService(session: cameraService.session)
    private let countdownManager = CountdownManager()
    private var progressManager: RecordingProgressManager!
    
    // 오디오 재생용
    private var audioPlayer: AVAudioPlayer?
    private var songDuration: Int = 15
    
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.delegate = self
        countdownManager.delegate = self
        recordingService.delegate = self

        audioSetting()
        requestCameraPermission()
        setupUI()
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
    private func audioSetting() {
        if let mp4Url = Bundle.main.url(forResource: audioFileName, withExtension: "mp4") {
            prepareAudio(url: mp4Url)
            Task {
                let durationSec = await getVideoDuration(url: mp4Url)
                await MainActor.run {
                    self.songDuration = Int(durationSec)
                    self.progressManager = RecordingProgressManager(maxDuration: TimeInterval(self.songDuration))
                    self.progressManager.delegate = self
                }
            }
        } else {
            self.progressManager = RecordingProgressManager(maxDuration: TimeInterval(self.songDuration))
            self.progressManager.delegate = self
        }
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
        closeButton.addTarget(self, action: #selector(onCloseButtonTapped), for: .touchUpInside)
        
        [recordButton, countdownLabel, progressView, cameraControlWrapperView].forEach { view.addSubview($0) }
        [flipCameraButton, timerCameraButton].forEach { cameraControlStackView.addArrangedSubview($0) }
        cameraControlWrapperView.addSubview(cameraControlStackView)

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

            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 10),
            
            closeButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            recordingTimeLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 4),
            recordingTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func configureFlipButton() {
        flipCameraButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera"), for: .normal)
        flipCameraButton.tintColor = .white
        flipCameraButton.addTarget(self, action: #selector(onCameraPositionChangedPressed), for: .touchUpInside)
    }

    private func configureTimerButton() {
        timerCameraButton.setImage(UIImage(systemName: "gauge.with.needle"), for: .normal)
        timerCameraButton.tintColor = .white
        timerCameraButton.addTarget(self, action: #selector(onTimerButtonPressed), for: .touchUpInside)
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
    
    // MARK: - Actions
    @objc private func onCameraPositionChangedPressed() {
        cameraService.switchCamera()
    }

    @objc private func onTimerButtonPressed() {
        let timerView = TimerSelectView()
        let bottomSheet = BaseBottomSheetViewController(
            title: "타이머 설정",
            contentView: timerView,
            onDismiss: {}
        )

        timerView.onStart = { [weak self] selected in
            guard let self = self else { return }
            bottomSheet.dismiss(animated: true) {
                self.countdownManager.start(seconds: selected)
            }
        }

        present(bottomSheet, animated: true)
    }

    private func startRecording() {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
        recordingService.startRecording(to: fileURL)
        recordButton.setState(.recording)
        
        progressManager.start()
        
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
        
        setUIForRecording(isRecording: true)
    }

    private func stopRecording() {
        recordingService.stopRecording()
        progressManager.stop()
        
        audioPlayer?.stop()
        
        progressView.setProgress(0.0, animated: false)
        recordButton.setState(.ready)
        
        recordingTimeLabel.text = String(format: "%02d:00", songDuration)
        setUIForRecording(isRecording: false)
    }

    @objc private func onCloseButtonTapped() {
        delegate?.cameraViewControllerDidCancel()
    }
    
    private func setUIForRecording(isRecording: Bool) {
        closeButton.isHidden = isRecording
        recordingTimeLabel.isHidden = !isRecording
        cameraControlWrapperView.isHidden = isRecording
    }

    private func getVideoDuration(url: URL) async -> Double {
            let asset = AVAsset(url: url)
            do {
                let duration = try await asset.load(.duration)
                return CMTimeGetSeconds(duration)
            } catch {
                print("영상 길이 못찾음: \(error)")
                return 0
            }
        }
    
    private func prepareAudio(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("오디오 준비 실패: \(error)")
        }
    }
}

// MARK: - Delegates
extension CameraViewController: RecordButtonDelegate {
    func recordButtonDidTapStart(_ button: RecordButton) {
        startRecording()
    }

    func recordButtonDidTapStop(_ button: RecordButton) {
        stopRecording()
    }

    func recordButtonDidTapCancelDuringCountdown(_ button: RecordButton) {
        countdownManager.cancel()
        countdownLabel.alpha = 0
        countdownLabel.text = ""
        stopRecording()
    }
}

extension CameraViewController: CountdownManagerDelegate {
    func countdownDidStart() {
        countdownLabel.alpha = 1
        recordButton.setState(.countdown)
    }

    func countdownDidUpdate(remaining: Int) {
        countdownLabel.text = "\(remaining)"
    }

    func countdownDidFinish() {
        countdownLabel.alpha = 0
        startRecording()
    }
}

extension CameraViewController: RecordingProgressManagerDelegate {
    func progressDidUpdate(_ progress: Float) {
        progressView.setProgress(progress, animated: false)
    }
    
    func timeRemainingDidUpdate(_ seconds: Int) {
        let minutes = seconds / 60
        let secs = seconds % 60
        recordingTimeLabel.text = String(format: "%02d:%02d", minutes, secs)
    }

    func progressDidFinish() {
        stopRecording()
    }
}

extension CameraViewController: RecordingManagerDelegate {
    func recordingDidFinish(url: URL) {
        if progressManager.isCompleted {
            showResultView(url: url)
        }
    }
}

extension CameraViewController: ChallCameraResultViewDelegate {
    func cameraResultViewClose(_ view: ChallCameraResultView) {
        view.removeFromSuperview()
        resultView = nil
    }

    func cameraResultViewSave(_ view: ChallCameraResultView, didTapSaveWith videoURL: URL) {
        delegate?.cameraViewControllerDidFinishRecording(videoURL: videoURL)
    }
}
