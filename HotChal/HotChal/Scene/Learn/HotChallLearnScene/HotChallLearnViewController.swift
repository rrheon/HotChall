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
  
  weak var coordinator: HotChallLearnCoordinator?
  
  var searchTimer: Timer?

  
  lazy var challengeDatas: [ChallengeVideo] = []
  
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
    
    challengeDatas = MockupDataManager.shared.recommendChallengeVideos
    
    setupCollectionView()
    setupSearchBar()
    setupLayout()
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
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(ChallengeCell.self, forCellWithReuseIdentifier: ChallengeCell.reuseIdentifier)
  }
  
  // searchBar 설정
  private func setupSearchBar(){
    challengeSearchbar.delegate = self
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
}


// MARK: - UICollectionViewDataSource

extension HotChallLearnViewController: UICollectionViewDataSource {
  
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
      withReuseIdentifier: ChallengeCell.reuseIdentifier,
      for: indexPath
    ) as? ChallengeCell else { return UICollectionViewCell() }
    
    cell.challengeData = challengeDatas[indexPath.row]
    
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HotChallLearnViewController: UICollectionViewDelegateFlowLayout{
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    view.endEditing(true)

    let challengeData: ChallengeVideo = challengeDatas[indexPath.item]

    coordinator?.showChallPlayer(from: self, data: challengeData)
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

// MARK: Challenge Player Delegate

extension HotChallLearnViewController: ChallengePlayerViewDelegate {
  var challengeNavigationDelegate: ChallengeNavigationDelegate? { coordinator }
}


// MARK: SearchBar Delegate

extension HotChallLearnViewController: UISearchBarDelegate {
  func searchBar(
    _ searchBar: UISearchBar,
    shouldChangeTextIn range: NSRange,
    replacementText text: String
  ) -> Bool {
    let maxLength = 20
    let currentText = searchBar.text ?? ""
    let newLength = (currentText.count ) + text.count - range.length

    return newLength <= maxLength
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.searchTimer?.invalidate()
    self.searchTimer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                            repeats: false,
                                            block: { [weak self] timer in
      guard let self = self else { return }
      if searchText.isEmpty {
          challengeDatas = MockupDataManager.shared.recommendChallengeVideos
      } else {
          challengeDatas = MockupDataManager.shared.challengeVideos.filter {
              $0.title?.contains(searchText) ?? false
          }
      }
      
      let hasResults = !challengeDatas.isEmpty
      noResultView.isHidden = hasResults
      collectionView.isHidden = !hasResults
      
      collectionView.reloadData()
    })
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    view.endEditing(true)
  }
}
