//
//  ChallengePlayerUIManager.swift
//  HotChal
//
//  Created by 최용헌 on 8/2/25.
//

import UIKit

/// 플레이어 매니저
class ChallengePlayerCoordinator: BaseCoordinator, GetKeyWindowProtocol, ChallengeNavigationDelegate {
  
  private weak var playerView: ChallPlayerView?
  
  /// 플레이어 UI 보여주기
  func showChallPlayer(from viewController: UIViewController, data: ChallengeVideo){
    guard let keyWindow = getKeyWindow() else { return }
    
    let presentNew = { [weak self] in
      guard let self = self else { return }
      let newView = self.makePlayerView(for: data, in: keyWindow, from: viewController)
      self.playerView = newView
      self.applyLayout(for: newView, in: keyWindow, from: viewController)
      self.prepareForShow(newView)
      self.animateShow(newView)
    }
    
    if let existing = self.playerView,
       existing.superview != nil {
      // 제일 상단 화면에 이미 playerview가 있는 경우 제거하고 띄워줌
        self.animateHide(existing) { [weak self] in
          existing.removeFromSuperview()
          self?.playerView = nil
          presentNew()
        }
      
      } else {
      
      presentNew()
    }
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
  
  func handleShowModal(from vc: UIViewController & ModalViewControllerProtocol) {
    let modalVC = ModalViewController()
    modalVC.delegate = vc
    modalVC.modalPresentationStyle = .pageSheet
    
    if let sheet = modalVC.sheetPresentationController {
      if #available(iOS 16.0, *) {
        sheet.detents = [.custom { _ in return 220 }]
      } else {
        sheet.detents = [.medium()]
      }
      sheet.prefersGrabberVisible = true
      sheet.preferredCornerRadius = 20
    }
    vc.present(modalVC, animated: true)
  }
  
  // MARK: - Helpers
  
  
  /// 새로운 playerView만들기
  private func makePlayerView(
    for data: ChallengeVideo,
    in keyWindow: UIWindow,
    from viewController: UIViewController
  ) -> ChallPlayerView {
    let newPlayerView = ChallPlayerView(challenge: data)
    
    let buttonTitle = viewController is SavedHotChallViewController ? "삭제하기" : "즐겨찾기"
    let buttonImage = viewController is SavedHotChallViewController ? "trash" : "star"
    newPlayerView.changeButton(title: buttonTitle, image: buttonImage)
    
    keyWindow.addSubview(newPlayerView)
    newPlayerView.challengeData = data
    newPlayerView.translatesAutoresizingMaskIntoConstraints = false
    
    newPlayerView.layer.cornerRadius = 10
    newPlayerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    
    newPlayerView.delegate = viewController as? ChallengePlayerViewDelegate
    return newPlayerView
  }
  
  
  /// 레이아웃 적용
  private func applyLayout(
    for playerView: ChallPlayerView,
    in keyWindow: UIWindow,
    from viewController: UIViewController
  ) {
    if let tabBarHeight = viewController.tabBarController?.tabBar.frame.height {
      NSLayoutConstraint.activate([
        playerView.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor),
        playerView.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor),
        playerView.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor),
        playerView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor, constant: -tabBarHeight)
      ])
    }
  }
  
  private func prepareForShow(_ playerView: ChallPlayerView) {
    playerView.alpha = 0
    playerView.transform = .identity
  }
  
  private func animateShow(_ playerView: ChallPlayerView) {
    UIView.animate(withDuration: 0.3) {
      playerView.alpha = 1
      playerView.transform = .identity
    }
  }
  
  private func animateHide(_ playerView: ChallPlayerView, completion: @escaping () -> Void) {
    UIView.animate(withDuration: 0.2, animations: {
      playerView.alpha = 0
      playerView.transform = CGAffineTransform(translationX: 0, y: playerView.bounds.height)
    }, completion: { _ in
      completion()
    })
  }
}

