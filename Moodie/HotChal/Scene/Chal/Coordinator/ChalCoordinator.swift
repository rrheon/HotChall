
import UIKit

/// 핫첼 메인화면이동 코디네이터
final class ChalCoordinator: BaseCoordinator {
    
    private var lastSubVideoFilename: String?
    
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
    /// 챌린지 배우기 디테일 화면으로 이동
    func navToLearnChallengeViewController(with data: ChallengeVideo){
        lastSubVideoFilename = data.videoFilename
        let vc = ChallCompareViewController()
        vc.subVideoFilename = data.videoFilename
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    // 챌린지 찍기 화면으로 이동
    func navToTakeChallengeViewController(audioFileName: String, subVideoFilename: String?) {
        lastSubVideoFilename = subVideoFilename
        let cameraCoordinator = CameraCoordinator(navigationController: navigationController, audioFileName: audioFileName)
        cameraCoordinator.delegate = self
        cameraCoordinator.finishDelegate = self
        childCoordinators.append(cameraCoordinator)
        cameraCoordinator.start()
    }

    func navToCompareViewController(url: URL) {
        let vc = ChallCompareViewController()
        vc.videoURL = url
        vc.subVideoFilename = lastSubVideoFilename
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    override func didFinishCameraRecording(url: URL) {
        self.navToCompareViewController(url: url)
    }
}
