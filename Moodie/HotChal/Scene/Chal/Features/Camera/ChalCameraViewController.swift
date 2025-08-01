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
        let bottomSheet = TimerSelectBottomSheet()
        bottomSheet.modalPresentationStyle = .automatic
        if let sheet = bottomSheet.sheetPresentationController {
            sheet.detents = [.medium()] // iOS 15+
            sheet.prefersGrabberVisible = true
        }

        bottomSheet.onSelect = { [weak self] selectedSec in
            if let sec = selectedSec {
                print("⏱ 선택한 타이머: \(sec)초")
                // self?.startCountdown(seconds: sec)
            } else {
                print("❌ 타이머 선택 취소")
            }
        }

        present(bottomSheet, animated: true)
    }
}

// MARK: - CameraDelegate
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("📹 영상 저장 위치: \(outputFileURL)")
    }
}

// MARK: - 커스텀 녹화 버튼
private final class RecordButton: UIControl {

    private let outerCircleLayer = CAShapeLayer()
    private let innerShapeView = UIView()

    private var isRecording: Bool = false {
        didSet { animateInnerShape(animated: true) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 버튼 크기에 맞춰서 레이아웃
    override func layoutSubviews() {
        super.layoutSubviews()

        outerCircleLayer.frame = bounds
        // 원 생성
        outerCircleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        applyInnerShapeLayout(animated: false)
    }

    func toggleRecording() {
        isRecording.toggle()
    }

    private func setupLayers() {
        outerCircleLayer.strokeColor = UIColor.white.cgColor
        outerCircleLayer.fillColor = UIColor.clear.cgColor
        outerCircleLayer.lineWidth = 4
        layer.addSublayer(outerCircleLayer)

        innerShapeView.backgroundColor = .red
        innerShapeView.isUserInteractionEnabled = false
        addSubview(innerShapeView)
    }

    private func animateInnerShape(animated: Bool) {
        applyInnerShapeLayout(animated: animated)
    }

    private func applyInnerShapeLayout(animated: Bool) {
        let targetFrame: CGRect
        let targetCornerRadius: CGFloat

        // 원형, 정사각형
        if isRecording {
            let side = bounds.width * 0.5
            targetFrame = CGRect(
                x: (bounds.width - side) / 2,
                y: (bounds.height - side) / 2,
                width: side,
                height: side
            )
            targetCornerRadius = 4
        } else {
            let diameter = bounds.width * 0.85
            targetFrame = CGRect(
                x: (bounds.width - diameter) / 2,
                y: (bounds.height - diameter) / 2,
                width: diameter,
                height: diameter
            )
            targetCornerRadius = diameter / 2
        }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
                self.innerShapeView.frame = targetFrame
                self.innerShapeView.layer.cornerRadius = targetCornerRadius
            }, completion: nil)
        } else {
            self.innerShapeView.frame = targetFrame
            self.innerShapeView.layer.cornerRadius = targetCornerRadius
        }
    }
}


final class TimerSelectBottomSheet: UIViewController {

    private let options = [3, 5, 10]
    private var selectedValue: Int?
    var onSelect: ((Int?) -> Void)? // 선택 후 콜백

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        let titleLabel = UILabel()
        titleLabel.text = "타이머 선택"
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 18)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center

        options.forEach { sec in
            let button = UIButton(type: .system)
            button.setTitle("\(sec)초", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.addTarget(self, action: #selector(timerOptionTapped(_:)), for: .touchUpInside)
            button.tag = sec
            stackView.addArrangedSubview(button)
        }

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.addTarget(self, action: #selector(onCancelPressed), for: .touchUpInside)

        let vStack = UIStackView(arrangedSubviews: [titleLabel, stackView, cancelButton])
        vStack.axis = .vertical
        vStack.spacing = 20
        vStack.alignment = .fill
        vStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(vStack)

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            vStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
    }

    @objc private func timerOptionTapped(_ sender: UIButton) {
        selectedValue = sender.tag
        dismiss(animated: true) {
            self.onSelect?(self.selectedValue)
        }
    }

    @objc private func onCancelPressed() {
        dismiss(animated: true) {
            self.onSelect?(nil)
        }
    }
}
