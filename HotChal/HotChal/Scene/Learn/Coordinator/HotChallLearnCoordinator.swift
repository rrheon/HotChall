//
//  HotChallLearnCoordinator.swift
//  HotChal
//
//  Created by 최용헌 on 8/4/25.
//

import UIKit


/// 챌린지  배우기 코디네이터
final class HotChallLearnCoordinator: ChallengePlayerCoordinator {
  
  private var lastSubVideoFilename: String?
  
  override func start() {
    let HotChallLearnViewController = HotChallLearnViewController()
    HotChallLearnViewController.coordinator = self
    
    self.navigationController.viewControllers = [HotChallLearnViewController]
  }

}
