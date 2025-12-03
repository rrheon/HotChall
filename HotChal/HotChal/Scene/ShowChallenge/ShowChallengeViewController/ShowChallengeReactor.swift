import Foundation
import ReactorKit
import RxSwift

final class ShowChallengeReactor: Reactor {
  // Inputs
  enum Action {
    case viewDidLoad
    case setChallenge(ChallengeVideo)
    case playPauseToggle
    case tapSave
    case tapLearn
    case tapTake
    case setNavigation(ShowChallengeNavigation?)
  }
  
  // State changes
  enum Mutation {
    case setPlaying(Bool)
    case setDatas(ChallengeVideo)
    case showToast(String?)
    case saveChallenge(Bool)
    case setNavigation(ShowChallengeNavigation?)
  }
  
  struct State {
    var isPlaying: Bool = false
    var title: String? = ""
    var uploader: String? = ""
    var videoFilename: String?
    var audioFilename: String?
    var toastMessage: String?
    var currentChallenge: ChallengeVideo?
    var navigation: ShowChallengeNavigation?
  }
  
  enum ShowChallengeNavigation {
    case learn(ChallengeVideo)
    case take(String)
  }
  
  let initialState: State
  
  init(challenge: ChallengeVideo? = nil) {
    var state = State()
    state.currentChallenge = challenge
    
    if let challenge = challenge {
      state.title = challenge.title
      state.uploader = challenge.uploader
      state.videoFilename = challenge.videoFilename
      state.audioFilename = challenge.mp4FilenameWithoutExtension
    }
    
    self.initialState = state
  }
  
  // MARK: Mutate

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .empty()
    case .setChallenge(let challenge):
      return .just(.setDatas(challenge))
    case .playPauseToggle:
      return .just(.setPlaying(!currentState.isPlaying))
    case .tapSave:
      guard let data = currentState.currentChallenge else {
        return .empty()
      }
      // 비동기로 처리하여 메인 스레드 블로킹 방지
      return Observable.create { observer in
        CoreDataManager.shared.saveChallenge(with: data) { success in
          let comment = success ? "챌린지가 저장되었습니다." : "이미 저장된 챌린지입니다."
          observer.onNext(.saveChallenge(success))
          observer.onNext(.showToast(comment))
          observer.onCompleted()
        }
        return Disposables.create()
      }
    case .tapLearn:
      guard let data = currentState.currentChallenge else {
        return .empty()
      }
      return .just(.setNavigation(.learn(data)))
    case .tapTake:
      guard let audio = currentState.audioFilename else {
        return .empty()
      }
      return .just(.setNavigation(.take(audio)))
    case .setNavigation(let navigation):
      return .just(.setNavigation(navigation))
    }
  }
  
  // MARK: reduce

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .setPlaying(let playing):
      newState.isPlaying = playing
    case .setDatas(let challenge):
      newState.currentChallenge = challenge
      newState.title = challenge.title
      newState.uploader = challenge.uploader
      newState.videoFilename = challenge.videoFilename
      newState.audioFilename = challenge.mp4FilenameWithoutExtension
    case .showToast(let message):
      newState.toastMessage = message
    case .saveChallenge:
      break
    case .setNavigation(let navigation):
      newState.navigation = navigation
    }
    return newState
  }
}
