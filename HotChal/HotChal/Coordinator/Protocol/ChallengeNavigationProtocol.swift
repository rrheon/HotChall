//
//  ChallengeNavigationProtocol.swift
//  HotChal
//
//  Created by 최용헌 on 8/7/25.
//

import Foundation

/// 챌린지 관련 화면이동 Delegate
/// - 챌린지 찍기, 보기, 배우기
/// - Coordinator로 화면 이동을 처리하기 위한 전용 delegate
protocol ChallengeNavigationDelegate: AnyObject, CameraCoordinatorDelegate, CoordinatorFinishDelegate {
  func navToLearnChallengeViewController(with challenge: ChallengeVideo)
  func navToShowChallengeViewController(with challenge: String)
  func navToTakeChallengeViewController(audioFileName: String)
  func navToTakeChallengeViewController(audioFileName: String, subVideoFilename: String?)
}

extension ChallengeNavigationDelegate where Self: BaseCoordinator {
  func navToTakeChallengeViewController(audioFileName: String) {
    let cameraCoordinator = CameraCoordinator(
      navigationController: navigationController,
      audioFileName: audioFileName
    )
    cameraCoordinator.delegate = self
    cameraCoordinator.finishDelegate = self
    childCoordinators.append(cameraCoordinator)
    cameraCoordinator.start()
  }
  
  func navToTakeChallengeViewController() {
    navToTakeChallengeViewController(audioFileName: "")
  }
  
  func navToTakeChallengeViewController(audioFileName: String, subVideoFilename: String?) {
    navToTakeChallengeViewController(audioFileName: audioFileName)
  }
  
  func navToLearnChallengeViewController(with challenge: ChallengeVideo){
    let vc = PlayerViewController()
    vc.challengeData = challenge
    vc.coordinator = self
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
