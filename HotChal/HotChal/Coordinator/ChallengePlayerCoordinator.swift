//
//  ChallengePlayerUIManager.swift
//  HotChal
//
//  Created by 최용헌 on 8/2/25.
//

import UIKit

/// 플레이어 매니저
class ChallengePlayerCoordinator: BaseCoordinator,
                                  GetKeyWindowProtocol {
  
  private weak var playerView: ChallPlayerView?
  
  /// 플레이어 UI 보여주기
  func showChallPlayer(from viewController: UIViewController, data: ChallengeVideo){
    let playerView = ChallPlayerView(challenge: data)
    self.playerView = playerView
    
    guard let keyWindow = getKeyWindow() else { return }
    
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
        playerView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor,
                                           constant: -tabBarHeight)
      ])
    }
    
    playerView.alpha = 0
    
    UIView.animate(withDuration: 0.3) {
      self.playerView?.alpha = 1
      self.playerView?.transform = .identity
    }
    
    playerView.delegate = viewController as? ChallengePlayerViewDelegate
    playerView.challengeData = data
  }
  
  
  /// 챌린지 플레이어 닫기
  func closeChallPlayer() {
    guard playerView != nil else { return }
    
    UIView.animate(withDuration: 0.3, animations: {
      self.playerView?.alpha = 0
    }) { _ in
      self.playerView?.removeFromSuperview()
      self.playerView = nil
    }
  }
}

