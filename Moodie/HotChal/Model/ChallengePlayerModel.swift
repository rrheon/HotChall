//
//  ChallengePlayerModel.swift
//  HotChal
//
//  Created by 최용헌 on 8/1/25.
//

import UIKit
import AVFoundation
import AVKit


/// 챌린지 플레이어 모델
final class ChallengePlayerModel {
  
  func playLocalVideo(named filename: String) {
    guard let path = Bundle.main.path(forResource: filename, ofType: nil) else {
      print("❌ 영상 파일을 찾을 수 없습니다: \(filename)")
      return
    }
    
    let url = URL(fileURLWithPath: path)
    let player = AVPlayer(url: url)
    let playerVC = AVPlayerViewController()
    playerVC.player = player
    playerVC.player?.volume = 0.5
//    present(playerVC, animated: true) {
//      player.play()
//    }
  }
}
