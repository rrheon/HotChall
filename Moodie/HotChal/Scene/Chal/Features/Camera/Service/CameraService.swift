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
        
        if let mic = AVCaptureDevice.default(for: .audio),
           let micInput = try? AVCaptureDeviceInput(device: mic),
           session.canAddInput(micInput) {
            session.addInput(micInput)
            self.micInput = micInput
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


