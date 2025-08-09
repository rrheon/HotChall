//
//  HotChallViewController.swift
//  HotChal
//
//  Created by 최용헌 on 7/31/25.
//

import UIKit

/// HotChall - front - HotChallMainViewController
/// 핫챌 메인 화면
final class HotChalMainViewController: UIViewController {
  
  weak var delegate: ChalCoordinator?
  
  private let mainView: HotChalMainView = HotChalMainView()
  
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
    ChallengePlayerUIManager.shared.closeChallPlayer()
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    ChallengePlayerUIManager.shared.closeChallPlayer()
  }
  
  /// 셀 delegate 및 dataSource 설정
  private func setupMainViewCell() {
    
    mainView.topCollectionView.delegate = self
    mainView.topCollectionView.dataSource = self
    
    [
      mainView.top1ChallengeView.collectionView,
      mainView.top2ChallengeView.collectionView,
      mainView.top3ChallengeView.collectionView
    ].forEach {
      $0.delegate = self
      $0.dataSource = self
    }
  }
  
  
  /// 버튼 액션 추가하기
  private func addButtonActions(){
    mainView.topMoreButton.addAction(UIAction { [weak self] _ in
      self?.delegate?.navToHotChallTop100ViewController()
    } , for: .touchUpInside)
    
    // 카테고리 별 전체보기 버튼을 찾아서 버튼 액션 달아주기
    [
      mainView.top1ChallengeView,
      mainView.top2ChallengeView,
      mainView.top3ChallengeView
    ].forEach {
      guard let challengeName = $0.titleLabel.text else { return }
      
      $0.moreButton.addAction(UIAction { [weak self] _ in
        self?.delegate?.navToHotChallTop100ViewController(type: .category, title: challengeName)
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
    case mainView.top1ChallengeView.collectionView: return categoryDatas[0]?.count ?? 0
    case mainView.top2ChallengeView.collectionView: return categoryDatas[1]?.count ?? 0
    case mainView.top3ChallengeView.collectionView: return categoryDatas[2]?.count ?? 0
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
    let collectionViews: [UICollectionView] = [
      mainView.top1ChallengeView.collectionView,
      mainView.top2ChallengeView.collectionView,
      mainView.top3ChallengeView.collectionView
    ]
    
    if let categoryIndex = collectionViews.firstIndex(of: collectionView) {
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: ChallengeCell.reuseIdentifier,
        for: indexPath
      ) as? ChallengeCell else { return UICollectionViewCell() }
      
      cell.challengeData = categoryDatas[categoryIndex]?[indexPath.row]
      return cell
    }
    
    return UICollectionViewCell()
  }
}

// MARK: CollectionView DelegateFlowLayout

extension HotChalMainViewController: UICollectionViewDelegateFlowLayout{
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let challengeData: ChallengeVideo = MockupDataManager.shared.challengeVideos[indexPath.item]
    ChallengePlayerUIManager.shared.showChallPlayer(from: self, data: challengeData)
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

extension HotChalMainViewController: ChallengePlayerViewDelegate {
  func navToTakeChallenge(with data: ChallengeVideo) {
    delegate?.navToTakeChallengeViewController()
  }
  
  func navToLearnChallenge(with data: ChallengeVideo) {
    delegate?.navToLearnChallengeViewController(with: data)
  }
  
  func navToShowChallenge(with data: ChallengeVideo) {
    guard let challenge = data.videoFilename else { return }
    //    ChallengePlayerManager.shared.playLocalVideo(named: challenge, from: self)
    delegate?.navToShowChallengeViewController()
  }
  
  func saveChallenge(with data: ChallengeVideo) {
    CoreDataManager.shared.saveChallenge(with: data) { result in
      ChallengePlayerUIManager.shared.closeChallPlayer()
      let comment = result ? "챌린지가 저장되었습니다." : "이미 저장된 챌린지입니다."
      
      ToastPopupManager.shared.showToast(message: comment, from: self)
    }
  }
}

