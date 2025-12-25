//
//  CameraReactor.swift
//  HotChal
//
//  Created by Claude on 12/18/25.
//

import ReactorKit
import Foundation
import AVFoundation

final class CameraReactor: Reactor {

  enum RecordingState: Equatable {
    case idle
    case countdown(remaining: Int)
    case recording
    case paused       // 일시정지 상태 추가
    case result(videoURL: URL)
  }

  // 사용자와의 interaction
  enum Action {
    case findAudioFile(fileName: String?)
    case startCountdown(seconds: Int)
    case cancelCountdown
    case startRecording
    case togglePause          // 일시정지/재개 토글
    case stopRecording
    case recordingFinished(url: URL)
    case flipCamera
    case showTimerSettings
    case closeResultView
    case saveVideo
    case close
  }

  // 데이터 가공
  enum Mutation {
    case setRecordingState(RecordingState)
    case setProgress(Float)
    case setRemainingTime(Int)
    case setSongDuration(Int)
    case setAudioURL(URL?)
    case setElapsedTime(TimeInterval)   // 경과 시간 저장 (일시정지용)
    case setRecordingComplete(Bool)
    case setNavigation(CameraNavigationEvent?)
  }

  enum CameraNavigationEvent: Equatable {
    case showTimerBottomSheet
    case flipCamera
    case close
    case saveVideo(URL)
    case startRecordingFromCountdown  // 카운트다운 완료 후 녹화 시작 신호
    case stopRecordingFromProgress    // 진행률 100% 도달 후 녹화 중지 신호
    case pauseRecording               // 녹화 일시정지 신호
    case resumeRecording              // 녹화 재개 신호
  }

  // 화면에 보여줄 정보
  struct State {
    var recordingState: RecordingState = .idle
    var progress: Float = 0.0
    var remainingTime: Int = 15
    var songDuration: Int = 15
    var audioURL: URL? = nil
    var elapsedTime: TimeInterval = 0   // 일시정지 시 경과 시간 저장
    var isRecordingComplete: Bool = false
    var navigation: CameraNavigationEvent? = nil

    var isRecording: Bool {
      if case .recording = recordingState { return true }
      return false
    }

    var isPaused: Bool {
      if case .paused = recordingState { return true }
      return false
    }

    var isCountdown: Bool {
      if case .countdown = recordingState { return true }
      return false
    }

    var countdownValue: Int? {
      if case .countdown(let remaining) = recordingState { return remaining }
      return nil
    }

    var resultVideoURL: URL? {
      if case .result(let url) = recordingState { return url }
      return nil
    }
  }

  var initialState: State

  init() {
    self.initialState = State()
  }

  // MARK: - Audio File Finding Logic

  /// Bundle에서 오디오 파일 찾기
  private func findAudioFileURL(fileName: String?) -> URL? {
    guard let fileName = fileName, !fileName.isEmpty else {
      print("⚠️ 오디오 파일명이 없음")
      return nil
    }

    // 디버그: Bundle에 있는 mp4 파일 목록 출력
    if let resourcePath = Bundle.main.resourcePath {
      let fileManager = FileManager.default
      if let files = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
        let mp4Files = files.filter { $0.hasSuffix(".mp4") }
        print("📂 Bundle mp4 파일 목록: \(mp4Files)")
      }
    }

    // 1. Bundle에서 mp4 파일 찾기
    if let mp4Url = Bundle.main.url(forResource: fileName, withExtension: "mp4") {
      print("✅ Bundle에서 파일 찾음: \(mp4Url)")
      return mp4Url
    }

    // 2. 확장자 없이 찾기 (이미 확장자가 포함된 경우)
    let nameWithoutExt = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
    if let mp4Url = Bundle.main.url(forResource: nameWithoutExt, withExtension: "mp4") {
      print("✅ Bundle에서 파일 찾음 (확장자 제거 후): \(mp4Url)")
      return mp4Url
    }

    // 3. 전체 Bundle 리소스에서 mp4 파일 찾기
    let searchName = fileName.replacingOccurrences(of: ".mp4", with: "")
    if let resourcePath = Bundle.main.resourcePath {
      let fileManager = FileManager.default
      if let files = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
        for file in files where file.contains(searchName) && file.hasSuffix(".mp4") {
          let fullPath = (resourcePath as NSString).appendingPathComponent(file)
          let url = URL(fileURLWithPath: fullPath)
          print("✅ Bundle 검색으로 파일 찾음: \(url)")
          return url
        }
      }
    }

    print("⚠️ 오디오 파일을 찾을 수 없음 - fileName: \(fileName)")
    return nil
  }

  /// 비디오 파일의 Duration 가져오기
  private func getVideoDuration(url: URL) -> Observable<Int> {
    return Observable.create { observer in
      Task {
        let asset = AVAsset(url: url)
        do {
          let duration = try await asset.load(.duration)
          let seconds = Int(CMTimeGetSeconds(duration))
          observer.onNext(seconds)
          observer.onCompleted()
        } catch {
          print("영상 길이 로드 실패: \(error)")
          observer.onNext(15) // 기본값
          observer.onCompleted()
        }
      }
      return Disposables.create()
    }
  }

  // MARK: - Timer Logic

  /// 카운트다운 타이머 생성 (1초 간격)
  private func createCountdownTimer(seconds: Int) -> Observable<Mutation> {
    let initialState = Observable.just(Mutation.setRecordingState(.countdown(remaining: seconds)))

    let timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
      .take(seconds)
      .flatMap { [weak self] tick -> Observable<Mutation> in
        guard let self = self else { return .empty() }
        let remaining = seconds - Int(tick) - 1

        if remaining > 0 {
          return .just(.setRecordingState(.countdown(remaining: remaining)))
        } else {
          // 카운트다운 완료 - 녹화 시작 + 진행률 타이머 시작
          let startRecording = Observable.concat([
            .just(Mutation.setRecordingState(.recording)),
            .just(Mutation.setElapsedTime(0)),
            .just(Mutation.setRecordingComplete(false)),
            .just(Mutation.setNavigation(.startRecordingFromCountdown)),
            .just(Mutation.setNavigation(nil))
          ])

          // 진행률 타이머도 시작
          let progressTimer = self.createProgressTimer(
            duration: self.currentState.songDuration,
            startFromElapsed: 0
          )

          return Observable.concat([startRecording, progressTimer])
        }
      }

    return Observable.concat([initialState, timer])
  }

  /// 녹화 진행률 타이머 생성 (~60fps)
  /// - Parameters:
  ///   - duration: 전체 녹화 시간
  ///   - startFromElapsed: 일시정지 후 재개 시 이미 경과한 시간
  private func createProgressTimer(duration: Int, startFromElapsed: TimeInterval = 0) -> Observable<Mutation> {
    let maxDuration = TimeInterval(duration)
    let startTime = Date()

    // 약 60fps로 업데이트 (16ms 간격)
    return Observable<Int>.interval(.milliseconds(16), scheduler: MainScheduler.instance)
      .map { _ -> (Float, Int, TimeInterval, Bool) in
        let currentElapsed = Date().timeIntervalSince(startTime) + startFromElapsed
        let progress = Float(currentElapsed / maxDuration)
        let remaining = max(0, Int(ceil(maxDuration - currentElapsed)))
        let isFinished = currentElapsed >= maxDuration
        return (min(progress, 1.0), remaining, currentElapsed, isFinished)
      }
      .take(until: { (_, _, _, isFinished) in isFinished }, behavior: .inclusive)
      .flatMap { (progress, remaining, elapsed, isFinished) -> Observable<Mutation> in
        if isFinished {
          // 녹화 완료 - 중지 신호
          return Observable.concat([
            .just(.setProgress(1.0)),
            .just(.setRemainingTime(0)),
            .just(.setElapsedTime(elapsed)),
            .just(.setRecordingComplete(true)),
            .just(.setNavigation(.stopRecordingFromProgress)),
            .just(.setNavigation(nil))
          ])
        } else {
          return Observable.concat([
            .just(.setProgress(progress)),
            .just(.setRemainingTime(remaining)),
            .just(.setElapsedTime(elapsed))
          ])
        }
      }
  }

  // Action -> Mutation
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .findAudioFile(let fileName):
      guard let url = findAudioFileURL(fileName: fileName) else {
        return Observable.concat([
          .just(.setAudioURL(nil)),
          .just(.setSongDuration(15)),
          .just(.setRemainingTime(15))
        ])
      }

      return getVideoDuration(url: url)
        .flatMap { duration -> Observable<Mutation> in
          return Observable.concat([
            .just(.setAudioURL(url)),
            .just(.setSongDuration(duration)),
            .just(.setRemainingTime(duration))
          ])
        }

    case .startCountdown(let seconds):
      return createCountdownTimer(seconds: seconds)

    case .cancelCountdown:
      return Observable.concat([
        .just(.setRecordingState(.idle)),
        .just(.setProgress(0.0)),
        .just(.setElapsedTime(0)),
        .just(.setRemainingTime(currentState.songDuration))
      ])

    case .startRecording:
      // 녹화 시작 - 진행률 타이머 시작
      let startMutation = Observable<Mutation>.concat([
        .just(.setRecordingState(.recording)),
        .just(.setElapsedTime(0)),
        .just(.setRecordingComplete(false))
      ])

      let progressTimer = createProgressTimer(
        duration: currentState.songDuration,
        startFromElapsed: 0
      )

      return Observable.concat([startMutation, progressTimer])

    case .togglePause:
      if currentState.isRecording {
        // 녹화 중 → 일시정지
        return Observable.concat([
          .just(.setRecordingState(.paused)),
          .just(.setNavigation(.pauseRecording)),
          .just(.setNavigation(nil))
        ])
      } else if currentState.isPaused {
        // 일시정지 → 재개
        let resumeMutation = Observable<Mutation>.concat([
          .just(.setRecordingState(.recording)),
          .just(.setNavigation(.resumeRecording)),
          .just(.setNavigation(nil))
        ])

        // 이전 경과 시간부터 이어서 타이머 시작
        let progressTimer = createProgressTimer(
          duration: currentState.songDuration,
          startFromElapsed: currentState.elapsedTime
        )

        return Observable.concat([resumeMutation, progressTimer])
      }
      return .empty()

    case .stopRecording:
      // 완전 중지 (취소)
      return Observable.concat([
        .just(.setRecordingState(.idle)),
        .just(.setProgress(0.0)),
        .just(.setElapsedTime(0)),
        .just(.setRemainingTime(currentState.songDuration))
      ])

    case .recordingFinished(let url):
      return .just(.setRecordingState(.result(videoURL: url)))

    case .flipCamera:
      return Observable.concat([
        .just(.setNavigation(.flipCamera)),
        .just(.setNavigation(nil))
      ])

    case .showTimerSettings:
      return Observable.concat([
        .just(.setNavigation(.showTimerBottomSheet)),
        .just(.setNavigation(nil))
      ])

    case .closeResultView:
      return Observable.concat([
        .just(.setRecordingState(.idle)),
        .just(.setElapsedTime(0)),
        .just(.setRecordingComplete(false))
      ])

    case .saveVideo:
      guard let url = currentState.resultVideoURL else { return .empty() }
      return Observable.concat([
        .just(.setNavigation(.saveVideo(url))),
        .just(.setNavigation(nil))
      ])

    case .close:
      return Observable.concat([
        .just(.setNavigation(.close)),
        .just(.setNavigation(nil))
      ])
    }
  }

  // Mutation -> State
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .setRecordingState(let recordingState):
      newState.recordingState = recordingState
    case .setProgress(let progress):
      newState.progress = progress
    case .setRemainingTime(let time):
      newState.remainingTime = time
    case .setSongDuration(let duration):
      newState.songDuration = duration
    case .setAudioURL(let url):
      newState.audioURL = url
    case .setElapsedTime(let time):
      newState.elapsedTime = time
    case .setRecordingComplete(let isComplete):
      newState.isRecordingComplete = isComplete
    case .setNavigation(let event):
      newState.navigation = event
    }

    return newState
  }
}
