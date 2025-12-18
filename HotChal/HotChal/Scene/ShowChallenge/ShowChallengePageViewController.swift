//
//  ShowChallengePageViewController.swift
//  HotChal
//
//  Created by 최용헌 on 8/6/25.
//

import UIKit
import RxSwift
import RxCocoa


/// 챌린지 보여주기 화면 PageViewController
final class ShowChallengePageViewController: UIPageViewController {

  weak var coordinatorDelgate: ChallengeNavigationDelegate?

  var reactor: ShowChallengePageReactor? = nil
  private let disposeBag: DisposeBag = DisposeBag()

  var selectedVideo: String?


  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = self
    delegate = self

    let reactor = reactor ?? ShowChallengePageReactor()
    self.reactor = reactor
    bind(with: reactor)
  }

  // MARK: bind

  private func bind(with reactor: ShowChallengePageReactor) {
    // 초기 데이터 로드
    Observable.just(())
      .map { [weak self] in
        ShowChallengePageReactor.Action.setupInitialData(selectedVideoId: self?.selectedVideo)
      }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // State 바인딩 - 초기 페이지 설정
    reactor.state
      .take(2)
      .filter { !$0.challengeList.isEmpty }
      .take(1)
      .withUnretained(self)
      .subscribe(onNext: { owner, state in
        let vc = owner.makePage(for: state.currentIndex, reactor: reactor)
        owner.setViewControllers([vc],
                                 direction: .forward,
                                 animated: false,
                                 completion: nil)
      })
      .disposed(by: disposeBag)
  }

  /// 화면 만들어주기
  /// - Parameter index: 몇 번째 데이터인지 확인을 위한 index
  private func makePage(for index: Int, reactor: ShowChallengePageReactor) -> ShowChallengeViewController {
    let vc = ShowChallengeViewController()
    vc.challengeData = reactor.challenge(at: index)
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
    guard let reactor = reactor else { return nil }
    let currentIndex = reactor.currentState.currentIndex
    guard currentIndex > 0 else { return nil }
    return makePage(for: currentIndex - 1, reactor: reactor)
  }

  func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerAfter viewController: UIViewController
  ) -> UIViewController? {
    guard let reactor = reactor else { return nil }
    let currentIndex = reactor.currentState.currentIndex
    guard currentIndex < reactor.currentState.challengeList.count - 1 else { return nil }
    return makePage(for: currentIndex + 1, reactor: reactor)
  }
}

// MARK: PageViewControllerDelegate

extension ShowChallengePageViewController: UIPageViewControllerDelegate{
  // 전환될 VC의 인덱스를 임시 저장
  func pageViewController(
    _ pageViewController: UIPageViewController,
    willTransitionTo pendingViewControllers: [UIViewController]
  ) {
    guard let reactor = reactor else { return }

    if let vc = pendingViewControllers.first as? ShowChallengeViewController,
       let data = vc.challengeData,
       let index = reactor.index(for: data) {
      reactor.action.onNext(.pageDidChange(index))
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
