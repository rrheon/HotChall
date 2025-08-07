//
//  ChallengePlayerUIManager.swift
//  HotChal
//
//  Created by 최용헌 on 8/2/25.
//

import UIKit

/// 플레이어 매니저
final class ChallengePlayerUIManager {
  static let shared = ChallengePlayerUIManager()
  
  private init() {}
  
  let playerView: ChallPlayerView = ChallPlayerView()

  
  /// 플레이어 UI 보여주기
  func showChallPlayer(from viewController: UIViewController, data: ChallengeVideo){
    guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
  
    let buttonTitle = viewController is SavedHotChallViewController ? "삭제하기" : "즐겨찾기"
    let buttonImage = viewController is SavedHotChallViewController ? "trash" : "star"
    playerView.changeButton(title: buttonTitle, image: buttonImage)
    
    keyWindow.addSubview(playerView)
    playerView.challengeData = data
    playerView.translatesAutoresizingMaskIntoConstraints = false
    
    playerView.layer.cornerRadius = 10
    playerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    
    if let tabBarHeight = viewController.tabBarController?.tabBar.frame.height {
      NSLayoutConstraint.activate([
        playerView.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor),
        playerView.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor),
        playerView.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor),
        playerView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor, constant: -tabBarHeight)
      ])
      
    }
    
    
    playerView.alpha = 0

    UIView.animate(withDuration: 0.3) {
        self.playerView.alpha = 1
        self.playerView.transform = .identity
    }
    
    playerView.delegate = viewController as? ChallengePlayerViewDelegate
    playerView.challengeData = data
  }
  
  func closeChallPlayer() {
    guard playerView.superview != nil else { return }

      UIView.animate(withDuration: 0.3, animations: {
          self.playerView.alpha = 0
      }) { _ in
          self.playerView.removeFromSuperview()
      }
  }

}
