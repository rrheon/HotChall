//
//  SavedChallengeCell.swift
//  HotChal
//
//  Created by 최용헌 on 7/30/25.
//

import UIKit


/// 핫챌 Top3 셀
final class HotChallTopCell: UICollectionViewCell, ReuseIdentifiable {
  var challengeData: (ChallengeVideo?, Int?) {
    didSet{
      guard let data = challengeData.0,
            let rank = challengeData.1 else { return }
      configure(with: data, rank: rank)
    }
  }
  /// 챌린지 썸네일 이미지뷰
   var challengeImageView: UIImageView = {
    let imageView = UIImageView()
     imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
     imageView.backgroundColor = .cellBackground
    return imageView
  }()
  
  /// 챌린지 랭킹 라벨
  private let challengeRankLabel: UILabel = {
    let label = UILabel()
    label.text = "1"
    label.font = .boldSystemFont(ofSize: 36)
    label.textColor = .black
    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
  }()
  
  /// 챌린지 이름 라벨
   var challengeNameLabel: UILabel = {
    let label = UILabel()
    label.text = "챌린지 제목"
     label.textColor = .black
     label.font = .boldSystemFont(ofSize: 20)
    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .white
    makeUI()
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// UI 설정
  private func makeUI(){
    self.addSubview(challengeImageView)
    self.addSubview(challengeNameLabel)
    self.addSubview(challengeRankLabel)
    
    NSLayoutConstraint.activate([
      challengeImageView.topAnchor.constraint(equalTo: self.topAnchor),
      challengeImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      challengeImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      challengeImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      challengeImageView.widthAnchor.constraint(equalTo: self.widthAnchor),
      challengeImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
      
      challengeNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -10),
      challengeNameLabel.leadingAnchor.constraint(equalTo: challengeImageView.leadingAnchor, constant: 20),
      
      challengeRankLabel.topAnchor.constraint(equalTo: challengeNameLabel.topAnchor, constant: -40),
      challengeRankLabel.leadingAnchor.constraint(equalTo: challengeNameLabel.leadingAnchor),
    ])
    
  }
  
  /// 데이터 설정
  private func configure(with item: ChallengeVideo, rank: Int) {
    challengeImageView.image = UIImage(named: item.thumbnailImage ?? "")
    challengeNameLabel.text = item.title
    challengeRankLabel.text = "\(rank + 1)"
  }
}
