//
//  HotChallViewController.swift
//  HotChal
//
//  Created by 최용헌 on 7/31/25.
//

import UIKit

/// HotChall - front - HotChallMainViewController
/// 핫챌 메인 화면
class HotChalMainViewController: UIViewController {
  
  weak var delegate: ChalCoordinator?
  
  private let mainView: HotChalMainView = HotChalMainView()
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.prefersLargeTitles = true
  }
  
  /// viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "핫챌 TOP3"
//    navigationItem.largeTitleDisplayMode = .always
    
//    setupNavigationController()
//    setupTabBarControler()
    
    setupMainViewCell()
    addButtonActions()
  }
  
  override func loadView() {
    self.view = mainView
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    ChallengPlayerUIManager.shared.closeChallPlayer()
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
      self?.delegate?.navToHotChallTop100ViewController(with: "핫챌 Top100")
    } , for: .touchUpInside)
    
    // 카테고리 별 전체보기 버튼을 찾아서 버튼 액션 달아주기
    [
      mainView.top1ChallengeView,
      mainView.top2ChallengeView,
      mainView.top3ChallengeView
    ].forEach {
      guard let challengeName: String = $0.titleLabel.text else { return }
      
      $0.moreButton.addAction(UIAction { [weak self] _ in
        self?.delegate?.navToHotChallTop100ViewController(with: challengeName)
      }, for: .touchUpInside)
    }
  }
}

// MARK: - UICollectionViewDataSource

extension HotChalMainViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == mainView.topCollectionView {
      return 3
    } else {
      return 5
    }
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    var cellID: String
    
    if collectionView == mainView.topCollectionView {
      cellID = HotChallTopCell.reuseIdentifier
    } else {
      cellID = LearnChallengeCell.reuseIdentifier
    }
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
    return cell
  }
}

// MARK: CollectionView DelegateFlowLayout

extension HotChalMainViewController: UICollectionViewDelegateFlowLayout{
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    ChallengPlayerUIManager.shared.showChallPlayer()
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
