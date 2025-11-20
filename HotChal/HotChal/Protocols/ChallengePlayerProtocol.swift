//
//  ChallengePlayerProtocol.swift
//  HotChal
//
//  Created by 최용헌 on 11/20/25.
//

import UIKit

/// 플레이어 액션 Delegate
/// - 플레이어 화면 내부의 사용자 인터랙션 처리
protocol ChallengePlayerViewDelegate: AnyObject {
  var challengeNavigationDelegate: ChallengeNavigationDelegate? { get }
  
  func navToLearnChallenge(with data: ChallengeVideo)
  func navToShowChallenge(with data: ChallengeVideo)
  func navToTakeChallenge(with data: ChallengeVideo)
  func saveChallenge(with data: ChallengeVideo)
}

extension ChallengePlayerViewDelegate where Self: UIViewController {
  func navToLearnChallenge(with data: ChallengeVideo) {
    challengeNavigationDelegate?.navToLearnChallengeViewController(with: data)
  }
  
  func navToShowChallenge(with data: ChallengeVideo) {
    guard let challenge = data.videoFilename else { return }
    challengeNavigationDelegate?.navToShowChallengeViewController(with: challenge)
  }
  
  func navToTakeChallenge(with data: ChallengeVideo) {
    challengeNavigationDelegate?.navToTakeChallengeViewController(
      audioFileName: data.videoFilename ?? "",
      subVideoFilename: data.videoFilename
    )
  }
  
  func saveChallenge(with data: ChallengeVideo) {
    CoreDataManager.shared.saveChallenge(with: data) { result in
      let comment = result ? "챌린지가 저장되었습니다." : "이미 저장된 챌린지입니다."
      ToastPopupManager.shared.showToast(message: comment, from: self)
    }
  }
}
