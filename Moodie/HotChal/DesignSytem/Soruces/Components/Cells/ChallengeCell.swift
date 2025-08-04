//
//  ChallengeCell.swift
//  HotChal
//
//  Created by jonghyuck on 7/30/25.
//

import UIKit


/// 챌린지 셀
final class ChallengeCell: UICollectionViewCell, ReuseIdentifiable {
  var challengeData: ChallengeVideo? {
    didSet{
      guard let data = challengeData else { return }
      configure(with: data)
    }
  }
  
  /// 챌린지 썸네일 이미지뷰
  private let thumbnailImageView: UIImageView = {
    let image = UIImageView()
    image.contentMode = .scaleAspectFit
    
    return image
  }()
  
  /// 챌린지 제목 라벨
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 15)
    label.textColor = .white
    label.numberOfLines = 1
    label.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    
    return label
  }()

  /// 챌린지 업로더 라벨
  private let uploaderLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 10)
    label.textColor = .white
    
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    contentView.backgroundColor = .darkGray
    contentView.layer.cornerRadius = 13
    contentView.clipsToBounds = true

    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Layout 설정
  private func setupLayout(){
    contentView.addSubview(thumbnailImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(uploaderLabel)
    
    thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    uploaderLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      thumbnailImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9),
      
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
      titleLabel.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -4),
      
      uploaderLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 4),
      uploaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      uploaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
      uploaderLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 10)
    ])
  }
  
  /// 데이터 설정
  private func configure(with item: ChallengeVideo) {
    thumbnailImageView.image = UIImage(named: item.thumbnailImage ?? "")
    titleLabel.text = item.title
    uploaderLabel.text = item.uploader
  }
}
