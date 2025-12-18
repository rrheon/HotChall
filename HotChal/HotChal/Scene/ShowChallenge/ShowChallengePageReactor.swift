//
//  ShowChallengePageReactor.swift
//  HotChal
//
//  Created by Claude on 12/18/25.
//

import ReactorKit
import Foundation

final class ShowChallengePageReactor: Reactor {

  // 사용자와의 interaction
  enum Action {
    case setupInitialData(selectedVideoId: String?)
    case pageDidChange(Int)
  }

  // 데이터 가공
  enum Mutation {
    case setChallengeList([ChallengeVideo])
    case setCurrentIndex(Int)
  }

  // 화면에 보여줄 정보
  struct State {
    var challengeList: [ChallengeVideo] = []
    var currentIndex: Int = 0
  }

  var initialState: State

  private let dataManager = MockupDataManager.shared

  init() {
    self.initialState = State()
  }

  // Action -> Mutation
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .setupInitialData(let selectedVideoId):
      let challengeList = dataManager.challengeVideos
      var initialIndex = 0

      if let selectedId = selectedVideoId,
         let foundIndex = challengeList.firstIndex(where: { $0.videoFilename == selectedId }) {
        initialIndex = foundIndex
      }

      return Observable.concat([
        .just(.setChallengeList(challengeList)),
        .just(.setCurrentIndex(initialIndex))
      ])

    case .pageDidChange(let index):
      return .just(.setCurrentIndex(index))
    }
  }

  // Mutation -> State
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .setChallengeList(let list):
      newState.challengeList = list
    case .setCurrentIndex(let index):
      newState.currentIndex = index
    }

    return newState
  }

  // Helper methods
  func challenge(at index: Int) -> ChallengeVideo? {
    guard index >= 0 && index < currentState.challengeList.count else { return nil }
    return currentState.challengeList[index]
  }

  func index(for challenge: ChallengeVideo) -> Int? {
    currentState.challengeList.firstIndex(where: { $0.id == challenge.id })
  }
}
