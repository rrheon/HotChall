//
//  ChallengeNavigationProtocol.swift
//  HotChal
//
//  Created by 최용헌 on 8/7/25.
//

import Foundation

/// 챌린지 관련 화면이동 Delegate
/// 챌린지 찍기, 보기, 배우기
protocol ChallengeNavigationDelegate: CameraCoordinatorDelegate, CoordinatorFinishDelegate {
  func navToTakeChallengeViewController()
  func navToLearnChallengeViewController(with challenge: ChallengeVideo)
  func navToShowChallengeViewController(with challenge: String)
}

extension ChallengeNavigationDelegate where Self: BaseCoordinator {
  func navToTakeChallengeViewController() {
    let cameraCoordinator = CameraCoordinator(navigationController)
    cameraCoordinator.delegate = self
    cameraCoordinator.finishDelegate = self
    childCoordinators.append(cameraCoordinator)
    cameraCoordinator.start()
  }
  
  func navToLearnChallengeViewController(with challenge: ChallengeVideo){
    let vc = PlayerViewController()
    vc.challengeData = challenge
    vc.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(vc, animated: true)
  }
  
  func navToShowChallengeViewController(with challenge: String) {
    let vc = ShowChallengePageViewController(
      transitionStyle: .scroll,
      navigationOrientation: .vertical
    )
    vc.coordinatorDelgate = self
    vc.selectedVideo = challenge
    navigationController.pushViewController(vc, animated: true)
  }
}
