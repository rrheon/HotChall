//
//  HotChallTop100View.swift
//  HotChal
//
//  Created by 최용헌 on 8/1/25.
//

import UIKit

/// HotChall - front - HotChallTop100ViewController
/// UIView
final class HotChallTop100View: UIView {
 
   let top100ListView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 15
    
    let top100ListView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    top100ListView.translatesAutoresizingMaskIntoConstraints = false
    top100ListView.backgroundColor = .clear
    return top100ListView
  }()
  

  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupLayout()
    
    top100ListView.register(ChallegneTop100Cell.self,
                            forCellWithReuseIdentifier: ChallegneTop100Cell.reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// layout 설정
  private func setupLayout(){

    self.addSubview(top100ListView)
    
    NSLayoutConstraint.activate([
      top100ListView.topAnchor.constraint(equalTo:  self.safeAreaLayoutGuide.topAnchor, constant: 5),
      top100ListView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
      top100ListView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
      top100ListView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
    ])
  }
  
}
