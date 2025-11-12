//
//  CalendarViewController.swift
//  Moodie
//
//  Created by heojiwoo on 7/29/25.
//
import UIKit


/// HotChall - front - SavedHotChallViewController
/// 저장된 챌린지 화면
final class SavedHotChallViewController: UIViewController {
  
  private lazy var divideWithCategory: [String: [ChallengeVideo]] = [:]
  
  private lazy var categories: [String] = []
  
  weak var delegate: SavedChallengeCoordinator?
  
  var selectedChallengeUUID: UUID? = nil
  
  // 챌린지 컬렉션뷰
  private lazy var challengeCollectionView: UICollectionView = {
    
    let view = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    view.backgroundColor = .backgroundColor
    view.translatesAutoresizingMaskIntoConstraints = false
    
    return view
  }()
  
  private let noResultView: UIView = NoResultView(title: "저장된 챌린지가 없습니다.")

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "즐겨찾기"
    
    view.backgroundColor = .backgroundColor
    
    registerCell()
    
    makeUI()
    reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.reloadData()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    ChallengePlayerUIManager.shared.closeChallPlayer()
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    ChallengePlayerUIManager.shared.closeChallPlayer()
  }
  
  
  /// 화면 구성
  private func makeUI(){
    view.addSubview(challengeCollectionView)
    view.addSubview(noResultView)
    noResultView.translatesAutoresizingMaskIntoConstraints = false
    noResultView.isHidden = true
    
    let safeArea = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      challengeCollectionView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
      challengeCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
      challengeCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
      challengeCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
      
      noResultView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
      noResultView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
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
  
  func reloadData() {
    let savedList = CoreDataManager.shared.getSavedChallengeList()
    divideWithCategory = Dictionary(grouping: savedList) { $0.category ?? "" }
    categories = Array(divideWithCategory.keys).sorted()
    
    if savedList.count > 0 {
      challengeCollectionView.reloadData()
      noResultView.isHidden = true
      challengeCollectionView.isHidden = false
    }else {
      noResultView.isHidden = false
      challengeCollectionView.isHidden = true
    }
    
  }
  
  /// CollectionView 생성
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
      section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 50, trailing: 16)
      
      return section
    }
  }
}

// MARK: CollectionView extension

extension SavedHotChallViewController: UICollectionViewDataSource {
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
    
    cell.challengeData = data
    
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

// MARK: CollectionViewDelegate

extension SavedHotChallViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let category = categories[indexPath.section]
    guard let data: ChallengeVideo = divideWithCategory[category]?[indexPath.item] else { return }

    ChallengePlayerUIManager.shared.showChallPlayer(from: self, data: data)

  }
}

// MARK: 삭제팝업 프로토콜

extension SavedHotChallViewController {
  func showDeletePopup() {
    let vc = PopupViewController()
    vc.delegate = self
    vc.modalPresentationStyle = .overFullScreen
    self.present(vc, animated: false)
  }
}

extension SavedHotChallViewController: ChallengeHeaderViewActionDelegate{
  func didTapShowAllContent(category: String) {
    delegate?.navToHotChallTop100ViewController(with: category)
  }
}

///  MARK: Challenge Player Delegate

extension SavedHotChallViewController: ChallengePlayerViewDelegate {
  func navToTakeChallenge(with data: ChallengeVideo) {

    delegate?.navToTakeChallengeViewController(
      audioFileName: data.mp4FilenameWithoutExtension ?? "",
      subVideoFilename: data.videoFilename
    )
  }
  
  func navToLearnChallenge(with data: ChallengeVideo) {
    delegate?.navToLearnChallengeViewController(with: data)
  }
  
  func navToShowChallenge(with data: ChallengeVideo) {
    guard let challenge = data.videoFilename else { return }
    delegate?.navToShowChallengeViewController(with: challenge)
  }
  
  func saveChallenge(with data: ChallengeVideo) {
  
    guard let uuid = data.id else { return }
    selectedChallengeUUID = uuid
    showDeletePopup()

  }
}

// MARK: 저장된 챌린지 삭제 Delegate

extension SavedHotChallViewController: SavedChallengeDelegate {
  func didTapDeleteButton() {
    guard let uuid = selectedChallengeUUID else { return }
    CoreDataManager.shared.deleteSavedChallenge(with: uuid) {
      ChallengePlayerUIManager.shared.closeChallPlayer()
      ToastPopupManager.shared.showToast(message: "챌린지가 삭제되었습니다.", from: self)
      self.reloadData()
    }
  }
}
