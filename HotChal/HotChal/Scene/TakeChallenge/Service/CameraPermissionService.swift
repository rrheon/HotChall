import AVFoundation

enum CameraPermissionStatus {
    case granted
    case denied
    case notDetermined
}

final class CameraPermissionService {

    static func requestCameraAndMicPermissions(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { videoGranted in
            AVCaptureDevice.requestAccess(for: .audio) { audioGranted in
                DispatchQueue.main.async {
                    completion(videoGranted && audioGranted)
                }
            }
        }
    }

    static func cameraPermissionStatus() -> CameraPermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }

    static func microphonePermissionStatus() -> CameraPermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }
}
