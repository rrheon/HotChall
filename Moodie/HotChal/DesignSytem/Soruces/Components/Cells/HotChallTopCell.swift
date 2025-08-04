//
//  SavedChallengeCell.swift
//  HotChal
//
//  Created by 최용헌 on 7/30/25.
//

import UIKit


/// 핫챌 Top3 셀
final class HotChallTopCell: UICollectionViewCell, ReuseIdentifiable {
  
  /// 챌린지 썸네일 이미지뷰
   var challengeImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.backgroundColor = .blue
    return imageView
  }()
  
  /// 챌린지 랭킹 라벨
  private let challengeRankLabel: UILabel = {
    let label = UILabel()
    label.text = "1"
    label.font = .boldSystemFont(ofSize: 36)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
  }()
  
  /// 챌린지 이름 라벨
   var challengeNameLabel: UILabel = {
    let label = UILabel()
    label.text = "챌린지 제목"
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
  }()
  
  /// 챌린지 재생버튼
  private let challengePlayButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "play.circle"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false

    return button
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .appPink
    makeUI()
    
    challengePlayButton.addAction(UIAction { _ in
      print(#fileID, #function, #line, "- 챌린지 재생버튼 탭")

    }, for: .touchUpInside)
  }
  
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// UI 설정
  private func makeUI(){
    self.addSubview(challengeImageView)
    self.addSubview(challengeNameLabel)
    self.addSubview(challengeRankLabel)
    self.addSubview(challengePlayButton)
    
    NSLayoutConstraint.activate([
      challengeImageView.topAnchor.constraint(equalTo: self.topAnchor),
      challengeImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      challengeImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      challengeImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      challengeImageView.widthAnchor.constraint(equalTo: self.widthAnchor),
      challengeImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
      
      challengeNameLabel.bottomAnchor.constraint(equalTo: challengeImageView.bottomAnchor),
      challengeNameLabel.leadingAnchor.constraint(equalTo: challengeImageView.leadingAnchor, constant: 20),
      
      challengeRankLabel.topAnchor.constraint(equalTo: challengeNameLabel.topAnchor, constant: -30),
      challengeRankLabel.leadingAnchor.constraint(equalTo: challengeNameLabel.leadingAnchor),
      
      challengePlayButton.centerYAnchor.constraint(equalTo: challengeNameLabel.centerYAnchor),
      challengePlayButton.trailingAnchor.constraint(equalTo: challengeImageView.trailingAnchor, constant: -20),
      challengePlayButton.bottomAnchor.constraint(equalTo: challengeImageView.bottomAnchor, constant: -20),
    ])
    
  }
}
