
import UIKit

/// 핫첼 메인화면이동 코디네이터
final class ChalCoordinator: ChallengePlayerCoordinator {
  
  private var lastSubVideoFilename: String?
  
  override func start() {
    let chalMainViewController = HotChalMainViewController()
    chalMainViewController.coordinator = self
    self.navigationController.viewControllers = [chalMainViewController]
  }
  
  /// 핫챌 Top100 VC로 이동하기
  func navToHotChallTop100ViewController(type: HotChallTop100Case = .normal,
                                         title challengeName: String = "핫챌 Top20"){
    let vc = HotChallTop100ViewController(vcType: type, navTitle: challengeName)
    
    vc.coordinator = self
    self.navigationController.pushViewController(vc, animated: true)
  }
  
  /// 챌린지 배우기 디테일 화면으로 이동
  func navToLearnChallengeViewController(with data: ChallengeVideo) {
    let vc = PlayerViewController()
    vc.challengeData = data
    vc.hidesBottomBarWhenPushed = true
    vc.coordinator = self
    self.navigationController.pushViewController(vc, animated: true)
  }
  
  // 챌린지 찍기 화면으로 이동
  func navToTakeChallengeViewController(
    audioFileName: String,
    subVideoFilename: String?
  ) {
    lastSubVideoFilename = subVideoFilename
    
    let cameraCoordinator = CameraCoordinator(navigationController: navigationController,
                                              audioFileName: audioFileName)
    cameraCoordinator.delegate = self
    cameraCoordinator.finishDelegate = self
    childCoordinators.append(cameraCoordinator)
    cameraCoordinator.start()
  }
  
  
  /// 찍은 챌린지 비교해보기 화면으로 이동
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
