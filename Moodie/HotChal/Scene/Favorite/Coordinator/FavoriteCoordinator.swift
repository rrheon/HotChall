//
//  HomeCoordinator.swift
//  HotChal
//
//  Created by heojiwoo on 7/29/25.
//

import UIKit

final class FavoriteCoordinator: Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .favorite }

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let favoriteViewController = FavoriteViewController()
        favoriteViewController.didSendEventClosure = { [weak self] event in
            switch event {
            case .favoriteDateil:
                self?.showFavoriteDetail()
            }
        }
        navigationController.setViewControllers([favoriteViewController], animated: false)
    }

    private func showFavoriteDetail() {
        let detailVC = Favaor2Controller()
        detailVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(detailVC, animated: true)
    }
}


