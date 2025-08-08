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
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .white
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.isPagingEnabled = true
    collectionView.layer.cornerRadius = 10
    
    return collectionView
  }()
  
  /// 각 챌린지의 카테고리에 맞는 컬렉션뷰
  let top1ChallengeView = HotChallTop3CategoryView(title: "소다팝 챌린지")
  let top2ChallengeView = HotChallTop3CategoryView(title: "챌린지1")
  let top3ChallengeView = HotChallTop3CategoryView(title: "챌린지2")
  
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
}
