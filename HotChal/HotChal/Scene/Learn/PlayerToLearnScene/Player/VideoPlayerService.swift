//
//  VideoPlayerService.swift
//  HotChal
//
//  Created by jonghyuck on 8/1/25.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

/// AVPlayer를 관리하는 서비스 클래스
final class VideoPlayerService {
  
  // MARK: - Properties
  
  let player: AVPlayer
  private var timeObserverToken: Any?
  private let disposeBag = DisposeBag()
  
  // Observables
  let timeUpdate = PublishSubject<(current: Double, duration: Double)>()
  let playbackEnded = PublishSubject<Void>()
  
  // MARK: - Initialization
  
  init(url: URL) {
    self.player = AVPlayer(url: url)
    setupPlayer()
  }
  
  deinit {
    removeTimeObserver()
  }
  
  // MARK: - Setup
  
  private func setupPlayer() {
    addPeriodicTimeObserver()
    observePlaybackEnd()
  }
  
  private func addPeriodicTimeObserver() {
    let interval = CMTime(seconds: 0.1, preferredTimescale: 60)
    timeObserverToken = player.addPeriodicTimeObserver(
      forInterval: interval,
      queue: .main
    ) { [weak self] time in
      guard let self = self else { return }
      
      let currentSeconds = time.seconds
      let duration = self.player.currentItem?.duration.seconds ?? 0
      
      guard duration.isFinite, duration > 0 else { return }
      
      self.timeUpdate.onNext((current: currentSeconds, duration: duration))
    }
  }
  
  private func observePlaybackEnd() {
    NotificationCenter.default.rx
      .notification(.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
      .subscribe(onNext: { [weak self] _ in
        self?.playbackEnded.onNext(())
      })
      .disposed(by: disposeBag)
  }
  
  private func removeTimeObserver() {
    if let token = timeObserverToken {
      player.removeTimeObserver(token)
      timeObserverToken = nil
    }
  }
  
  // MARK: - Player Controls
  
  func play(atRate rate: Float = 1.0) {
    player.playImmediately(atRate: rate)
    player.rate = rate
    player.play()
  }
  
  func pause() {
    player.pause()
  }
  
  func seek(to progress: Float, completion: (() -> Void)? = nil) {
    guard let duration = player.currentItem?.duration.seconds,
          duration > 0 else { return }
    
    let targetTime = Double(progress) * duration
    let cmTime = CMTime(seconds: targetTime, preferredTimescale: 1000)
    
    player.seek(to: cmTime) { finished in
      if finished {
        completion?()
      }
    }
  }
  
  func seek(toSeconds seconds: Double, completion: (() -> Void)? = nil) {
    let cmTime = CMTime(seconds: seconds, preferredTimescale: 60)
    player.seek(to: cmTime) { finished in
      if finished {
        completion?()
      }
    }
  }
  
  func setVolume(_ volume: Float) {
    player.volume = volume
  }
  
  func isAtEnd() -> Bool {
    guard let duration = player.currentItem?.duration.seconds else { return false }
    return abs(player.currentTime().seconds - duration) < 0.3
  }
  
  func replayFromBeginning(atRate rate: Float = 1.0) {
    player.seek(to: .zero) { [weak self] _ in
      self?.player.playImmediately(atRate: rate)
    }
  }
  
  func isPaused() -> Bool {
    return player.timeControlStatus == .paused
  }
  
  func currentTimeSeconds() -> Double {
    return player.currentTime().seconds
  }
  
  // MARK: - Loop Support
  
  func checkAndHandleLoop(loopStart: Double?, loopEnd: Double?, rate: Float) {
    guard let start = loopStart,
          let end = loopEnd,
          end > start else { return }
    
    let currentTime = currentTimeSeconds()
    if currentTime >= end {
      seek(toSeconds: start) { [weak self] in
        self?.play(atRate: rate)
      }
    }
  }
}
