//
//  PlayerViewReactor.swift
//  HotChal
//
//  Created by jonghyuck on 8/1/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

final class PlayerViewReactor: Reactor {
  
  enum Action {
    case setChallenge(ChallengeVideo)
    case togglePlayPause
    case seek(progress: Float)
    case changeVolume(Float)
    case toggleMute
    case selectSpeed(Float)
    case setLoopRange(start: Double?, end: Double?)
    case updateTime(current: Double, duration: Double)
  }
  
  enum Mutation {
    case setChallenge(ChallengeVideo)
    case setPlaying(Bool)
    case setProgress(Float)
    case setSeekProgress(Float) // seek를 위한 별도 mutation
    case setVolume(Float)
    case setMuted(Bool)
    case setPreviousVolume(Float)
    case setSpeed(Float)
    case setLoopRange(start: Double?, end: Double?)
    case setCurrentTime(Double)
    case setDuration(Double)
  }
  
  struct State {
    var challengeData: ChallengeVideo?
    var isPlaying: Bool = true
    var progress: Float = 0
    var seekProgress: Float? = nil // seek 요청을 위한 별도 상태
    var currentTime: Double = 0
    var duration: Double = 0
    var volume: Float = 0.5
    var isMuted: Bool = false
    var previousVolume: Float = 0.5
    var selectedSpeed: Float = 1.0
    var loopStart: Double?
    var loopEnd: Double?
    
    // UI 표시용 computed properties
    var title: String {
      challengeData?.title ?? "None Title"
    }
    
    var uploader: String {
      challengeData?.uploader ?? "Unknown Uploader"
    }
    
    var timeText: String {
      let current = Int(currentTime.rounded())
      let total = Int(duration.rounded())
      return "\(current)s | \(total)s"
    }
    
    var videoURL: URL? {
      guard let filename = challengeData?.videoFilename else { return nil }
      return Bundle.main.url(forResource: filename, withExtension: nil)
    }
    
    var audioFileName: String {
      challengeData?.mp4FilenameWithoutExtension ?? ""
    }
    
    var subVideoFilename: String? {
      challengeData?.videoFilename
    }
  }
  
  let initialState: State
  
  init(challengeData: ChallengeVideo? = nil) {
    self.initialState = State(challengeData: challengeData)
  }
  
  // MARK: Mutate

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .setChallenge(let challenge):
      return .just(.setChallenge(challenge))
      
    case .togglePlayPause:
      return .just(.setPlaying(!currentState.isPlaying))
      
    case .seek(let progress):
      return .just(.setSeekProgress(progress))
      
    case .changeVolume(let volume):
      let mutations: [Mutation] = [
        .setVolume(volume),
        .setMuted(volume == 0),
        .setPreviousVolume(volume > 0 ? volume : currentState.previousVolume)
      ]
      return .from(mutations)
      
    case .toggleMute:
      if currentState.isMuted {
        return .from([
          .setMuted(false),
          .setVolume(currentState.previousVolume)
        ])
      } else {
        return .from([
          .setMuted(true),
          .setPreviousVolume(currentState.volume),
          .setVolume(0)
        ])
      }
      
    case .selectSpeed(let speed):
      return .just(.setSpeed(speed))
      
    case .setLoopRange(let start, let end):
      return .just(.setLoopRange(start: start, end: end))
      
    case .updateTime(let current, let duration):
      return .from([
        .setCurrentTime(current),
        .setDuration(duration),
        .setProgress(Float(current / duration))
      ])
    }
  }
  
  // MARK: Reduce

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setChallenge(let challenge):
      newState.challengeData = challenge
      
    case .setPlaying(let isPlaying):
      newState.isPlaying = isPlaying
      
    case .setProgress(let progress):
      newState.progress = progress
      newState.seekProgress = nil // progress 업데이트 시 seekProgress 초기화
      
    case .setSeekProgress(let progress):
      newState.seekProgress = progress
      
    case .setVolume(let volume):
      newState.volume = volume
      
    case .setMuted(let isMuted):
      newState.isMuted = isMuted
      
    case .setPreviousVolume(let volume):
      newState.previousVolume = volume
      
    case .setSpeed(let speed):
      newState.selectedSpeed = speed
      
    case .setLoopRange(let start, let end):
      newState.loopStart = start
      newState.loopEnd = end
      
    case .setCurrentTime(let time):
      newState.currentTime = time
      
    case .setDuration(let duration):
      newState.duration = duration
    }
    
    return newState
  }
}
