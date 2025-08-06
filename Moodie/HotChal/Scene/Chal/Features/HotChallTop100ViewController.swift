//
//  HotChallTop100ViewController.swift
//  HotChal
//
//  Created by 이지훈 on 7/30/25.
//

import UIKit


/// HotChall - front - HotChallTop100ViewController
/// 핫챌 Top100 화면
final class HotChallTop100ViewController: UIViewController {
  weak var delegate: ChalCoordinator?
  
  var challengeName: String = "핫챌 Top100"
  
  private let sampleData: [String] = Array(repeating: "챌린지 제목", count: 100) // 임시
  private let sampleData2: [String] = Array(repeating: "아티스트", count: 100)
  
  private let mainView: HotChallTop100View = HotChallTop100View()
 

  // MARK: - View
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    self.navigationItem.title = challengeName
    
    setupBackButton()
    registerCell()

  }
  
  override func loadView() {
    self.view = mainView
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    ChallengePlayerUIManager.shared.closeChallPlayer()
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    ChallengePlayerUIManager.shared.closeChallPlayer()
  }
  
  /// 셀등록
  private func registerCell(){
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
    return MockupDataManager.shared.challengeVideos.count
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
    let data = MockupDataManager.shared.challengeVideos[indexPath.item]
    
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
    let challengeData: ChallengeVideo = MockupDataManager.shared.challengeVideos[indexPath.item]

    ChallengePlayerUIManager.shared.showChallPlayer(from: self, data: challengeData)

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
  func navToTakeChallenge(with data: ChallengeVideo) {
    delegate?.navToTakeChallengeViewController()
  }
  
  func navToLearnChallenge(with data: ChallengeVideo) {
    print(#fileID, #function, #line, "- 챌린지 배우기 화면으로 이동")
      delegate?.navToLearnChallengeViewController(with: data)
  }
  
  func navToShowChallenge(with data: ChallengeVideo) {
    print(#fileID, #function, #line, "- 챌린지 띄우기")
    guard let challenge = data.videoFilename else { return }
    ChallengePlayerManager.shared.playLocalVideo(named: challenge, from: self)
  }
  
  func saveChallenge(with data: ChallengeVideo) {
    CoreDataManager.shared.saveChallenge(with: data) { result in
      print(#fileID, #function, #line, "- 챌린지 저장")
      ChallengePlayerUIManager.shared.closeChallPlayer()
      let comment = result ? "챌린지가 저장되었습니다." : "이미 저장된 챌린지입니다."
      
      
      ToastPopupManager.shared.showToast(message: comment)
    }
  }
}
