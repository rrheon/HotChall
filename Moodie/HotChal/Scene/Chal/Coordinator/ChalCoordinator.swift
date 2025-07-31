import UIKit

final class ChalCoordinator: Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .favorite }

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let chalMainViewController = HotChallViewController()
        chalMainViewController.view.backgroundColor = .systemBackground
        chalMainViewController.delegate = self
        self.navigationController.viewControllers = [chalMainViewController]
    }

    func next() {
        let chalMain2 = ChalMain2()
        chalMain2.delegate = self
        navigationController.pushViewController(chalMain2, animated: true)
        print("다음페이지")
    }
    
    func next2() {
        let chalMain3 = ChalMain3()
        navigationController.pushViewController(chalMain3, animated: true)
        print("다음페이지")
    }
}


