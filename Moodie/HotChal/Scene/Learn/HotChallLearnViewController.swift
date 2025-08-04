//
//  CalendarViewController.swift
//  Moodie
//
//  Created by heojiwoo on 7/29/25.
//
import UIKit

/// HotChall - front - HotChallLearnViewController
/// 챌린지 배우기 화면
final class HotChallLearnViewController: UIViewController {
  
  var didSendEventClosure: ((HotChallLearnViewController.Event) -> Void)?

  private var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 16
    layout.minimumInteritemSpacing = 12
    layout.sectionInset = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .backgroundColor
    
    return collectionView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "챌린지 배우기"
  
    view.backgroundColor = .backgroundColor
    
    setupCollectionView()
    setupLayout()
  }
  
  // collectionView 설정
  private func setupCollectionView() {
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(ChallengeCell.self, forCellWithReuseIdentifier: ChallengeCell.reuseIdentifier)
  }
  
  // layout 설정
  private func setupLayout(){
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }
}


// MARK: - UICollectionViewDataSource

extension HotChallLearnViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return MockupDataManager.shared.challengeVideos.count
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: ChallengeCell.reuseIdentifier,
      for: indexPath
    ) as? ChallengeCell else { return UICollectionViewCell() }
    
    cell.challengeData =  MockupDataManager.shared.challengeVideos[indexPath.item]
    
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HotChallLearnViewController: UICollectionViewDelegateFlowLayout{
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let challengeData: ChallengeVideo = MockupDataManager.shared.challengeVideos[indexPath.item]

    ChallengPlayerUIManager.shared.showChallPlayer(from: self, data: challengeData)

  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let width = (collectionView.frame.width - 50) / 2
    return CGSize(width: width, height: width * 1.5)
  }
}

extension HotChallLearnViewController {
  enum Event {
    case learnViewControllerTwo
  }
}
