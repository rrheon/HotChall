
import UIKit

/// 핫첼 메인화면이동 코디네이터
final class ChalCoordinator: BaseCoordinator {
    
    override func start() {
        let chalMainViewController = HotChalMainViewController()
        chalMainViewController.delegate = self
        self.navigationController.viewControllers = [chalMainViewController]
    }
    
    /// 핫챌 Top100 VC로 이동하기
    func navToHotChallTop100ViewController(with challengeName: String){
        let vc = HotChallTop100ViewController()
        vc.challengeName = challengeName
        vc.delegate = self
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    /// 챌린지 배우기 디테일 화면으로 이동
    func navToLearnChallengeViewController(with data: ChallengeVideo){
        let vc = ChallCompareViewController()
        vc.subVideoFilename = data.videoFilename
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    // 챌린지 찍기 화면으로 이동
    func navToTakeChallengeViewController(audioFileName: String) {
        let cameraCoordinator = CameraCoordinator(navigationController: navigationController, audioFileName: audioFileName)
        cameraCoordinator.delegate = self
        cameraCoordinator.finishDelegate = self
        childCoordinators.append(cameraCoordinator)
        cameraCoordinator.start()
    }
    

    func navToCompareViewController(url: URL) {
        let vc = ChallCompareViewController()
        vc.videoURL = url
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
      
  /// 챌린지 보기 화면으로 이동
  func navToShwoChallengeViewController(){
    let vc = ShowChallengePageViewController(
      transitionStyle: .scroll,
      navigationOrientation: .vertical
    )
    self.navigationController.pushViewController(vc, animated: true)
  }
}

extension ChalCoordinator: CameraCoordinatorDelegate {
    func cameraCoordinatorDidFinishWithVideo(url: URL) {
        navToCompareViewController(url: url)
    }
}

extension ChalCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators.removeAll { $0 === childCoordinator }
    }
}
