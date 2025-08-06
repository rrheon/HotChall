//
//  ShowChallengeViewController.swift
//  HotChal
//
//  Created by 최용헌 on 8/5/25.
//

import UIKit


/// HotChall - front - ShowChallengeViewController
/// 챌린지 보기 화면
final class ShowChallengeViewController: UIViewController {
  
  
  // 챌린지 컬렉션뷰
  private let collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .vertical
    flowLayout.minimumLineSpacing = 0
    
    let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    view.backgroundColor = .backgroundColor
    view.showsHorizontalScrollIndicator = false
    view.isPagingEnabled = true

    return view
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.navigationBar.prefersLargeTitles = false
    setupLayout()
    setupCollectionView()
  }
  
  private func setupCollectionView(){
    collectionView.delegate = self
    collectionView.dataSource = self
    
    collectionView.register(ShowChallengeCell.self,
                            forCellWithReuseIdentifier: ShowChallengeCell.reuseIdentifier)
  }
  
  /// 레이아웃 설정
  private func setupLayout(){
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}

// MARK: - UICollectionViewDataSource

extension ShowChallengeViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 1
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {

      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: ShowChallengeCell.reuseIdentifier,
        for: indexPath
      ) as? ShowChallengeCell else { return UICollectionViewCell() }
      cell.challengeData = MockupDataManager.shared.challengeVideos[indexPath.item]
      cell.delegate = self
      return cell
    }
  }


// MARK: CollectionView DelegateFlowLayout

extension ShowChallengeViewController: UICollectionViewDelegateFlowLayout{
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
 
  
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let width = collectionView.frame.width
    let height = collectionView.frame.height
    
    return CGSize(width: width, height: height)

  }
}

// MARK: 챌린지 보기 셀 delegate

extension ShowChallengeViewController: ShowChallengeCellDelegate {
  func saveChallengeButtonTapped(wtih data: ChallengeVideo) {
    print(#fileID, #function, #line, "- 저장")
  }
  
  func takeChallengeButtonTapped(wtih data: ChallengeVideo) {
    print(#fileID, #function, #line, "- 찍기")
  }
  
  func learnChallengeButtonTapped(wtih data: ChallengeVideo) {
    print(#fileID, #function, #line, "- 배우기")
  }
}
