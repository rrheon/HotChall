//
//  ChallengeVideoCell.swift
//  HotChal
//
//  Created by 최용헌 on 7/31/25.
//

import UIKit

/// 챌린지 영상 셀
final class ChallengeVideoCell: UICollectionViewCell, ReuseIdentifiable {
 
  private let imageView = UIImageView()
  private let titleLabel = UILabel()
  private let uploaderLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupViews()
    self.backgroundColor = .appPink
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  /// 데이터에 따라 UI에 넣어주기
  /// - Parameter video: 셀의 데이터
  func configure(with video: ChallengeVideo) {
    guard let image = video.thumbnailImage else { return }
    
    imageView.image = UIImage(named: image)
    titleLabel.text = video.title
    uploaderLabel.text = video.uploader
  }
  
  
  /// layout 설정
  private func setupViews() {
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 8
    
    titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
    titleLabel.numberOfLines = 2
    
    uploaderLabel.font = .systemFont(ofSize: 12)
    uploaderLabel.textColor = .gray
    
    
    let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, uploaderLabel])
    stackView.axis = .vertical
    stackView.spacing = 4
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      imageView.heightAnchor.constraint(equalToConstant: 120),
      
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
}
