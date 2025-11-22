//
//  CalendarViewController.swift
//  Moodie
//
//  Created by heojiwoo on 7/29/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

/// HotChall - front - SavedHotChallViewController
/// 저장된 챌린지 화면
final class SavedHotChallViewController: UIViewController {
  
  weak var coordinator: SavedChallengeCoordinator?
  private var disposeBag = DisposeBag()
  
  // Reactor
  var reactor: SavedHotChallReactor
  
  // UI
  private let mainView = SavedHotChallView()
  
  private let dataSource = SavedChallengeDataSource()
  
  // MARK: Init
  init(reactor: SavedHotChallReactor = SavedHotChallReactor()) {
    self.reactor = reactor
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not implemented")
  }
  
  // MARK: lifecycle
  override func loadView() {
    super.loadView()
    self.view = mainView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "즐겨찾기"
    
    // RxSwift DataSource 설정
    mainView.collectionView.dataSource = dataSource
    mainView.collectionView.rx.setDelegate(self)
      .disposed(by: disposeBag)
    
    bind(reactor: reactor)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reactor.action.onNext(.refresh)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    coordinator?.closeChallPlayer()
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    coordinator?.closeChallPlayer()
  }
  
  // MARK: - bind
  func bind(reactor: SavedHotChallReactor) {
    reactor.action.onNext(.viewDidLoad)

    mainView.collectionView.rx.itemSelected
      .map { SavedHotChallReactor.Action.selectItem($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    Observable.combineLatest(
      reactor.state.map { $0.categories },
      reactor.state.map { $0.categoryMap }
    )
    .distinctUntilChanged { lhs, rhs in
      let (lhsCats, lhsMap) = lhs
      let (rhsCats, rhsMap) = rhs

      guard lhsCats == rhsCats,
            lhsMap.keys.count == rhsMap.keys.count else { return false }

      return lhsMap.keys.allSatisfy { lhsMap[$0]?.count == rhsMap[$0]?.count }
    }
    .observe(on: MainScheduler.instance)
    .subscribe(onNext: { [weak self] categories, categoryMap in
      guard let self = self else { return }
      self.dataSource.categories = categories
      self.dataSource.categoryMap = categoryMap
      self.mainView.collectionView.reloadData()
    })
    .disposed(by: disposeBag)
    
    reactor.state.map { $0.isEmpty }
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] isEmpty in
        guard let self = self else { return }
        self.mainView.noResultView.isHidden = !isEmpty
        self.mainView.collectionView.isHidden = isEmpty
      })
      .disposed(by: disposeBag)
    
    reactor.state.compactMap { $0.selectedChallenge }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] challenge in
        guard let self = self else { return }
        self.coordinator?.showChallPlayer(from: self, data: challenge)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - UICollectionViewDelegate (헤더 delegate 설정)
extension SavedHotChallViewController: UICollectionViewDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    willDisplaySupplementaryView view: UICollectionReusableView,
    forElementKind elementKind: String,
    at indexPath: IndexPath
  ) {
    if elementKind == UICollectionView.elementKindSectionHeader,
       let header = view as? ChallengeCollectionHeaderView {
      header.delegate = self
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SavedHotChallViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let height: CGFloat = 180
    return CGSize(width: 200, height: height)
  }
}

// MARK: Header action delegate
extension SavedHotChallViewController: ChallengeHeaderViewActionDelegate {
  func didTapShowAllContent(category: String) {
    coordinator?.navToHotChallTop100ViewController(with: category)
  }
}

// MARK: 삭제 팝업 delegate
extension SavedHotChallViewController: SavedChallengeDelegate {
  func didTapDeleteButton() {
    coordinator?.closeChallPlayer()
    
    reactor.action.onNext(.confirmDelete)
    
    ToastPopupManager.shared.showToast(message: "챌린지가 삭제되었습니다.", from: self)
  }
}

// MARK: ChallengePlayer Delegate mapping
extension SavedHotChallViewController: ChallengePlayerViewDelegate {
  var challengeNavigationDelegate: ChallengeNavigationDelegate? { coordinator }
  
  func manageChallengeSaveStatus(with data: ChallengeVideo) {
    guard let uuid = data.id else { return }
    reactor.action.onNext(.requestDelete(uuid))
    
    coordinator?.presentDeleteChallengeVC(from: self)
  }
}
