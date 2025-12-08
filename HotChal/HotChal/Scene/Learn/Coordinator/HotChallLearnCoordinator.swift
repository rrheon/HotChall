//
//  HotChallLearnCoordinator.swift
//  HotChal
//
//  Created by 최용헌 on 8/4/25.
//

import UIKit


/// 챌린지  배우기 코디네이터
final class HotChallLearnCoordinator: ChallengePlayerCoordinator {
  
  private var lastSubVideoFilename: String?
  
  override func start() {
    let HotChallLearnViewController = HotChallLearnViewController()
    HotChallLearnViewController.coordinator = self
    
    self.navigationController.viewControllers = [HotChallLearnViewController]
  }
  
  func handleShowModal(from vc: UIViewController & ModalViewControllerProtocol) {
    let modalVC = ModalViewController()
    modalVC.delegate = vc
    modalVC.modalPresentationStyle = .pageSheet
    
    if let sheet = modalVC.sheetPresentationController {
      if #available(iOS 16.0, *) {
        sheet.detents = [.custom { _ in return 220 }]
      } else {
        sheet.detents = [.medium()]
      }
      sheet.prefersGrabberVisible = true
      sheet.preferredCornerRadius = 20
    }
    vc.present(modalVC, animated: true)
  }
}
