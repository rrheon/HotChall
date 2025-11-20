//
//  HotChallViewController.swift
//  HotChal
//
//  Created by 최용헌 on 7/31/25.
//

import UIKit
import RxSwift
import RxCocoa

/// HotChall - front - HotChallMainViewController
/// 핫챌 메인 화면
final class HotChalMainViewController: UIViewController {
  
  weak var coordinator: ChalCoordinator?
  var reactor: HotChalMainReactor? = nil
  private let disposeBag: DisposeBag = DisposeBag()
  
  private let mainView: HotChalMainView = HotChalMainView()
  private lazy var categoryViews: [HotChallTop3CategoryView] = [
      mainView.top1ChallengeView,
      mainView.top2ChallengeView,
      mainView.top3ChallengeView
  ]

  override func loadView() {
    super.loadView()
    self.view = mainView
  }

  // MARK: viewDidLoad

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "핫챌 Top3"

    setupMainViewCell()
    
    mainView.scrollView.delegate = self
    bind(wtih: reactor ?? HotChalMainReactor())
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.prefersLargeTitles = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    coordinator?.closeChallPlayer()
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    coordinator?.closeChallPlayer()
  }
  
  /// 셀 delegate 및 dataSource 설정
  private func setupMainViewCell() {
    mainView.topCollectionView.delegate = self
    categoryViews.forEach { $0.collectionView.delegate = self }
  }
  
  // MARK: bind

  private func bind(wtih reactor: HotChalMainReactor) {
    // 초기 데이터
    Observable.just(())
      .map { HotChalMainReactor.Action.setupInititalDatas }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // action
    mainView.topCollectionView.rx.itemSelected
      .map { HotChalMainReactor.Action.tapTopItem($0.row) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    mainView.topMoreButton.rx.tap
      .map { HotChalMainReactor.Action.tapMoreTopButton("핫챌 Top20") }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    for (index, view) in categoryViews.enumerated() {
      view.moreButton.rx.tap
        .map { HotChalMainReactor.Action.tapMoreCategoryButton(view.titleLabel.text ?? "") }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
      
      view.collectionView.rx.itemSelected
        .map { HotChalMainReactor.Action.tapCategoryItem(categoryIndex: index, itemIndex: $0.row) }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
    }
    
    // state
    reactor.state.map { $0.top3Challenge }
      .bind(to: mainView.topCollectionView.rx.items(
        cellIdentifier: HotChallTopCell.reuseIdentifier,
        cellType: HotChallTopCell.self)) { row, product, cell in
          cell.challengeData = (product, row)
        }
        .disposed(by: disposeBag)

    for (index, view) in categoryViews.enumerated() {
      reactor.state.map { $0.categoryVideos[index] }
        .bind(to: view.collectionView.rx.items(
          cellIdentifier: ChallengeCell.reuseIdentifier,
          cellType: ChallengeCell.self)) { _ , video, cell in
            cell.challengeData = video
          }
          .disposed(by: self.disposeBag)
    }
    
    reactor.state.map { $0.navigation }
      .distinctUntilChanged()
      .compactMap { $0 }
      .withUnretained(self)
      .subscribe(onNext: { (_, event) in
          switch event {
          case let .navTotop100VC(type, title):
              self.coordinator?.navToHotChallTop100ViewController(type: type, title: title)
          }
      })
      .disposed(by: disposeBag)

    reactor.state.compactMap { $0.selectedChallenge }
      .withUnretained(self)
      .subscribe(onNext: { _, video in
        self.coordinator?.showChallPlayer(from: self, data: video)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: CollectionView DelegateFlowLayout

extension HotChalMainViewController: UICollectionViewDelegateFlowLayout{
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let width = collectionView.frame.width
    let height = collectionView.frame.height
    
    if collectionView == mainView.topCollectionView {
      return CGSize(width: width, height: height)
    } else {
      return CGSize(width: width / 2.5, height: height)
    }
  }
}

/// MARK: Challenge Player Delegate

extension HotChalMainViewController: ChallengePlayerViewDelegate {
  var challengeNavigationDelegate: ChallengeNavigationDelegate? { coordinator }
}

