import AVFoundation

protocol RecordingManagerDelegate: AnyObject {
    func recordingDidFinish(url: URL)
}

final class RecordingService: NSObject {

    weak var delegate: RecordingManagerDelegate?

    private let session: AVCaptureSession
    private let videoOutput = AVCaptureMovieFileOutput()

    init(session: AVCaptureSession) {
        self.session = session
        super.init()
        setupOutput()
    }

    private func setupOutput() {
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
    }

    func startRecording(to url: URL) {
        videoOutput.startRecording(to: url, recordingDelegate: self)
    }

    func stopRecording() {
        if videoOutput.isRecording {
            videoOutput.stopRecording()
        }
    }

  @available(iOS 18.0, *)
  func pauseRecording() {
        if videoOutput.isRecording && !videoOutput.isRecordingPaused {
            videoOutput.pauseRecording()
        }
    }

  @available(iOS 18.0, *)
  func resumeRecording() {
        if videoOutput.isRecording && videoOutput.isRecordingPaused {
            videoOutput.resumeRecording()
        }
    }

  @available(iOS 18.0, *)
  var isRecordingPaused: Bool {
        return videoOutput.isRecordingPaused
    }
}

extension RecordingService: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        delegate?.recordingDidFinish(url: outputFileURL)
    }
}
