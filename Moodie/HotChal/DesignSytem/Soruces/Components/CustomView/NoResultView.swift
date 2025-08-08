//
//  NoResultView.swift
//  HotChal
//
//  Created by 최용헌 on 8/8/25.
//

import UIKit


/// 검색결과가 없는 경우의 View
final class NoResultView: UIView {
  private let imageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "crying"))
    imageView.tintColor = .white
    imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)

    return imageView
  }()
  
  private let noResultLabel: UILabel = {
    let label = UILabel()
    label.text = "검색결과가 없습니다"
    label.textColor = .white
    
    return label
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayout() {
    self.addSubview(imageView)
    self.addSubview(noResultLabel)
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    noResultLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20),
      imageView.widthAnchor.constraint(equalToConstant: 80),
      imageView.heightAnchor.constraint(equalToConstant: 80),
      
      // noResultLabel 제약
      noResultLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
      noResultLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
    ])
  }
}
