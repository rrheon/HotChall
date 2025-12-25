//
//  CameraService.swift
//  HotChal
//
//  Created by heojiwoo on 8/4/25.
//

import AVFoundation

final class CameraService {
    let session = AVCaptureSession()
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var videoInput: AVCaptureDeviceInput?
    private var micInput: AVCaptureDeviceInput?

    /// 마이크 입력 활성화 여부 (false면 무음으로 녹화, 나중에 원본 오디오 합성)
    var isMicrophoneEnabled: Bool = false

    func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high

        defer {
            session.commitConfiguration()
            session.startRunning()
        }

        // Camera
        if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition),
           let newVideoInput = try? AVCaptureDeviceInput(device: camera),
           session.canAddInput(newVideoInput) {
            session.addInput(newVideoInput)
            self.videoInput = newVideoInput
        }

        // Microphone (isMicrophoneEnabled가 true일 때만 추가)
        if isMicrophoneEnabled {
            if let mic = AVCaptureDevice.default(for: .audio),
               let micInput = try? AVCaptureDeviceInput(device: mic),
               session.canAddInput(micInput) {
                session.addInput(micInput)
                self.micInput = micInput
            }
        }
    }

    /// 마이크 입력 활성화/비활성화 (세션 실행 중에도 변경 가능)
    func setMicrophoneEnabled(_ enabled: Bool) {
        guard isMicrophoneEnabled != enabled else { return }
        isMicrophoneEnabled = enabled

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        if enabled {
            // 마이크 추가
            if micInput == nil,
               let mic = AVCaptureDevice.default(for: .audio),
               let newMicInput = try? AVCaptureDeviceInput(device: mic),
               session.canAddInput(newMicInput) {
                session.addInput(newMicInput)
                self.micInput = newMicInput
            }
        } else {
            // 마이크 제거
            if let micInput = micInput {
                session.removeInput(micInput)
                self.micInput = nil
            }
        }
    }

    func switchCamera() {
        guard let currentInput = videoInput else { return }

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.removeInput(currentInput)

        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back

        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition),
              let newInput = try? AVCaptureDeviceInput(device: newCamera),
              session.canAddInput(newInput)
        else { return }

        session.addInput(newInput)
        self.videoInput = newInput
    }

}


