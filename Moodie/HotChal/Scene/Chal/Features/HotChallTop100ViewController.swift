//
//  HotChallTop100ViewController.swift
//  HotChal
//
//  Created by 이지훈 on 7/30/25.
//

import UIKit

class HotChallTop100ViewController: UIViewController {
    
    private let sampleData: [String] = (1...20).map { "🔥 챌린지 \($0)번" }
    
    private let allPlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle( "전체재생", for: .normal)
        button.backgroundColor = .grayEmotion
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        
        return button
    }()
    
    private let randomPlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle( "랜덤재생", for: .normal)
        button.backgroundColor = .grayEmotion
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        
        return button
    }()
    
    private let buttonsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let top100ListView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 80)
        layout.minimumLineSpacing = 12
        
        let top100ListView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        top100ListView.translatesAutoresizingMaskIntoConstraints = false
        top100ListView.backgroundColor = .clear
        return top100ListView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.navigationItem.title = "핫챌 TOP100"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.white
        ]
        appearance.backgroundColor = .black
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
        self.navigationItem.titleView?.backgroundColor = .black
        
        top100ListView.dataSource = self
        top100ListView.register(ChallengeCell.self, forCellWithReuseIdentifier: "ChallengeCell")
        
        
        view.addSubview(buttonsContainerView)
        buttonsContainerView.addSubview(allPlayButton)
        buttonsContainerView.addSubview(randomPlayButton)
        view.addSubview(top100ListView)
        
        allPlayButton.translatesAutoresizingMaskIntoConstraints = false
        randomPlayButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            
            buttonsContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            buttonsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            buttonsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            buttonsContainerView.heightAnchor.constraint(equalToConstant: 70),
            

            allPlayButton.leadingAnchor.constraint(equalTo: buttonsContainerView.leadingAnchor, constant: 10),
            allPlayButton.topAnchor.constraint(equalTo: buttonsContainerView.topAnchor, constant: 10),
            allPlayButton.bottomAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor, constant: -10),
            allPlayButton.trailingAnchor.constraint(equalTo: buttonsContainerView.centerXAnchor, constant: -5),
            
            randomPlayButton.leadingAnchor.constraint(equalTo: buttonsContainerView.centerXAnchor, constant: 5),
            randomPlayButton.topAnchor.constraint(equalTo: buttonsContainerView.topAnchor, constant: 10),
            randomPlayButton.bottomAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor, constant: -10),
            randomPlayButton.trailingAnchor.constraint(equalTo: buttonsContainerView.trailingAnchor, constant: -10),
            
            top100ListView.topAnchor.constraint(equalTo: allPlayButton.bottomAnchor, constant: 20),
            top100ListView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            top100ListView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            top100ListView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
}

class ChallengeCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray5
        contentView.layer.cornerRadius = 5
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HotChallTop100ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sampleData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChallengeCell", for: indexPath) as! ChallengeCell
        cell.titleLabel.text = sampleData[indexPath.item]
        return cell
    }
}


#Preview {
    HotChallTop100ViewController()
}
