//
//  HotChallLearnCoordinator.swift
//  HotChal
//
//  Created by 최용헌 on 8/4/25.
//

import UIKit


/// 챌린지  배우기 코디네이터
final class HotChallLearnCoordinator: Coordinator {
  weak var finishDelegate: CoordinatorFinishDelegate?
  
  var childCoordinators: [Coordinator] = []
  var navigationController: UINavigationController
  var type: CoordinatorType { .favorite }
  
  required init(_ navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let HotChallLearnViewController = HotChallLearnViewController()
    HotChallLearnViewController.delegate = self
    
    self.navigationController.viewControllers = [HotChallLearnViewController]
    
  }

  /// 챌린지 배우기 디테일 화면으로 이동
    func navToLearnChallengeViewController(filename: String, title: String, uploader: String){
    let vc = PlayerViewController()
    vc.videoFilename = filename
    vc.videoTitle = title
    vc.uploader = uploader
    vc.hidesBottomBarWhenPushed = true
    self.navigationController.pushViewController(vc, animated: true)
  }

  
}
extension HotChallLearnCoordinator: CameraCoordinatorDelegate {
    func cameraCoordinatorDidFinishWithVideo(url: URL) {
        let compareVC = ChallCompareViewController()
        navigationController.pushViewController(compareVC, animated: true)
    }
}

extension HotChallLearnCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators.removeAll { $0 === childCoordinator }
    }
}

extension HotChallLearnCoordinator: ChallengeNavigationDelegate {}
