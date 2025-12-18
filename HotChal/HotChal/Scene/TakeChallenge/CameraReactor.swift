//
//  CameraReactor.swift
//  HotChal
//
//  Created by Claude on 12/18/25.
//

import ReactorKit
import Foundation

final class CameraReactor: Reactor {

  enum RecordingState {
    case idle
    case countdown(remaining: Int)
    case recording
    case result(videoURL: URL)
  }

  // 사용자와의 interaction
  enum Action {
    case setupAudio(duration: Int)
    case startCountdown(seconds: Int)
    case countdownTick(remaining: Int)
    case countdownFinished
    case cancelCountdown
    case startRecording
    case stopRecording
    case progressUpdate(progress: Float, remainingSeconds: Int)
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
    case setNavigation(CameraNavigationEvent?)
  }

  enum CameraNavigationEvent {
    case showTimerBottomSheet
    case flipCamera
    case close
    case saveVideo(URL)
  }

  // 화면에 보여줄 정보
  struct State {
    var recordingState: RecordingState = .idle
    var progress: Float = 0.0
    var remainingTime: Int = 15
    var songDuration: Int = 15
    var navigation: CameraNavigationEvent? = nil

    var isRecording: Bool {
      if case .recording = recordingState { return true }
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

  // Action -> Mutation
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .setupAudio(let duration):
      return Observable.concat([
        .just(.setSongDuration(duration)),
        .just(.setRemainingTime(duration))
      ])

    case .startCountdown(let seconds):
      return .just(.setRecordingState(.countdown(remaining: seconds)))

    case .countdownTick(let remaining):
      return .just(.setRecordingState(.countdown(remaining: remaining)))

    case .countdownFinished:
      return .just(.setRecordingState(.recording))

    case .cancelCountdown:
      return Observable.concat([
        .just(.setRecordingState(.idle)),
        .just(.setProgress(0.0))
      ])

    case .startRecording:
      return .just(.setRecordingState(.recording))

    case .stopRecording:
      return Observable.concat([
        .just(.setRecordingState(.idle)),
        .just(.setProgress(0.0)),
        .just(.setRemainingTime(currentState.songDuration))
      ])

    case let .progressUpdate(progress, remainingSeconds):
      return Observable.concat([
        .just(.setProgress(progress)),
        .just(.setRemainingTime(remainingSeconds))
      ])

    case .recordingFinished(let url):
      return .just(.setRecordingState(.result(videoURL: url)))

    case .flipCamera:
      return .just(.setNavigation(.flipCamera))

    case .showTimerSettings:
      return .just(.setNavigation(.showTimerBottomSheet))

    case .closeResultView:
      return .just(.setRecordingState(.idle))

    case .saveVideo:
      guard let url = currentState.resultVideoURL else { return .empty() }
      return .just(.setNavigation(.saveVideo(url)))

    case .close:
      return .just(.setNavigation(.close))
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
    case .setNavigation(let event):
      newState.navigation = event
    }

    return newState
  }
}
