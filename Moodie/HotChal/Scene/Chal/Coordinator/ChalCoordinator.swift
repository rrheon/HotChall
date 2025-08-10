
import UIKit

/// 핫첼 메인화면이동 코디네이터
final class ChalCoordinator: BaseCoordinator {
    
    override func start() {
        let chalMainViewController = HotChalMainViewController()
        chalMainViewController.delegate = self
        self.navigationController.viewControllers = [chalMainViewController]
    }
    
    /// 핫챌 Top100 VC로 이동하기
  func navToHotChallTop100ViewController(type: HotChallTop100Case = .normal,
                                         title challengeName: String = "핫챌 Top20"){
        let vc = HotChallTop100ViewController(vcType: type, navTitle: challengeName)

        vc.delegate = self
        self.navigationController.pushViewController(vc, animated: true)
    }

    func navToCompareViewController(url: URL) {
        let vc = ChallCompareViewController()
        vc.videoURL = url
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
