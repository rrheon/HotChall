//
//  ShowChallengePageViewController.swift
//  HotChal
//
//  Created by 최용헌 on 8/6/25.
//

import UIKit


/// 챌린지 보여주기 화면 PageViewController
final class ShowChallengePageViewController: UIPageViewController {
  
  weak var coordinatorDelgate: ChallengeNavigationDelegate?
  
  private var challengeList: [ChallengeVideo] = MockupDataManager.shared.challengeVideos
  private var currentIndex: Int = 0
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dataSource = self
    delegate = self
    setViewControllers([makePage(for: currentIndex)],
                       direction: .forward,
                       animated: false,
                       completion: nil)

  }
  
  
  /// 화면 만들어주기
  /// - Parameter index: 몇 번째 데이터인지 확인을 위한 index
  private func makePage(for index: Int) -> ShowChallengeViewController {
    let vc = ShowChallengeViewController()
    vc.challengeData = challengeList[index]
    vc.delegate = coordinatorDelgate
    return vc
  }
  
}

// MARK: PageViewControllerDataSource

extension ShowChallengePageViewController: UIPageViewControllerDataSource {
  func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerBefore viewController: UIViewController
  ) -> UIViewController? {
    guard currentIndex > 0 else { return nil }
    return makePage(for: currentIndex - 1)
  }
  
  func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerAfter viewController: UIViewController
  ) -> UIViewController? {
    guard currentIndex < challengeList.count - 1 else { return nil }
    return makePage(for: currentIndex + 1)
  }
  

}

// MARK: PageViewControllerDelegate

extension ShowChallengePageViewController: UIPageViewControllerDelegate{
  // 전환될 VC의 인덱스를 임시 저장
  func pageViewController(
    _ pageViewController: UIPageViewController,
    willTransitionTo pendingViewControllers: [UIViewController]
  ) {
    if let vc = pendingViewControllers.first as? ShowChallengeViewController,
       let data = vc.challengeData,
       let index = challengeList.firstIndex(where: { $0.id == data.id }) {
      self.currentIndex = index
    }
  }
  
  // 전환 완료 후 호출됨
  func pageViewController(
    _ pageViewController: UIPageViewController,
    didFinishAnimating finished: Bool,
    previousViewControllers: [UIViewController],
    transitionCompleted completed: Bool
  ) {
    if !completed {
      // 전환 취소된 경우
    }
  }
}
