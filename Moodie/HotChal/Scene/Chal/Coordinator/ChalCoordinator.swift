
import UIKit

/// 핫첼 메인화면이동 코디네이터
final class ChalCoordinator: Coordinator {
  weak var finishDelegate: CoordinatorFinishDelegate?
  
  var childCoordinators: [Coordinator] = []
  var navigationController: UINavigationController
  var type: CoordinatorType { .favorite }
  
  required init(_ navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  
  /// 처음 시작화면
  func start() {
    let chalMainViewController = HotChallViewController()
    chalMainViewController.delegate = self
    self.navigationController.viewControllers = [chalMainViewController]
  }
  
  /// 핫챌 Top100 VC로 이동하기
  func navToHotChallTop100ViewController(){
    let vc = HotChallTop100ViewController()
    vc.delegate = self
    self.navigationController.pushViewController(vc, animated: true)
  }

}


