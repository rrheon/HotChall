//
//  HotChalMainView.swift
//  HotChal
//
//  Created by 최용헌 on 8/1/25.
//

import UIKit


/// HotChall - front - HotChallMainViewController
/// UIView
final class HotChalMainView: UIView {
  let scrollView = UIScrollView()
  private let contentView = UIView()
  
  /// 핫챌차트 전체보기 버튼
  let topMoreButton: UIButton = {
    let button = UIButton(configuration: UIButton.Configuration.plain())
    button.setTitle("차트 전체보기", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
    button.semanticContentAttribute = .forceRightToLeft
    button.configuration?.imagePadding = 10
    button.tintColor = .white

    return button
  }()
  
  
  /// 핫챌차트 TOP3 컬렉션뷰
  lazy var topCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 12
    layout.itemSize = CGSize(width: 200, height: 300)
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .clear
    
    return collectionView
  }()
  
  
  lazy var top1ChallengeView = createChallengeSection(title: "소다팝 챌린지")
  lazy var top2ChallengeView = createChallengeSection(title: "챌린지")
  lazy var top3ChallengeView = createChallengeSection(title: "챌린지111111")
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.scrollView.backgroundColor = .backgroundColor
    
    setupLayout()
    
    topCollectionView.register(HotChallTopCell.self,
                               forCellWithReuseIdentifier: HotChallTopCell.reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  /// UI설정
  private func setupLayout() {
    self.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    
    [topMoreButton, topCollectionView, top1ChallengeView, top2ChallengeView, top3ChallengeView]
      .forEach {
      contentView.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
  
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      
      contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      
      topMoreButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
      topMoreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      
      topCollectionView.topAnchor.constraint(equalTo: topMoreButton.bottomAnchor, constant: 12),
      topCollectionView.centerXAnchor.constraint(equalTo: centerXAnchor),
      topCollectionView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7),
      topCollectionView.heightAnchor.constraint(equalToConstant: 300),
      
      top1ChallengeView.topAnchor.constraint(equalTo: topCollectionView.bottomAnchor, constant: 30),
      top1ChallengeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
      top1ChallengeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

      top2ChallengeView.topAnchor.constraint(equalTo: top1ChallengeView.bottomAnchor, constant: 30),
      top2ChallengeView.leadingAnchor.constraint(equalTo: top1ChallengeView.leadingAnchor),
      top2ChallengeView.trailingAnchor.constraint(equalTo: top1ChallengeView.trailingAnchor),

      top3ChallengeView.topAnchor.constraint(equalTo: top2ChallengeView.bottomAnchor, constant: 30),
      top3ChallengeView.leadingAnchor.constraint(equalTo: top1ChallengeView.leadingAnchor),
      top3ChallengeView.trailingAnchor.constraint(equalTo: top1ChallengeView.trailingAnchor),
      top3ChallengeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
    ])

 
  }
  
  
  /// 챌린지 View 생성 (카테고리 라벨 + 컬렉션뷰)
  /// - Parameter title: 챌린지 카테고리
  /// - Returns: 챌린지 UIView
  func createChallengeSection(title: String) -> UIView {
    // 섹션을 담을 전체 컨테이너 뷰
    let containerView = UIView()
    
    // 1. 섹션 헤더 (라벨 + 버튼)
    let headerStackView = UIStackView()
    headerStackView.axis = .horizontal
    headerStackView.distribution = .equalCentering
    headerStackView.spacing = 8
    
    // 라벨 생성
    let titleLabel: UILabel = {
      let label = UILabel()
      label.text = title
      label.font = .boldSystemFont(ofSize: 18)
      label.textColor = .white
      
      return label
    }()
    
    // 전체보기 버튼 생성
    let moreButton: UIButton = {
      let button = UIButton(configuration: UIButton.Configuration.plain())
      button.setTitle("전체보기", for: .normal)
      button.setTitleColor(.white, for: .normal)
      button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
      button.semanticContentAttribute = .forceRightToLeft
      button.configuration?.imagePadding = 10
      button.tintColor = .white
      
      return button
    }()


    // 헤더 스택 뷰에 라벨과 버튼 추가
    headerStackView.addArrangedSubview(titleLabel)
    headerStackView.addArrangedSubview(moreButton)
        
    // 2. 컬렉션 뷰
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 20
    layout.itemSize = CGSize(width: 120, height: 180)
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .clear
    collectionView.register(SavedChallengeCell.self,
                            forCellWithReuseIdentifier: SavedChallengeCell.reuseIdentifier)
    
    // 3. 전체 뷰에 헤더와 컬렉션 뷰 추가
    containerView.addSubview(headerStackView)
    containerView.addSubview(collectionView)
    
    headerStackView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([

      // 헤더 스택 뷰 제약 조건
      headerStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
      headerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
      headerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
      
      // 컬렉션 뷰 제약 조건
      collectionView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 12),
      collectionView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      collectionView.heightAnchor.constraint(equalToConstant: 180)
    ])
    
    return containerView
  }
}
