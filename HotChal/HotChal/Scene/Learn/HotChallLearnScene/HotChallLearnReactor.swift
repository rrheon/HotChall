import ReactorKit
import Foundation

final class HotChallLearnReactor: Reactor {

  // 사용자와의 interaction
  enum Action {
    case setupInitialDatas
    case searchTextChanged(String)
    case selectChallenge(Int)
  }

  // 데이터 가공
  enum Mutation {
    case setChallengeDatas([ChallengeVideo])
    case setSearchText(String)
    case setLoading(Bool)
    case setSelectedChallenge(ChallengeVideo?)
  }

  // 화면에 보여줄 정보
  struct State {
    var isLoading: Bool = false
    var searchText: String = ""
    var challengeDatas: [ChallengeVideo] = []
    var hasResults: Bool = true
    var selectedChallenge: ChallengeVideo? = nil
  }

  var initialState: State

  private let dataManager = MockupDataManager.shared

  init() {
    self.initialState = State()
    print("리액터 생성")
  }
  
  deinit {
    print("리액터 해제")
  }

  // Action -> Mutation
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .setupInitialDatas:
      let recommendVideos = dataManager.recommendChallengeVideos
      return Observable.concat([
        .just(.setLoading(true)),
        .just(.setChallengeDatas(recommendVideos)),
        .just(.setLoading(false))
      ])

    case .searchTextChanged(let searchText):
      let filteredVideos: [ChallengeVideo]
      if searchText.isEmpty {
        filteredVideos = dataManager.recommendChallengeVideos
      } else {
        filteredVideos = dataManager.challengeVideos.filter {
          $0.title?.contains(searchText) ?? false
        }
      }
      return .just(.setSearchText(searchText))

    case .selectChallenge(let indexPath):
      let item = currentState.challengeDatas[indexPath]
      return .just(.setSelectedChallenge(item))
    }
  }

  // Mutation -> State
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .setChallengeDatas(let datas):
      newState.challengeDatas = datas
      newState.hasResults = !datas.isEmpty
    case .setSearchText(let text):
      newState.searchText = text
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
    case .setSelectedChallenge(let challenge):
      newState.selectedChallenge = challenge
    }

    return newState
  }
}
