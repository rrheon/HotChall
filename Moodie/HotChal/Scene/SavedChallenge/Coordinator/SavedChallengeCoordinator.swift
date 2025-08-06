//
//  HomeCoordinator.swift
//  HotChal
//
//  Created by heojiwoo on 7/29/25.
//

import UIKit


/// 저장된 챌린지 코디네이터
final class SavedChallengeCoordinator: Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .favorite }

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let favoriteViewController = SavedHotChallViewController()
        favoriteViewController.delegate = self
        
      self.navigationController.viewControllers = [favoriteViewController]

    }

  /// 핫챌 Top100 VC로 이동하기
  func navToHotChallTop100ViewController(with challengeName: String){
    let vc = HotChallTop100ViewController()
    vc.challengeName = challengeName
    self.navigationController.pushViewController(vc, animated: true)
  }
  
  // 챌린지 찍기 화면으로 이동
  func navToTakeChallengeViewController(){
    let vc = CameraViewController()
    self.navigationController.pushViewController(vc, animated: true)
  }
  
  /// 챌린지 배우기 디테일 화면으로 이동
  func navToLearnChallengeViewController(){
    let vc = ChallCompareViewController()
//    vc.setupPlayer()
    self.navigationController.pushViewController(vc, animated: true)
  }
  
  /// 챌린지 보기 화면으로 이동
  func navToShowChallengeViewController(){
    let vc = ShowChallengePageViewController(
      transitionStyle: .scroll,
      navigationOrientation: .vertical
    )
    self.navigationController.pushViewController(vc, animated: true)
  }
  
}


