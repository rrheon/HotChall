//
//  HotChallTop100ViewController.swift
//  HotChal
//
//  Created by 이지훈 on 7/30/25.
//

import UIKit


/// 핫챌 Top100 화면 케이스
enum HotChallTop100Case {
  case savedChallenge
  case category
  case normal
}

/// HotChall - front - HotChallTop100ViewController
/// 핫챌 Top100 화면
final class HotChallTop100ViewController: UIViewController {
  weak var coordinator: ChallengePlayerCoordinator?
  
  let vcType: HotChallTop100Case
  var challengeName: String
  var challengeDatas: [ChallengeVideo] = []
  
  private let mainView: HotChallTop100View = HotChallTop100View()
 
  init(vcType: HotChallTop100Case = .normal, navTitle: String = "핫챌 Top20"){
    self.vcType = vcType
    self.challengeName = navTitle
    
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    self.vcType = .normal
    self.challengeName = "핫챌 Top20"
    
    super.init(coder: coder)
  }
  
  // MARK: - View
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    self.navigationItem.title = challengeName
    
    setupCollectionView()

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
  
  /// collectionView 설정
  private func setupCollectionView(){
    switch vcType {
    case .savedChallenge:
      challengeDatas = CoreDataManager.shared.getSavedChallengeList()
        .filter{ $0.category == challengeName }
    case .category:
      challengeDatas = MockupDataManager.shared.challengeVideos
        .filter{ $0.category == challengeName }
    case .normal:
      challengeDatas = MockupDataManager.shared.sortedWithViewCountChallengeVideos
    }
    
    mainView.top100ListView.dataSource = self
    mainView.top100ListView.delegate = self
  }
}


// MARK: - UICollectionView 데이터소스 (챌린지 목록)

extension HotChallTop100ViewController: UICollectionViewDataSource {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return challengeDatas.count
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: ChallegneTop100Cell.reuseIdentifier,
      for: indexPath
    ) as? ChallegneTop100Cell else { return UICollectionViewCell() }
    
    let number = indexPath.item + 1
    let data = challengeDatas[indexPath.row]
    
    cell.challengeRankLabel.text = "\(number)"
    cell.challengeTitleLabel.text = data.title
    cell.challengeArtistLabel.text = data.uploader
    cell.challengeThumbnailView.image = UIImage(named: data.thumbnailImage ?? "")
    
    return cell
  }
  
}


// MARK: CollectionView Delegate
extension HotChallTop100ViewController: UICollectionViewDelegateFlowLayout{

  
  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    let challengeData: ChallengeVideo = challengeDatas[indexPath.item]
    coordinator?.showChallPlayer(from: self, data: challengeData)
    }
  
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
