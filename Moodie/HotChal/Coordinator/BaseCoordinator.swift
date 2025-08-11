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
    
    func didFinishCameraRecording(url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let vc = ChallCompareViewController()
            vc.videoURL = url
            // ChalCoordinator에서만 coordinator 참조를 달아줘야 하면 아래 캐스팅 유지
            if let chal = self as? ChalCoordinator {
                vc.coordinator = chal
            }
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
}

extension BaseCoordinator: ChallengeNavigationDelegate {
  func cameraCoordinatorDidFinishWithVideo(url: URL) {
//    navToCompareViewController(url: url)
      didFinishCameraRecording(url: url)
  }
  
  func coordinatorDidFinish(childCoordinator: any Coordinator) {
    childCoordinators.removeAll { $0 === childCoordinator }

  }
}
