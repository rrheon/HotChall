import UIKit
import AVFoundation

// MARK: - 카메라 뷰컨트롤러
final class CameraViewController: UIViewController {

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoOutput = AVCaptureMovieFileOutput()
    private var currentCameraPosition: AVCaptureDevice.Position = .back

    private let recordButton = RecordButton()
    private let flipCameraButton = UIButton(type: .system)
    private let timerCameraButton = UIButton(type: .system)

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
    
    private let countdownLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 100, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestCameraPermission()
        setupUI()
    }

    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.setupCamera()
                } else {
                    self.showPermissionAlert()
                }
            }
        }
    }

    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "카메라 접근 불가",
            message: "설정 > 개인정보 보호에서 카메라 권한을 허용해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    // MARK: - 카메라 셋업
    private func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high

        // 카메라 생성
        if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition),
           let videoInput = try? AVCaptureDeviceInput(device: camera),
           captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        if let microphone = AVCaptureDevice.default(for: .audio),
           let micInput = try? AVCaptureDeviceInput(device: microphone),
           captureSession.canAddInput(micInput) {
            captureSession.addInput(micInput)
        }
        
        // 카메라 아웃풋
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        captureSession.commitConfiguration()

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)

        captureSession.startRunning()
    }

    // MARK: - 레이아웃
    private func setupUI() {
        view.backgroundColor = .black

        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.addTarget(self, action: #selector(onRecordPressed), for: .touchUpInside)
    
        flipCameraButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera"), for: .normal)
        flipCameraButton.tintColor = .white
        flipCameraButton.addTarget(self, action: #selector(onCameraPositionChangedPressed), for: .touchUpInside)

        timerCameraButton.setImage(UIImage(systemName: "gauge.with.needle"), for: .normal)
        timerCameraButton.tintColor = .white
        timerCameraButton.addTarget(self, action: #selector(onTimerButtonPressed), for: .touchUpInside)
        
        cameraControlStackView.addArrangedSubview(flipCameraButton)
        cameraControlStackView.addArrangedSubview(timerCameraButton)
        
        cameraControlWrapperView.addSubview(cameraControlStackView)
        
        view.addSubview(countdownLabel)
        view.addSubview(recordButton)
        view.addSubview(cameraControlWrapperView)
        
        NSLayoutConstraint.activate([
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.heightAnchor.constraint(equalToConstant: 80),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            
            cameraControlWrapperView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cameraControlWrapperView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            cameraControlStackView.topAnchor.constraint(equalTo: cameraControlWrapperView.topAnchor, constant: 12),
            cameraControlStackView.bottomAnchor.constraint(equalTo: cameraControlWrapperView.bottomAnchor, constant: -12),
            cameraControlStackView.leadingAnchor.constraint(equalTo: cameraControlWrapperView.leadingAnchor, constant: 12),
            cameraControlStackView.trailingAnchor.constraint(equalTo: cameraControlWrapperView.trailingAnchor, constant: -12),
            
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func onRecordPressed() {
        if videoOutput.isRecording {
            videoOutput.stopRecording()
        } else {
            let filename = UUID().uuidString + ".mov"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            videoOutput.startRecording(to: tempURL, recordingDelegate: self)
        }

        recordButton.toggleRecording()
    }

    @objc private func onCameraPositionChangedPressed() {
        captureSession.beginConfiguration()

        // 기존 카메라 입력 제거
        if let currentInput = captureSession.inputs.first(where: {
            ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.video) == true
        }) {
            captureSession.removeInput(currentInput)
        }

        currentCameraPosition = currentCameraPosition == .back ? .front : .back

        // 다시 세션 삽입
        if let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition),
           let newInput = try? AVCaptureDeviceInput(device: newCamera),
           captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
        }
        
        captureSession.commitConfiguration()
    }
    
    @objc private func onTimerButtonPressed() {
        let timerView = TimerSelectView()
        
        let bottomSheet = BaseBottomSheetViewController(
            title: "타이머 설정",
            contentView: timerView,
            onDismiss: {
                print("닫힘")
            }
        )
        
        timerView.onStart = { [weak self] selected in
            guard let self = self else { return }
            bottomSheet.dismiss(animated: true) {
                self.startCountdown(seconds: selected) {
                    self.onRecordPressed()
                }
            }
        }
        
        present(bottomSheet, animated: true)
    }
    
    private func startCountdown(seconds: Int, completion: @escaping () -> Void) {
        var remaining = seconds
        
        countdownLabel.alpha = 1
        countdownLabel.text = "\(remaining)"
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            remaining -= 1
            
            if remaining > 0 {
                UIView.transition(with: self.countdownLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.countdownLabel.text = "\(remaining)"
                })
            } else {
                timer.invalidate()
                UIView.animate(withDuration: 0.3) {
                    self.countdownLabel.alpha = 0
                }
                completion()
            }
        }
    }

}

// MARK: - CameraDelegate
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("📹 영상 저장 위치: \(outputFileURL)")
    }
}
