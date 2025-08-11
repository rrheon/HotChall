//
//  HotChallLearnCoordinator.swift
//  HotChal
//
//  Created by 최용헌 on 8/4/25.
//

import UIKit


/// 챌린지  배우기 코디네이터
final class HotChallLearnCoordinator: BaseCoordinator {
    
    private var lastSubVideoFilename: String?

  override func start() {
    let HotChallLearnViewController = HotChallLearnViewController()
    HotChallLearnViewController.delegate = self
    
    self.navigationController.viewControllers = [HotChallLearnViewController]
    
  }
    
    func navToTakeChallengeViewController(audioFileName: String, subVideoFilename: String?) {
        lastSubVideoFilename = subVideoFilename
        let cameraCoordinator = CameraCoordinator(navigationController: navigationController,
                                                  audioFileName: audioFileName)
        cameraCoordinator.delegate = self
        cameraCoordinator.finishDelegate = self
        childCoordinators.append(cameraCoordinator)
        cameraCoordinator.start()
      }

      // (하위호환) 1-파라미터
      func navToTakeChallengeViewController(audioFileName: String) {
        navToTakeChallengeViewController(audioFileName: audioFileName, subVideoFilename: nil)
      }

      // 촬영 후 비교화면으로 이동
      func navToCompareViewController(url: URL) {
        let vc = ChallCompareViewController()
        vc.videoURL = url
        vc.subVideoFilename = lastSubVideoFilename // ✅ 핵심
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
      }

      override func didFinishCameraRecording(url: URL) {
        navToCompareViewController(url: url)
      }
    }
