//
//  VideoAudioMergeService.swift
//  HotChal
//
//  녹화된 비디오에 원본 오디오를 합성하는 서비스
//

import AVFoundation

final class VideoAudioMergeService {

    /// 비디오 파일에 오디오 파일을 합성
    /// - Parameters:
    ///   - videoURL: 녹화된 비디오 URL (무음 또는 마이크 음성)
    ///   - audioURL: 합성할 오디오 URL (원본 영상의 오디오)
    ///   - completion: 합성된 비디오 URL 또는 에러
    static func mergeVideoWithAudio(
        videoURL: URL,
        audioURL: URL,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let composition = AVMutableComposition()

        // 비디오 에셋 로드
        let videoAsset = AVAsset(url: videoURL)
        let audioAsset = AVAsset(url: audioURL)

        print("🎬 비디오 합성 시작")
        print("  - 비디오 URL: \(videoURL)")
        print("  - 오디오 URL: \(audioURL)")

        Task {
            do {
                // 비디오 트랙 추가
                guard let videoTrack = try await videoAsset.loadTracks(withMediaType: .video).first else {
                    print("❌ 비디오 트랙을 찾을 수 없음")
                    throw MergeError.videoTrackNotFound
                }

                let videoDuration = try await videoAsset.load(.duration)
                print("  - 비디오 길이: \(CMTimeGetSeconds(videoDuration))초")

                guard let compositionVideoTrack = composition.addMutableTrack(
                    withMediaType: .video,
                    preferredTrackID: kCMPersistentTrackID_Invalid
                ) else {
                    throw MergeError.failedToCreateVideoTrack
                }

                try compositionVideoTrack.insertTimeRange(
                    CMTimeRange(start: .zero, duration: videoDuration),
                    of: videoTrack,
                    at: .zero
                )

                // 비디오 방향 유지
                let transform = try await videoTrack.load(.preferredTransform)
                compositionVideoTrack.preferredTransform = transform

                // 오디오 트랙 추가 (원본 오디오)
                let audioTracks = try await audioAsset.loadTracks(withMediaType: .audio)
                print("  - 오디오 트랙 수: \(audioTracks.count)")

                if let audioTrack = audioTracks.first {
                    guard let compositionAudioTrack = composition.addMutableTrack(
                        withMediaType: .audio,
                        preferredTrackID: kCMPersistentTrackID_Invalid
                    ) else {
                        throw MergeError.failedToCreateAudioTrack
                    }

                    // 오디오를 비디오 길이만큼만 삽입
                    let audioDuration = try await audioAsset.load(.duration)
                    let insertDuration = min(videoDuration, audioDuration)
                    print("  - 오디오 길이: \(CMTimeGetSeconds(audioDuration))초")
                    print("  - 삽입할 길이: \(CMTimeGetSeconds(insertDuration))초")

                    try compositionAudioTrack.insertTimeRange(
                        CMTimeRange(start: .zero, duration: insertDuration),
                        of: audioTrack,
                        at: .zero
                    )
                    print("✅ 오디오 트랙 삽입 완료")
                } else {
                    print("⚠️ 오디오 트랙을 찾을 수 없음 - 무음 비디오로 진행")
                }

                // 출력 파일 생성
                let outputURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mov")

                // 기존 파일 삭제
                try? FileManager.default.removeItem(at: outputURL)

                // 내보내기
                guard let exportSession = AVAssetExportSession(
                    asset: composition,
                    presetName: AVAssetExportPresetHighestQuality
                ) else {
                    throw MergeError.exportSessionCreationFailed
                }

                exportSession.outputURL = outputURL
                exportSession.outputFileType = .mov
                exportSession.shouldOptimizeForNetworkUse = true

                await exportSession.export()

                switch exportSession.status {
                case .completed:
                    // 원본 비디오 파일 삭제
                    try? FileManager.default.removeItem(at: videoURL)

                    await MainActor.run {
                        completion(.success(outputURL))
                    }
                case .failed:
                    await MainActor.run {
                        completion(.failure(exportSession.error ?? MergeError.exportFailed))
                    }
                case .cancelled:
                    await MainActor.run {
                        completion(.failure(MergeError.exportCancelled))
                    }
                default:
                    await MainActor.run {
                        completion(.failure(MergeError.unknownError))
                    }
                }

            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }

    /// async/await 버전
    static func mergeVideoWithAudio(videoURL: URL, audioURL: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            mergeVideoWithAudio(videoURL: videoURL, audioURL: audioURL) { result in
                continuation.resume(with: result)
            }
        }
    }

    enum MergeError: LocalizedError {
        case videoTrackNotFound
        case failedToCreateVideoTrack
        case failedToCreateAudioTrack
        case exportSessionCreationFailed
        case exportFailed
        case exportCancelled
        case unknownError

        var errorDescription: String? {
            switch self {
            case .videoTrackNotFound:
                return "비디오 트랙을 찾을 수 없습니다."
            case .failedToCreateVideoTrack:
                return "비디오 트랙 생성에 실패했습니다."
            case .failedToCreateAudioTrack:
                return "오디오 트랙 생성에 실패했습니다."
            case .exportSessionCreationFailed:
                return "내보내기 세션 생성에 실패했습니다."
            case .exportFailed:
                return "비디오 내보내기에 실패했습니다."
            case .exportCancelled:
                return "비디오 내보내기가 취소되었습니다."
            case .unknownError:
                return "알 수 없는 오류가 발생했습니다."
            }
        }
    }
}
