//
//  HomeCoordinator.swift
//  HotChal
//
//  Created by heojiwoo on 7/29/25.
//

import UIKit


/// 저장된 챌린지 코디네이터
final class SavedChallengeCoordinator: BaseCoordinator {
    
    private var lastSubVideoFilename: String?
  
  override func start() {
    let favoriteViewController = SavedHotChallViewController()
    favoriteViewController.delegate = self
    
    self.navigationController.viewControllers = [favoriteViewController]
    
  }
  
  /// 핫챌 Top100 VC로 이동하기
  func navToHotChallTop100ViewController(with challengeName: String){
    let vc = HotChallTop100ViewController(vcType: .savedChallenge, navTitle: challengeName)
    vc.delegate = self
    self.navigationController.pushViewController(vc, animated: true)
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
