//
//  HotChallTop100ViewController.swift
//  HotChal
//
//  Created by 이지훈 on 7/30/25.
//

import UIKit
import RxSwift

/// 핫챌 Top100 화면 케이스
enum HotChallTop100Case {
  case savedChallenge
  case category
  case top100
}

/// HotChall - front - HotChallTop100ViewController
/// 핫챌 Top100 화면
final class HotChallTop100ViewController: UIViewController {
  weak var coordinator: ChallengePlayerCoordinator?
  private var reactor: HotChallTop100Reactor
  
  private var disposeBag: DisposeBag = DisposeBag()
  
  private let mainView: HotChallTop100View = HotChallTop100View()
 
  init(vcType: HotChallTop100Case = .top100, navTitle: String = "핫챌 Top20"){
    reactor = HotChallTop100Reactor(vcType: vcType, navTitle: navTitle)
    
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    self.reactor =  HotChallTop100Reactor(vcType: .top100)
    super.init(coder: coder)
  }
  
  // MARK: - viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    self.navigationItem.title = reactor.initialState.challengeName
    
    mainView.top100ListView.delegate = self

    bind(reactor: reactor)
  }
  
  override func loadView() {
    super.loadView()
    self.view = mainView
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    coordinator?.closeChallPlayer()
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    coordinator?.closeChallPlayer()
  }
  
  private func bind(reactor: HotChallTop100Reactor) {
    Observable.just(())
      .map { HotChallTop100Reactor.Action.setupInitialDatas }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    mainView.top100ListView.rx.modelSelected(ChallengeVideo.self)
      .map { HotChallTop100Reactor.Action.tapChallenge($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  
    reactor.state.map { $0.challengeDatas }
      .bind(to: mainView.top100ListView.rx.items(
        cellIdentifier: ChallegneTop100Cell.reuseIdentifier,
        cellType: ChallegneTop100Cell.self)
      ) { index, challenge, cell in
        let number = index + 1
  
        cell.challengeRankLabel.text = "\(number)"
        cell.challengeTitleLabel.text = challenge.title
        cell.challengeArtistLabel.text = challenge.uploader
        cell.challengeThumbnailView.image = UIImage(named: challenge.thumbnailImage ?? "")
      }
      .disposed(by: disposeBag)
    
    reactor.state.compactMap { $0.selectedChallenge }
      .subscribe(onNext: { challenge in
        self.coordinator?.showChallPlayer(from: self, data: challenge)
      })
      .disposed(by: disposeBag)
  }
}


// MARK: CollectionView Delegate
extension HotChallTop100ViewController: UICollectionViewDelegateFlowLayout{
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let width = collectionView.frame.width
    let count = collectionView.frame.height / 10 < 50.0 ? 7 : 10
    let height = collectionView.frame.height / CGFloat(count)

    return CGSize(width: width, height: height)
  }
}

// MARK: Challenge Player Delegate

extension HotChallTop100ViewController: ChallengePlayerViewDelegate {
  var challengeNavigationDelegate: ChallengeNavigationDelegate? { coordinator }
}
