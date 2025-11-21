
import UIKit


/// 핫챌 메인화면이동 이벤트목록
enum HotChalMainNavigationEvent: Equatable {
  case navTotop100VC(type: HotChallTop100Case, title: String)
}

/// 핫첼 메인화면이동 코디네이터
final class ChalCoordinator: ChallengePlayerCoordinator {
  
  override func start() {
    let chalMainViewController = HotChalMainViewController()
    chalMainViewController.coordinator = self
    chalMainViewController.reactor = HotChalMainReactor()
    self.navigationController.viewControllers = [chalMainViewController]
  }
  
  /// 핫챌 Top100 VC로 이동하기
  func navToHotChallTop100ViewController(type: HotChallTop100Case = .top100,
                                         title challengeName: String = "핫챌 Top20"){
    let vc = HotChallTop100ViewController(vcType: type, navTitle: challengeName)
    vc.coordinator = self
    self.navigationController.pushViewController(vc, animated: true)
  }
}
