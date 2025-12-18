//
//  ModalReactor.swift
//  HotChal
//
//  Created by Claude on 12/18/25.
//

import ReactorKit
import Foundation

final class ModalReactor: Reactor {

  // 사용자와의 interaction
  enum Action {
    case startTimeChanged(String)
    case endTimeChanged(String)
    case confirmButtonTapped
    case showTooltip
    case hideTooltip
  }

  // 데이터 가공
  enum Mutation {
    case setStartTime(String)
    case setEndTime(String)
    case setShowTooltip(Bool)
    case setDismiss(startTime: Double?, endTime: Double?)
  }

  // 화면에 보여줄 정보
  struct State {
    var startTimeText: String = ""
    var endTimeText: String = ""
    var showTooltip: Bool = false
    var shouldDismiss: Bool = false
    var dismissStartTime: Double? = nil
    var dismissEndTime: Double? = nil
  }

  var initialState: State

  init() {
    self.initialState = State()
  }

  // Action -> Mutation
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .startTimeChanged(let text):
      return .just(.setStartTime(text))

    case .endTimeChanged(let text):
      return .just(.setEndTime(text))

    case .confirmButtonTapped:
      let startTime = Double(currentState.startTimeText)
      let endTime = Double(currentState.endTimeText)

      // 둘 다 nil이면 nil로 전달, 아니면 값 전달
      if startTime == nil && endTime == nil {
        return .just(.setDismiss(startTime: nil, endTime: nil))
      } else {
        return .just(.setDismiss(startTime: startTime, endTime: endTime))
      }

    case .showTooltip:
      return Observable.concat([
        .just(.setShowTooltip(true)),
        Observable.just(.setShowTooltip(false)).delay(.seconds(2), scheduler: MainScheduler.instance)
      ])

    case .hideTooltip:
      return .just(.setShowTooltip(false))
    }
  }

  // Mutation -> State
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .setStartTime(let text):
      newState.startTimeText = text
    case .setEndTime(let text):
      newState.endTimeText = text
    case .setShowTooltip(let show):
      newState.showTooltip = show
    case let .setDismiss(startTime, endTime):
      newState.shouldDismiss = true
      newState.dismissStartTime = startTime
      newState.dismissEndTime = endTime
    }

    return newState
  }
}
