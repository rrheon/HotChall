//
//  CalendarViewController.swift
//  Moodie
//
//  Created by heojiwoo on 7/29/25.
//
import UIKit
import RxSwift
import RxCocoa

/// HotChall - front - HotChallLearnViewController
/// 챌린지 배우기 화면
final class HotChallLearnViewController: UIViewController {

  weak var coordinator: HotChallLearnCoordinator?

  var reactor: HotChallLearnReactor? = nil
  private let disposeBag: DisposeBag = DisposeBag()

  /// 챌린지 검색 서치바
  private let challengeSearchbar: UISearchBar = UISearchBar()

  /// 추천 및 검색결과 collectionView
  private let collectionView: UICollectionView = {
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

  private let recommendChallengeLabel: UILabel = {
    let label = UILabel()
    label.text = "추천 챌린지"
    label.font = .systemFont(ofSize: 18)
    label.translatesAutoresizingMaskIntoConstraints = false


    return label
  }()

  private let noResultView: UIView = NoResultView()

  // MARK: viewDidLoad

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "챌린지 배우기"

    self.view.backgroundColor = .backgroundColor

    setupCollectionView()
    setupSearchBar()
    setupLayout()

    
    let reactor = reactor ?? HotChallLearnReactor()
    self.reactor = reactor
    bind(with: reactor)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    coordinator?.closeChallPlayer()
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    coordinator?.closeChallPlayer()
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    view.endEditing(true)
    coordinator?.closeChallPlayer()
  }

  // collectionView 설정
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.register(ChallengeCell.self, forCellWithReuseIdentifier: ChallengeCell.reuseIdentifier)
  }

  // searchBar 설정
  private func setupSearchBar(){
    challengeSearchbar.translatesAutoresizingMaskIntoConstraints = false
    challengeSearchbar.backgroundImage = UIImage()

    if let searchBarTextField = challengeSearchbar.value(forKey: "searchField") as? UITextField {
      searchBarTextField.font = UIFont.systemFont(ofSize: 14)
      searchBarTextField.textColor = .black
      searchBarTextField.layer.cornerRadius = 10
      searchBarTextField.layer.masksToBounds = true
      searchBarTextField.backgroundColor = .white
      searchBarTextField.layer.borderColor = UIColor.lightGray.cgColor
      searchBarTextField.layer.borderWidth = 0.5

      let placeholderText = "챌린지 이름을 입력하세요."
         let attributedString = NSAttributedString(
          string: placeholderText,
          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
         )
         searchBarTextField.attributedPlaceholder = attributedString

      if let leftView = searchBarTextField.leftView as? UIImageView  {
        leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
        leftView.tintColor = .gray
      }

      let clearButton = searchBarTextField.value(forKey: "clearButton") as? UIButton
      clearButton?.setImage(clearButton?.imageView?.image?.withRenderingMode(.alwaysTemplate),
                            for: .normal)
      clearButton?.tintColor = .gray
    }
  }

  // layout 설정
  private func setupLayout(){
    view.addSubview(challengeSearchbar)
    view.addSubview(collectionView)
    view.addSubview(recommendChallengeLabel)
    view.addSubview(noResultView)
    noResultView.translatesAutoresizingMaskIntoConstraints = false
    noResultView.isHidden = true

    NSLayoutConstraint.activate([
      challengeSearchbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                              constant: 10),
      challengeSearchbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      challengeSearchbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      challengeSearchbar.heightAnchor.constraint(equalToConstant: 44),

      recommendChallengeLabel.topAnchor.constraint(equalTo: challengeSearchbar.bottomAnchor, constant: 20),
      recommendChallengeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 10),

      collectionView.topAnchor.constraint(equalTo: recommendChallengeLabel.bottomAnchor, constant: 5),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: recommendChallengeLabel.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      noResultView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
      noResultView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
    ])
  }

  // MARK: bind

  private func bind(with reactor: HotChallLearnReactor) {
    // 초기 데이터 로드
    Observable.just(())
      .map { HotChallLearnReactor.Action.setupInitialDatas }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // 검색어 입력 (debounce 적용)
    challengeSearchbar.rx.text.orEmpty
      .skip(1)
      .debounce(.seconds(1), scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .map { HotChallLearnReactor.Action.searchTextChanged($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // 검색 버튼 클릭 시 키보드 숨김
    challengeSearchbar.rx.searchButtonClicked
      .subscribe(onNext: { [weak self] in
        self?.view.endEditing(true)
      })
      .disposed(by: disposeBag)

    // 챌린지 선택
    collectionView.rx.itemSelected
      .map { HotChallLearnReactor.Action.selectChallenge($0.row) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // State 바인딩 - 챌린지 데이터
    reactor.state.map { $0.challengeDatas }
      .bind(to: collectionView.rx.items(
        cellIdentifier: ChallengeCell.reuseIdentifier,
        cellType: ChallengeCell.self)) { _, video, cell in
          cell.challengeData = video
        }
        .disposed(by: disposeBag)

    // State 바인딩 - 검색 결과 없음 표시
    reactor.state.map { $0.hasResults }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] hasResults in
        self?.noResultView.isHidden = hasResults
        self?.collectionView.isHidden = !hasResults
      })
      .disposed(by: disposeBag)

    
    // State 바인딩 - 챌린지 선택 시 플레이어 표시
    reactor.state.compactMap { $0.selectedChallenge }
      .withUnretained(self)
      .subscribe(onNext: { owner, video in
        owner.coordinator?.showChallPlayer(from: owner, data: video)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HotChallLearnViewController: UICollectionViewDelegateFlowLayout{

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let width = (collectionView.frame.width - 50) / 2
    return CGSize(width: width, height: width * 1.5)
  }
}

// MARK: Challenge Player Delegate

extension HotChallLearnViewController: ChallengePlayerViewDelegate {
  var challengeNavigationDelegate: ChallengeNavigationDelegate? { coordinator }
}
