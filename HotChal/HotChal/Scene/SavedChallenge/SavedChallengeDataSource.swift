//
//  SavedChallengeDataSource.swift
//  HotChal
//
//  Created by 최용헌 on 11/22/25.
//

import UIKit

/// SavedChallengeCollectionView DataSource
final class SavedChallengeDataSource: NSObject, UICollectionViewDataSource {
  var categories: [String] = []
  var categoryMap: [String: [ChallengeVideo]] = [:]
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return categories.count
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    let category = categories[section]
    return categoryMap[category]?.count ?? 0
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: ChallengeCell.reuseIdentifier,
      for: indexPath
    ) as? ChallengeCell else {
      return UICollectionViewCell()
    }
    
    let category = categories[indexPath.section]
    if let data = categoryMap[category]?[indexPath.item] {
      cell.challengeData = data
    }
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
          ) as? ChallengeCollectionHeaderView else {
      return UICollectionReusableView()
    }
    
    let category = categories[indexPath.section]
    header.challengeCategoryLabel.text = category
    return header
  }
}
