//
//  ChallegneTop100Cell.swift
//  HotChal
//
//  Created by 최용헌 on 8/1/25.
//

import UIKit


/// 챌린지 Top100 Cell
final class ChallegneTop100Cell: UICollectionViewCell, ReuseIdentifiable {
  
  // 챌린지 랭크 라벨
   let challengeRankLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 18)
     label.textColor = .appPink
    return label
  }()
  
  // 썸네일 이미지뷰
   let challengeThumbnailView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "SodaPop4")
     imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    
    return imageView
  }()
  
  // 챌린지 타이틀라벨
  let challengeTitleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 18, weight: .bold)
    label.textColor = .label
    
    return label
  }()
  
  // 챌린지 올린사람 라벨
  let challengeArtistLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14, weight: .medium)
    label.textColor = .gray
    
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
 
//    contentView.backgroundColor = .systemGray5
//    contentView.layer.cornerRadius = 5
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // layout 설정
  private func setupLayout(){
    [challengeRankLabel, challengeThumbnailView, challengeTitleLabel, challengeArtistLabel]
      .forEach {
        $0.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview($0)
    }
    
    NSLayoutConstraint.activate([
      
      challengeRankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
      challengeRankLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      challengeRankLabel.widthAnchor.constraint(equalToConstant: 40),
      
      challengeThumbnailView.leadingAnchor.constraint(equalTo: challengeRankLabel.trailingAnchor,
                                                      constant: 10),
      challengeThumbnailView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      challengeThumbnailView.heightAnchor.constraint(equalToConstant: 60),
      challengeThumbnailView.widthAnchor.constraint(equalTo: challengeThumbnailView.heightAnchor,
                                                    multiplier: 2),
      
      challengeTitleLabel.leadingAnchor.constraint(equalTo: challengeThumbnailView.trailingAnchor,
                                                   constant: 30),
      challengeTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
      challengeTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor,
                                                    constant: -10),
      
      challengeArtistLabel.leadingAnchor.constraint(equalTo: challengeTitleLabel.leadingAnchor),
      challengeArtistLabel.topAnchor.constraint(equalTo: challengeTitleLabel.bottomAnchor,
                                                constant: 10),
    ])
  }
}
