//
//  SavedChallengeCell.swift
//  HotChal
//
//  Created by 최용헌 on 7/30/25.
//

import UIKit


protocol DeleteSavedChallengeProtocol: AnyObject {
  func showDeletePopup()
}

/// 저장된 챌린지의 셀
final class SavedChallengeCell: UICollectionViewCell, ReuseIdentifiable {
  weak var delegate: DeleteSavedChallengeProtocol?
  
  /// 챌린지 썸네일 이미지뷰
   var challengeImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    return imageView
  }()
  
  /// 챌린지 이름 라벨
   var challengeNameLabel: UILabel = {
    let label = UILabel()
    label.text = "챌린지 제목"
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
  }()
  
  /// 챌린지 저장 버튼
  private let challengeSaveButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "star"), for: .normal)
    button.tintColor = .white
    button.translatesAutoresizingMaskIntoConstraints = false
    
    return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .appPink
    makeUI()
    
    challengeSaveButton.addAction(UIAction { [weak self] _ in
      self?.delegate?.showDeletePopup()
    }, for: .touchUpInside)
    
  }
  
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// UI 설정
  private func makeUI(){
    self.addSubview(challengeImageView)
    self.addSubview(challengeNameLabel)
    self.addSubview(challengeSaveButton)
    
    NSLayoutConstraint.activate([
      challengeImageView.topAnchor.constraint(equalTo: self.topAnchor),
      challengeImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      challengeImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      challengeImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      
      challengeNameLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
      challengeNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
      challengeNameLabel.trailingAnchor.constraint(equalTo: challengeSaveButton.leadingAnchor,
                                                   constant: 10),
      
      challengeSaveButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
      challengeSaveButton.topAnchor.constraint(equalTo: challengeNameLabel.topAnchor)
    ])
    
  }
}
