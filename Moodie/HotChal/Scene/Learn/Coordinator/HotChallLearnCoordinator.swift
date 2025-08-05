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

  // 챌린지 찍기 화면으로 이동
  func navToTakeChallengeViewController(){
    let vc = CameraViewController()
    self.navigationController.pushViewController(vc, animated: true)
  }
  
  /// 챌린지 배우기 디테일 화면으로 이동
  func navToLearnChallengeViewController(){
    let vc = PlayerViewController()
//    vc.setupPlayer()
    self.navigationController.pushViewController(vc, animated: true)
  }
  
}
