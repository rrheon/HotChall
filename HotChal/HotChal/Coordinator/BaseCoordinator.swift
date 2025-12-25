//
//  BaseCoordinator.swift
//  HotChal
//
//  Created by heojiwoo on 8/6/25.
//

import UIKit

class BaseCoordinator: Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .base }

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        fatalError("error")
    }

    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension BaseCoordinator {
  func cameraCoordinatorDidFinishWithVideo(url: URL, subVideoFilename: String?) {
    let compareVC = ChallCompareViewController()
    compareVC.videoURL = url
    compareVC.subVideoFilename = subVideoFilename
    compareVC.coordinator = self as? ChallengeNavigationDelegate
    compareVC.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(compareVC, animated: true)
  }
  
  func coordinatorDidFinish(childCoordinator: any Coordinator) {
    childCoordinators.removeAll { $0 === childCoordinator }

  }
}
