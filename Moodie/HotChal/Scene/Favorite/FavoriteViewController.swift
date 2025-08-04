//
//  CalendarViewController.swift
//  Moodie
//
//  Created by heojiwoo on 7/29/25.
//
import UIKit
import AVFoundation
import AVKit



/// HotChall - front - SavedHotChallViewController
/// 저장된 챌린지 화면
final class FavoriteViewController: UIViewController {
  
  private lazy var divideWithCategory: [String: [ChallengeVideo]] = {
    Dictionary(grouping: MockupDataManager.shared.challengeVideos) { $0.category ?? "" }
  }()
  
  private lazy var categories: [String] = Array(divideWithCategory.keys).sorted()
  
  var didSendEventClosure: ((FavoriteViewController.Event) -> Void)?
  
  // 저장된 챌린지 라벨
  //  private let favoriteTitleLabel: UILabel = {
  //    let label = UILabel()
  //    label.text = "저장된 챌린지"
  //    label.font = .boldSystemFont(ofSize: 24)
  //
  //    return label
  //  }()
  
  // 챌린지 컬렉션뷰
  private lazy var challengeCollectionView: UICollectionView = {
    
    let view = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    view.backgroundColor = .black
    view.translatesAutoresizingMaskIntoConstraints = false
    
    return view
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "저장된 챌린지"
    
    view.backgroundColor = .systemBackground
    
    registerCell()
    
    makeUI()
    
  }
  
  /// 화면 구성
  private func makeUI(){
    view.addSubview(challengeCollectionView)
    
    let safeArea = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      challengeCollectionView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
      challengeCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
      challengeCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
      challengeCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
    ])
  }
  
  /// 셀 등록
  private func registerCell(){
    
    challengeCollectionView.delegate = self
    challengeCollectionView.dataSource = self
    
    // 셀등록
    challengeCollectionView.register(ChallengeCell.self,
                                     forCellWithReuseIdentifier: ChallengeCell.reuseIdentifier)
    // 헤더 등록
    challengeCollectionView.register(ChallengeCollectionHeaderView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: ChallengeCollectionHeaderView.reuseIdentifier)
  }
  
  private func createCollectionViewLayout() -> UICollectionViewLayout{
    return UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
      
      // 1. Item
      let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(200),
                                            heightDimension: .absolute(200))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 10)
      
      
      // 2. Group (가로 방향)
      let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(120),
                                             heightDimension: .absolute(180))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      group.interItemSpacing = .fixed(10)
      
      // 3. Section
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .continuous
      
      // 4. Header
      let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(40))
      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top)
      section.boundarySupplementaryItems = [sectionHeader]
      section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
      
      return section
    }
  }
}

/// 화면 이동 Enum
extension FavoriteViewController {
  enum Event {
    case favoriteDateil
  }
}

// MARK: CollectionView extension

extension FavoriteViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return categories.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let category = categories[section]
    return divideWithCategory[category]?.count ?? 0
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: ChallengeCell.reuseIdentifier,
      for: indexPath
    ) as? ChallengeCell else { return UICollectionViewCell() }
    
    let category = categories[indexPath.section]
    guard let data = divideWithCategory[category]?[indexPath.item] else { return UICollectionViewCell() }
    
//    cell.challengeImageView.image = UIImage(named: data.thumbnailImage ?? "")
//    cell.challengeNameLabel.text = data.title
//    cell.delegate = self
    
    return cell
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    guard kind == UICollectionView.elementKindSectionHeader,
          let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ChallengeCollectionHeaderView.reuseIdentifier,
            for: indexPath
          ) as? ChallengeCollectionHeaderView else { return UICollectionReusableView() }
    
    header.challengeCategoryLabel.text = categories[indexPath.section]
    header.delegate = self
    return header
  }
  
  
}

extension FavoriteViewController: UICollectionViewDelegateFlowLayout{
  
  private func playLocalVideo(named filename: String) {
    guard let path = Bundle.main.path(forResource: filename, ofType: nil) else {
      print("❌ 영상 파일을 찾을 수 없습니다: \(filename)")
      return
    }
    
    let url = URL(fileURLWithPath: path)
    let player = AVPlayer(url: url)
    let playerVC = AVPlayerViewController()
    playerVC.player = player
    
    present(playerVC, animated: true) {
      player.play()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print(#fileID, #function, #line, "- <#comment#>")
    let category = categories[indexPath.section]
    guard let data = divideWithCategory[category]?[indexPath.item] else { return }
    
    playLocalVideo(named: data.videoFilename ?? "")
    
  }
}

// MARK: 삭제팝업 프로토콜

extension FavoriteViewController: DeleteSavedChallengeProtocol {
  func showDeletePopup() {
    let vc = PopupViewController()
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated: true)
  }
}

extension FavoriteViewController: ShowAllContentProtocol{
  func showAllContent() {
    let vc = HotChallTop100ViewController()
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
