//
//  ToolTipView.swift
//  HotChal
//
//  Created by 최용헌 on 8/10/25.
//

import UIKit

final class TooltipView: UIView {
  
  init(text: String) {
    super.init(frame: .zero)
    
    setupLayout(text: text)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayout(text: String){
    let label = UILabel()
    label.text = text
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 12)
    label.numberOfLines = 0
    label.textAlignment = .center
    
    self.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    self.layer.cornerRadius = 8
    self.translatesAutoresizingMaskIntoConstraints = false
    
    label.translatesAutoresizingMaskIntoConstraints = false
    addSubview(label)
    
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
    ])
  }
}
