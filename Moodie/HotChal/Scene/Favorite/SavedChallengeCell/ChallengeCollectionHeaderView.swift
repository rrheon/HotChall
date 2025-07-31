//
//  ChallengeCollectionHeaderView.swift
//  HotChal
//
//  Created by 최용헌 on 7/30/25.
//

import UIKit

protocol ShowAllContentProtocol: AnyObject {
  func showAllContent()
}

/// 챌린지 컬랙션 뷰의 헤더뷰
final class ChallengeCollectionHeaderView: UICollectionReusableView, ReuseIdentifiable {
  
  weak var delegate: ShowAllContentProtocol?
  
  /// 챌린지 카테고리 라벨
  let challengeCategoryLabel: UILabel = {
    let label = UILabel()
    label.text = "소다팝 챌린지"
    label.font = .systemFont(ofSize: 20)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  /// 카테고리에 속한 챌린지 모두 보기 버튼
  private let showAllContentButton: UIButton = {
    let button = UIButton ()
    button.setTitle("전체보기", for: .normal)
    button.setImage(UIImage(named: "chevron.forward"), for: .normal)
    button.semanticContentAttribute = .forceRightToLeft
    button.translatesAutoresizingMaskIntoConstraints = false
    
    return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    makeUI()
    
    showAllContentButton.addAction(UIAction { [weak self] _ in
      self?.delegate?.showAllContent()
    }, for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// UI 설정하기
  private func makeUI(){
    self.addSubview(challengeCategoryLabel)
    self.addSubview(showAllContentButton)
    
    NSLayoutConstraint.activate([
      challengeCategoryLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
      challengeCategoryLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
     
      showAllContentButton.centerYAnchor.constraint(equalTo: challengeCategoryLabel.centerYAnchor),
      showAllContentButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
    ])
    
  }
  
  
}
