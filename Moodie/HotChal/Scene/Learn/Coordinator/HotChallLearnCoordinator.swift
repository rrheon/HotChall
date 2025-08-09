//
//  HotChallLearnCoordinator.swift
//  HotChal
//
//  Created by 최용헌 on 8/4/25.
//

import UIKit


/// 챌린지  배우기 코디네이터
final class HotChallLearnCoordinator: BaseCoordinator {

  override func start() {
    let HotChallLearnViewController = HotChallLearnViewController()
    HotChallLearnViewController.delegate = self
    
    self.navigationController.viewControllers = [HotChallLearnViewController]
    
  }
}
