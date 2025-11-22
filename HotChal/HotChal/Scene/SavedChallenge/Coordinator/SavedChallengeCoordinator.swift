//
//  HomeCoordinator.swift
//  HotChal
//
//  Created by heojiwoo on 7/29/25.
//

import UIKit


/// 저장된 챌린지 코디네이터
final class SavedChallengeCoordinator: ChallengePlayerCoordinator {
  
  override func start() {
    let favoriteViewController = SavedHotChallViewController()
    favoriteViewController.coordinator = self
    
    self.navigationController.viewControllers = [favoriteViewController]
  }
  
  /// 핫챌 Top100 VC로 이동하기
  func navToHotChallTop100ViewController(with challengeName: String){
    let vc = HotChallTop100ViewController(vcType: .savedChallenge, navTitle: challengeName)
    vc.coordinator = self
    self.navigationController.pushViewController(vc, animated: true)
  }
  
  /// 삭제 팝업 표시
  func presentDeleteChallengeVC(from vc: UIViewController){
    let popupVC = PopupViewController()
    popupVC.delegate = vc as? any SavedChallengeDelegate
    popupVC.modalPresentationStyle = .overFullScreen
    vc.present(popupVC, animated: false)
  }
}
