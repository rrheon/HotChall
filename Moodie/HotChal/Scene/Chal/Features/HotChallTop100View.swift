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
  private let buttonsContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemGray6
    view.layer.cornerRadius = 5
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let allPlayButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle( "전체재생", for: .normal)
    button.backgroundColor = .grayEmotion
    button.setTitleColor(.white, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.cornerRadius = 5
    
    return button
  }()
  
  private let randomPlayButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle( "랜덤재생", for: .normal)
    button.backgroundColor = .grayEmotion
    button.setTitleColor(.white, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.cornerRadius = 5
    
    return button
  }()
  
   let top100ListView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 5
    
    let top100ListView = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
    top100ListView.translatesAutoresizingMaskIntoConstraints = false
    top100ListView.backgroundColor = .clear
    return top100ListView
  }()
  
  private let top100ListContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemGray6
    view.layer.cornerRadius = 5
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
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
    
    self.addSubview(buttonsContainerView)
    buttonsContainerView.addSubview(allPlayButton)
    buttonsContainerView.addSubview(randomPlayButton)
    
    self.addSubview(top100ListContainerView)
    top100ListContainerView.addSubview(top100ListView)
    
    
    NSLayoutConstraint.activate([
      
      buttonsContainerView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
      buttonsContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
      buttonsContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
      buttonsContainerView.heightAnchor.constraint(equalToConstant: 65),
      
      
      allPlayButton.leadingAnchor.constraint(equalTo: buttonsContainerView.leadingAnchor, constant: 5),
      allPlayButton.topAnchor.constraint(equalTo: buttonsContainerView.topAnchor, constant: 5),
      allPlayButton.bottomAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor, constant: -5),
      allPlayButton.trailingAnchor.constraint(equalTo: buttonsContainerView.centerXAnchor, constant: -5),
      
      randomPlayButton.leadingAnchor.constraint(equalTo: buttonsContainerView.centerXAnchor, constant: 5),
      randomPlayButton.topAnchor.constraint(equalTo: buttonsContainerView.topAnchor, constant: 5),
      randomPlayButton.bottomAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor, constant: -5),
      randomPlayButton.trailingAnchor.constraint(equalTo: buttonsContainerView.trailingAnchor, constant: -5),
      
      top100ListContainerView.topAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor, constant: 5),
      top100ListContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
      top100ListContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
      top100ListContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
      
      top100ListView.topAnchor.constraint(equalTo: top100ListContainerView.topAnchor, constant: 5),
      top100ListView.leadingAnchor.constraint(equalTo: top100ListContainerView.leadingAnchor, constant: 5),
      top100ListView.trailingAnchor.constraint(equalTo: top100ListContainerView.trailingAnchor, constant: -5),
      top100ListView.bottomAnchor.constraint(equalTo: top100ListContainerView.bottomAnchor, constant: -5)
    ])
  }
  
}
