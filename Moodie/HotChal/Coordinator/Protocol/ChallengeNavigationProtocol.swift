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
  func navToLearnChallengeViewController()
  func navToShowChallengeViewController()
}

extension ChallengeNavigationDelegate where Self: Coordinator {
  func navToTakeChallengeViewController() {
    let cameraCoordinator = CameraCoordinator(navigationController)
    cameraCoordinator.delegate = self
    cameraCoordinator.finishDelegate = self
    childCoordinators.append(cameraCoordinator)
    cameraCoordinator.start()
  }
  
  func navToLearnChallengeViewController() {
    let vc = ChallCompareViewController()
    navigationController.pushViewController(vc, animated: true)
  }
  
  func navToShowChallengeViewController() {
    let vc = ShowChallengePageViewController(
      transitionStyle: .scroll,
      navigationOrientation: .vertical
    )
    vc.coordinatorDelgate = self
    navigationController.pushViewController(vc, animated: true)
  }
}
