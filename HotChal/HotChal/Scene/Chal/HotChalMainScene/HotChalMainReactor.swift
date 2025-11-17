//
//  HotChalMainReactor.swift
//  HotChal
//
//  Created by 최용헌 on 11/17/25.
//

import ReactorKit
import Foundation

final class HotChalMainReactor: Reactor {
  
  // 사용자와의 interaction
  enum Action {
    case setupInititalDatas
    case tapTopItem(IndexPath)
    case tapCategoryItem(Int, IndexPath)
    case tapMoreTopButton
    case tapMoreCategoryButton
  }
  
  // 데이터 가공
  enum Mutation {
    case setTop3Items([ChallengeVideo])
    case setCategoryVideos([[ChallengeVideo]])
    case setLoading(Bool)
    case setSelectedChallenge(ChallengeVideo)
  }
  
  // 화면에 보여줄 정보
  struct State {
    var isLoading: Bool = false
    
    var top3Challenge: [ChallengeVideo] = []
    var categoryVideos: [[ChallengeVideo]] = []
    
    var selectedChallenge: ChallengeVideo? = nil
  }
  
  var initialState: State

  private let dataManager = MockupDataManager.shared
  
  init() {
    self.initialState = State()
  }
  
  // Action -> Mutation
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .setupInititalDatas:
      let top3 = dataManager.top3ChallengeVideos
      let categoryVideos = dataManager.top3ChallengeVideosWithCategory
      return Observable.concat([
        .just(.setLoading(true)),
        .just(.setTop3Items(top3)),
        .just(.setCategoryVideos(categoryVideos)),
        .just(.setLoading(false))
      ])
    
    case .tapTopItem(let indexPath):
      let item = currentState.top3Challenge[indexPath.row]
      return .just(.setSelectedChallenge(item))
    
    case .tapCategoryItem(let categoryIndex, let indexPath):
      let item = currentState.categoryVideos[categoryIndex][indexPath.row]
      return .just(.setSelectedChallenge(item))
    
    case .tapMoreTopButton:
      return .empty()
    case .tapMoreCategoryButton:
      return .empty()
    }
  }
  
  // Mutation -> State
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setTop3Items(let top3):
      newState.top3Challenge = top3
    case .setCategoryVideos(let categoryList):
      newState.categoryVideos = categoryList
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
    case .setSelectedChallenge(let item):
      newState.selectedChallenge = item
    }
    
    return newState
  }
}
