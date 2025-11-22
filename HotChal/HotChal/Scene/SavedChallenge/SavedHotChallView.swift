//
//  SavedHotChallView.swift
//  HotChal
//
//  Created by 최용헌 on 11/22/25.
//

import UIKit

final class SavedHotChallView: UIView {
  
  // MARK: - UI
  
  let collectionView: UICollectionView = {
    let view = UICollectionView(
      frame: .zero,
      collectionViewLayout: SavedHotChallView.createLayout()
    )
    view.backgroundColor = .backgroundColor
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let noResultView: UIView = {
    let view = NoResultView(title: "저장된 챌린지가 없습니다.")
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .backgroundColor
    
    setupLayout()
    registerCells()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupLayout()
    registerCells()
  }
  
  // MARK: - Layout Setup
  
  private func setupLayout() {
    addSubview(collectionView)
    addSubview(noResultView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
      collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
      collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
      collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      
      noResultView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
      noResultView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor)
    ])
  }
  
  // MARK: - Register Cell
  
  private func registerCells() {
    collectionView.register(
      ChallengeCell.self,
      forCellWithReuseIdentifier: ChallengeCell.reuseIdentifier
    )
    
    collectionView.register(
      ChallengeCollectionHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: ChallengeCollectionHeaderView.reuseIdentifier
    )
  }
}

// MARK: - Compositional Layout 생성

extension SavedHotChallView {
  static func createLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { sectionIndex, environment in
      
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .absolute(200),
        heightDimension: .absolute(200)
      )
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 10)
      
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .estimated(120),
        heightDimension: .absolute(180)
      )
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: groupSize,
        subitems: [item]
      )
      group.interItemSpacing = .fixed(10)
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .continuous
      
      let headerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(40)
      )
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      section.boundarySupplementaryItems = [header]
      section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 50, trailing: 16)
      
      return section
    }
  }
}
