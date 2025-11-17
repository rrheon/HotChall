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
  
  /// viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "핫챌 Top3"

    setupMainViewCell()
    addButtonActions()
    
    mainView.scrollView.delegate = self
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
    mainView.topCollectionView.dataSource = self
    
    categoryViews.forEach {
      $0.collectionView.delegate = self
      $0.collectionView.dataSource = self
    }
  }
  
  private func bind(wtih reactor: HotChalMainReactor) {
    mainView.topMoreButton.rx.tap
      .map { HotChalMainReactor.Action.tapMoreTopButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    for (index, view) in categoryViews.enumerated() {
      view.moreButton.rx.tap
        .map { HotChalMainReactor.Action.tapMoreCategoryButton }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
      
      view.collectionView.rx.itemSelected
        .map { HotChalMainReactor.Action.tapCategoryItem(index, $0) }
        .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
    }
    
    reactor.state.map { $0.categoryVideos }
      .withUnretained(self)
      .subscribe(onNext: { _ in
        self.categoryViews.forEach { $0.collectionView.reloadData() }
      })
      .disposed(by: disposeBag)
  }
  
  
  /// 버튼 액션 추가하기
  private func addButtonActions(){
    mainView.topMoreButton.addAction(UIAction { [weak self] _ in
      self?.coordinator?.navToHotChallTop100ViewController()
    } , for: .touchUpInside)
    
    // 카테고리 별 전체보기 버튼을 찾아서 버튼 액션 달아주기
    [
      mainView.top1ChallengeView,
      mainView.top2ChallengeView,
      mainView.top3ChallengeView
    ].forEach {
      guard let challengeName = $0.titleLabel.text else { return }
      
      $0.moreButton.addAction(UIAction { [weak self] _ in
        self?.coordinator?.navToHotChallTop100ViewController(type: .category, title: challengeName)
      }, for: .touchUpInside)
    }
  }
}

// MARK: - UICollectionViewDataSource

extension HotChalMainViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let categoryDatas = MockupDataManager.shared.top3ChallengeVideosWithCategory

    switch collectionView {
    case mainView.topCollectionView: return 3
    case mainView.top1ChallengeView.collectionView: return categoryDatas[0].count
    case mainView.top2ChallengeView.collectionView: return categoryDatas[1].count
    case mainView.top3ChallengeView.collectionView: return categoryDatas[2].count
    default:
      return 0
    }
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let categoryDatas = MockupDataManager.shared.top3ChallengeVideosWithCategory
    
    // Top CollectionView
    if collectionView == mainView.topCollectionView {
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: HotChallTopCell.reuseIdentifier,
        for: indexPath
      ) as? HotChallTopCell else { return UICollectionViewCell() }
      
      cell.challengeData = (MockupDataManager.shared.top3ChallengeVideos[indexPath.item], indexPath.item)
      
      return cell
    }
    
    // Top 1~3 CollectionViews 매핑
    let collectionViews: [UICollectionView] = categoryViews.map({ $0.collectionView })
    
    if let categoryIndex = collectionViews.firstIndex(of: collectionView) {
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: ChallengeCell.reuseIdentifier,
        for: indexPath
      ) as? ChallengeCell else { return UICollectionViewCell() }
      
      cell.challengeData = categoryDatas[categoryIndex][indexPath.row]
      return cell
    }
    
    return UICollectionViewCell()
  }
}

// MARK: CollectionView DelegateFlowLayout

extension HotChalMainViewController: UICollectionViewDelegateFlowLayout{
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    var challengeData: ChallengeVideo?
    
    let categoryDatas = MockupDataManager.shared.top3ChallengeVideosWithCategory
    
    switch collectionView {
    case mainView.topCollectionView:
      challengeData = MockupDataManager.shared.top3ChallengeVideos[indexPath.row]
    case mainView.top1ChallengeView.collectionView:
      challengeData = categoryDatas[0][indexPath.row]
    case mainView.top2ChallengeView.collectionView:
      challengeData = categoryDatas[1][indexPath.row]
    case mainView.top3ChallengeView.collectionView:
      challengeData = categoryDatas[2][indexPath.row]
    default:
      break
    }
    
    if let data = challengeData {
//      ChallengePlayerUIManager.shared.showChallPlayer(from: self, data: data)
      coordinator?.showChallPlayer(from: self, data: data)
    }
  }

  
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

// MARK: Challenge Player Delegate
// ChallengeNavigationDelegate 가 있는데 이건 또 뭐냐
extension HotChalMainViewController: ChallengePlayerViewDelegate {
  func navToTakeChallenge(with data: ChallengeVideo) {

    coordinator?.navToTakeChallengeViewController(
      audioFileName: data.videoFilename ?? "",
      subVideoFilename: data.videoFilename
    )
  }
  
  func navToLearnChallenge(with data: ChallengeVideo) {
    coordinator?.navToLearnChallengeViewController(with: data)
  }
  
  func navToShowChallenge(with data: ChallengeVideo) {
    guard let challenge = data.videoFilename else { return }
    //    ChallengePlayerManager.shared.playLocalVideo(named: challenge, from: self)
    coordinator?.navToShowChallengeViewController(with: challenge)
  }
  
  func saveChallenge(with data: ChallengeVideo) {
    CoreDataManager.shared.saveChallenge(with: data) { result in
      let comment = result ? "챌린지가 저장되었습니다." : "이미 저장된 챌린지입니다."
      
      ToastPopupManager.shared.showToast(message: comment, from: self)
    }
  }
}

