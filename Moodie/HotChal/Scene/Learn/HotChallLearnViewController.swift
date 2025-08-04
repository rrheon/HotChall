//
//  CalendarViewController.swift
//  Moodie
//
//  Created by heojiwoo on 7/29/25.
//
import UIKit

/// HotChall - front - HotChallLearnViewController
/// 챌린지 배우기 화면
class HotChallLearnViewController: UIViewController {
  var didSendEventClosure: ((HotChallLearnViewController.Event) -> Void)?
  
  private var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "챌린지 배우기"
    
//    setupNavigationController()
    
    view.backgroundColor = .backgroundColor
    setupCollectionView()
  }
  
  private func setupCollectionView() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 16
    layout.minimumInteritemSpacing = 12
    layout.sectionInset = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .backgroundColor
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(LearnChallengeCell.self, forCellWithReuseIdentifier: LearnChallengeCell.reuseIdentifier)
    
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }
}

extension HotChallLearnViewController {
  enum Event {
    case learnViewControllerTwo
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
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: LearnChallengeCell.reuseIdentifier,
      for: indexPath
    ) as! LearnChallengeCell
    cell.configure(with: MockupDataManager.shared.challengeVideos[indexPath.item])
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HotChallLearnViewController: UICollectionViewDelegateFlowLayout{
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let selectedItem = MockupDataManager.shared.challengeVideos[indexPath.item]
    
    guard let seletedVideo = selectedItem.videoFilename else { return }
          
    ChallengePlayerManager.shared.playLocalVideo(named: seletedVideo)
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
