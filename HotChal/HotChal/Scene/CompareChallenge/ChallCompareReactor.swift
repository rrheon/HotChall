//
//  ChallCompareReactor.swift
//  HotChal
//
//  Created by Claude on 12/18/25.
//

import ReactorKit
import Foundation

final class ChallCompareReactor: Reactor {

  // 사용자와의 interaction
  enum Action {
    case setupInitialData(videoURL: URL?, subVideoFilename: String?)
    case togglePlayPause
    case requestRetake
    case requestShare
    case requestSave
    case swapVideos
    case setAlert(title: String, message: String)
    case clearAlert
  }

  // 데이터 가공
  enum Mutation {
    case setVideoURL(URL?)
    case setSubVideoFilename(String?)
    case setIsPlaying(Bool)
    case setAlert(title: String, message: String)
    case clearAlert
    case setNavigation(ChallCompareNavigationEvent?)
  }

  enum ChallCompareNavigationEvent {
    case retake(subVideoFilename: String?)
    case share(videoURL: URL)
    case back
  }

  // 화면에 보여줄 정보
  struct State {
    var videoURL: URL? = nil
    var subVideoFilename: String? = nil
    var isPlaying: Bool = true

    var alertTitle: String? = nil
    var alertMessage: String? = nil

    var navigation: ChallCompareNavigationEvent? = nil
  }

  var initialState: State

  init() {
    self.initialState = State()
  }

  // Action -> Mutation
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .setupInitialData(videoURL, subVideoFilename):
      return Observable.concat([
        .just(.setVideoURL(videoURL)),
        .just(.setSubVideoFilename(subVideoFilename))
      ])

    case .togglePlayPause:
      let newState = !currentState.isPlaying
      return .just(.setIsPlaying(newState))

    case .requestRetake:
      return .just(.setNavigation(.retake(subVideoFilename: currentState.subVideoFilename)))

    case .requestShare:
      guard let url = currentState.videoURL else { return .empty() }
      return .just(.setNavigation(.share(videoURL: url)))

    case .requestSave:
      // 저장은 ViewController에서 직접 처리 (PHPhotoLibrary 권한 요청 필요)
      return .empty()

    case .swapVideos:
      return .empty()

    case let .setAlert(title, message):
      return .just(.setAlert(title: title, message: message))

    case .clearAlert:
      return .just(.clearAlert)
    }
  }

  // Mutation -> State
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .setVideoURL(let url):
      newState.videoURL = url
    case .setSubVideoFilename(let filename):
      newState.subVideoFilename = filename
    case .setIsPlaying(let isPlaying):
      newState.isPlaying = isPlaying
    case let .setAlert(title, message):
      newState.alertTitle = title
      newState.alertMessage = message
    case .clearAlert:
      newState.alertTitle = nil
      newState.alertMessage = nil
    case .setNavigation(let event):
      newState.navigation = event
    }

    return newState
  }
}
