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
