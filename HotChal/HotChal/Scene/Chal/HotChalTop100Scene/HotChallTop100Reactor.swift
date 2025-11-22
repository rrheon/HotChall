//
//  HotChallTop100Reactor.swift
//  HotChal
//
//  Created by 최용헌 on 11/21/25.
//

import ReactorKit

final class HotChallTop100Reactor: Reactor {
  var initialState: State = State()
  
  enum Action {
    case setupInitialDatas
    case tapChallenge(ChallengeVideo)
  }
  
  enum Mutation {
    case setupInitialDatas([ChallengeVideo])
    case tapChallenge(ChallengeVideo)
  }
  
  struct State {
    var isLoad: Bool = false
    var challengeName: String? = nil
    var challengeDatas: [ChallengeVideo] = []
    var selectedChallenge: ChallengeVideo? = nil
    var vcType: HotChallTop100Case = .top100
  }
  
  init(vcType: HotChallTop100Case = .top100, navTitle: String = "핫챌 Top20") {
    self.initialState = State(challengeName: navTitle, vcType: vcType)
  }
  

  // MARK: Mutate
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .setupInitialDatas:
        .just(.setupInitialDatas(setupCollectionViewDatas()))
    case .tapChallenge(let challenge):
        .just(.tapChallenge(challenge))
    }
  }
  
  // MARK: Reduce
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setupInitialDatas(let challenges):
      newState.challengeDatas = challenges
    case .tapChallenge(let challenge):
      newState.selectedChallenge = challenge
    }
    return newState
  }
  
  private func setupCollectionViewDatas() -> [ChallengeVideo] {
    let challengeName = self.initialState.challengeName
    
    switch self.currentState.vcType {
    case .savedChallenge:
      return CoreDataManager.shared.getSavedChallengeList()
        .filter{ $0.category == challengeName }
    case .category:
      return MockupDataManager.shared.challengeVideos
        .filter{ $0.category == challengeName }
    case .top100:
      return MockupDataManager.shared.sortedWithViewCountChallengeVideos
    }
  }
}
