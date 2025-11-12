//
//  SavedChallengeCell.swift
//  HotChal
//
//  Created by 최용헌 on 7/30/25.
//

import UIKit


/// 핫챌 Top3 셀
import UIKit

final class HotChallTopCell: UICollectionViewCell, ReuseIdentifiable {
  
  var challengeData: (ChallengeVideo?, Int?) {
    didSet {
      guard let data = challengeData.0,
            let rank = challengeData.1 else { return }
      configure(with: data, rank: rank)
    }
  }
  
  // 썸네일 이미지
  private let challengeImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 12
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  // 반투명 오버레이
  private let overlayView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  // 랭크 라벨
  private let challengeRankLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 28)
    label.textAlignment = .center
    label.textColor = .white
    label.layer.cornerRadius = 25
    label.layer.masksToBounds = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  // 챌린지 제목
  private let challengeNameLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 18)
    label.textColor = .white
    label.numberOfLines = 1
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.1
    layer.shadowOffset = CGSize(width: 0, height: 4)
    layer.shadowRadius = 6
    makeUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // UI 구성
  private func makeUI() {
    contentView.addSubview(challengeImageView)
    contentView.addSubview(overlayView)
    contentView.addSubview(challengeNameLabel)
    contentView.addSubview(challengeRankLabel)
    
    NSLayoutConstraint.activate([
      challengeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      challengeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      challengeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      challengeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      
      overlayView.leadingAnchor.constraint(equalTo: challengeImageView.leadingAnchor),
      overlayView.trailingAnchor.constraint(equalTo: challengeImageView.trailingAnchor),
      overlayView.bottomAnchor.constraint(equalTo: challengeImageView.bottomAnchor),
      overlayView.heightAnchor.constraint(equalToConstant: 40),
      
      challengeNameLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 8),
      challengeNameLabel.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
      challengeNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: overlayView.trailingAnchor, constant: -8),
      
      challengeRankLabel.bottomAnchor.constraint(equalTo: challengeNameLabel.topAnchor, constant: -15),
      challengeRankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      challengeRankLabel.widthAnchor.constraint(equalToConstant: 50),
      challengeRankLabel.heightAnchor.constraint(equalToConstant: 50)
    ])
  }
  
  // 데이터 세팅
  private func configure(with item: ChallengeVideo, rank: Int) {
    challengeImageView.image = UIImage(named: item.thumbnailImage ?? "")
    challengeNameLabel.text = item.title
    
    // 랭크 + 메달 색상
    challengeRankLabel.text = "\(rank + 1)"
    challengeRankLabel.backgroundColor = .appPink
    //    switch rank {
//    case 0: challengeRankLabel.backgroundColor = .systemYellow   // 금
//    case 1: challengeRankLabel.backgroundColor = .lightGray      // 은
//    case 2: challengeRankLabel.backgroundColor = .systemOrange   // 동
//    default: challengeRankLabel.backgroundColor = .darkGray
//    }
  }
}
