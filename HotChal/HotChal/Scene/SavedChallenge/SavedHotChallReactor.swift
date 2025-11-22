//
//  SavedHotChallReactor.swift
//  HotChal
//
//  Created by 최용헌 on 11/22/25.
//

import Foundation
import ReactorKit
import RxSwift

final class SavedHotChallReactor: Reactor {
  
  // MARK: Action
  enum Action {
    case viewDidLoad
    case selectItem(IndexPath)
    case requestDelete(UUID)
    case confirmDelete
    case refresh
  }
  
  // MARK: Mutation
  enum Mutation {
    case setCategoryMap([String: [ChallengeVideo]])
    case setCategories([String])
    case setIsEmpty(Bool)
    case setSelectedChallenge(ChallengeVideo?)
    case setDeleteUUID(UUID?)
  }
  
  // MARK: State
  struct State {
    var categories: [String] = []
    var categoryMap: [String: [ChallengeVideo]] = [:]
    var selectedChallenge: ChallengeVideo? = nil
    var isEmpty: Bool = false
    var currentDeleteUUID: UUID? = nil
  }
  
  let initialState = State()
  
  // MARK: - Mutate
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad, .refresh:
      let saved = CoreDataManager.shared.getSavedChallengeList()
      let isEmpty = saved.isEmpty
      let map = Dictionary(grouping: saved) { $0.category ?? "" }
      let categories = Array(map.keys).sorted()
      
      return Observable.concat([
        .just(.setCategoryMap(map)),
        .just(.setCategories(categories)),
        .just(.setIsEmpty(isEmpty))
      ])
      
    case .selectItem(let indexPath):
      guard indexPath.section >= 0,
            indexPath.item >= 0,
            indexPath.section < currentState.categories.count else {
        return .just(.setSelectedChallenge(nil))
      }
      
      let category = currentState.categories[indexPath.section]
      let item = currentState.categoryMap[category]?[indexPath.item]
      
      return Observable.concat([
        .just(.setSelectedChallenge(item)),
        Observable.just(.setSelectedChallenge(nil))
          .delay(.milliseconds(100), scheduler: MainScheduler.instance)
      ])
      
    case .requestDelete(let uuid):
      return .just(.setDeleteUUID(uuid))
      
    case .confirmDelete:
      return Observable.create { observer in
        guard let uuid = self.currentState.currentDeleteUUID else {
          return Disposables.create()
        }
        
        observer.onNext(.setSelectedChallenge(nil))
        
        CoreDataManager.shared.deleteSavedChallenge(with: uuid) {
          let saved = CoreDataManager.shared.getSavedChallengeList()
          let isEmpty = saved.isEmpty
          let map = Dictionary(grouping: saved) { $0.category ?? "" }
          let categories = Array(map.keys).sorted()
          
          observer.onNext(.setCategoryMap(map))
          observer.onNext(.setCategories(categories))
          observer.onNext(.setIsEmpty(isEmpty))
          observer.onNext(.setDeleteUUID(nil))
          observer.onCompleted()
        }
        return Disposables.create()
      }

    }
  }
  
  // MARK: - Reduce
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setCategoryMap(let map):
      newState.categoryMap = map
    case .setCategories(let categories):
      newState.categories = categories
    case .setIsEmpty(let isEmpty):
      newState.isEmpty = isEmpty
    case .setSelectedChallenge(let challenge):
      newState.selectedChallenge = challenge
    case .setDeleteUUID(let uuid):
      newState.currentDeleteUUID = uuid
    }
    
    return newState
  }
}
