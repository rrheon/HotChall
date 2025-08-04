//
//  HotChallTop3CategoryView.swift
//  HotChal
//
//  Created by 최용헌 on 8/2/25.
//

import UIKit

/// Main화면 카테고리 별챌린지 View
/// 카테고리 라벨, 전체보기 버튼,  컬렉션뷰
final class HotChallTop3CategoryView: UIView {

  // MARK: - UI Components

  /// 카테고리 라벨
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 18)
    label.textColor = .white
    return label
  }()

  /// 카테고리 제목으로 전체보기 버튼
  let moreButton: UIButton = {
    let button = UIButton(configuration: .plain())
    button.setTitle("전체보기", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
    button.semanticContentAttribute = .forceRightToLeft
    button.configuration?.imagePadding = 10
    button.tintColor = .white
    return button
  }()

  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 20

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.register(ChallengeCell.self,
                            forCellWithReuseIdentifier: ChallengeCell.reuseIdentifier)
    return collectionView
  }()

  private let headerStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .equalCentering
    stackView.spacing = 8
    return stackView
  }()

  // MARK: - Init

  init(title: String) {
    super.init(frame: .zero)
    titleLabel.text = title
    setupLayout()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  private func setupLayout() {
    addSubview(headerStackView)
    addSubview(collectionView)

    headerStackView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.translatesAutoresizingMaskIntoConstraints = false

    headerStackView.addArrangedSubview(titleLabel)
    headerStackView.addArrangedSubview(moreButton)

    NSLayoutConstraint.activate([
      headerStackView.topAnchor.constraint(equalTo: topAnchor),
      headerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
      headerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),

      collectionView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 12),
      collectionView.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
      collectionView.heightAnchor.constraint(equalToConstant: 180)
    ])
  }
}
