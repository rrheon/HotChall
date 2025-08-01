//
//  HotChallViewController.swift
//  HotChal
//
//  Created by 최용헌 on 7/31/25.
//

import UIKit

/// HotChall - front - HotChallMainViewController
/// 핫챌 메인 화면
class HotChallViewController: UIViewController {
  
  weak var delegate: ChalCoordinator?
  
  private let mainView: HotChalMainView = HotChalMainView()
  
  /// viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "핫챌 TOP3"
    navigationItem.largeTitleDisplayMode = .always
    
    setupNavigationController()
    setupTabBarControler()
    
    registerCells()
    addButtonActions()
  }
  
  
  override func loadView() {
    self.view = mainView
  }
  
  /// 셀 등록
  private func registerCells() {
    
    mainView.topCollectionView.delegate = self
    mainView.topCollectionView.dataSource = self
    
    [mainView.top1ChallengeView, mainView.top2ChallengeView, mainView.top3ChallengeView]
      .compactMap { $0.subviews.compactMap { $0 as? UICollectionView }.first }
      .forEach {
        $0.delegate = self
        $0.dataSource = self
      }
  }
  
  
  /// 버튼 액션 추가하기
  private func addButtonActions(){
    mainView.topMoreButton.addAction(UIAction { [weak self] _ in
      self?.delegate?.navToHotChallTop100ViewController()
    } , for: .touchUpInside)
  }
}

// MARK: - UICollectionViewDataSource

extension HotChallViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == mainView.topCollectionView {
      return 3
    } else {
      return 5
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if collectionView == mainView.topCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotChallTopCell.reuseIdentifier,
                                                    for: indexPath)
      return cell
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedChallengeCell.reuseIdentifier,
                                                    for: indexPath)
      return cell
    }
  }
}

// MARK: CollectionView Delegate

extension HotChallViewController: UICollectionViewDelegateFlowLayout{
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print(#fileID, #function, #line, "- tap")
    ChallPlayerManager.shared.showChallPlayer()
    
  }
}
