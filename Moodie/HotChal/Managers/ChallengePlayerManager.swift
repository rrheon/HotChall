//
//  ChallengePlayerModel.swift
//  HotChal
//
//  Created by 최용헌 on 8/1/25.
//
import AVKit


/// 챌린지 플레이어 매니저
final class ChallengePlayerManager {
  static let shared = ChallengePlayerManager()
  private init() {}

  func playLocalVideo(named filename: String, from presentingVC: UIViewController) {
    guard let path = Bundle.main.path(forResource: filename, ofType: nil) else {
      print("❌ 영상 파일을 찾을 수 없습니다: \(filename)")
      return
    }

    let url = URL(fileURLWithPath: path)
    let player = AVPlayer(url: url)
    let playerVC = AVPlayerViewController()
    playerVC.player = player
    playerVC.player?.volume = 0.5

    presentingVC.present(playerVC, animated: true) {
      player.play()
    }
  }
}

