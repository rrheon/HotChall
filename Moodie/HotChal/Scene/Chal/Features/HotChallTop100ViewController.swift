//
//  HotChallTop100ViewController.swift
//  HotChal
//
//  Created by 이지훈 on 7/30/25.
//

import UIKit
import AVFoundation
import AVKit

class HotChallTop100ViewController: UIViewController {
    
    private let sampleData: [String] = Array(repeating: "챌린지 제목", count: 100) // 임시
    private let sampleData2: [String] = Array(repeating: "아티스트", count: 100)
    
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
    
    private let top100ListView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
        layout.minimumLineSpacing = 5
        
        let top100ListView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
    
    
    // MARK: - View
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
        top100ListView.delegate = self
        top100ListView.register(TOP100ChallengeCell.self, forCellWithReuseIdentifier: "ChallengeCell")
        
        
        // 임시
        [allPlayButton, randomPlayButton].forEach {
            $0.addAction(UIAction { _ in
                self.playLocalVideo(named: "sodaPop4.mp4")
            }, for: .touchUpInside)
        }
        
        view.addSubview(buttonsContainerView)
        buttonsContainerView.addSubview(allPlayButton)
        buttonsContainerView.addSubview(randomPlayButton)
        view.addSubview(top100ListContainerView)
        top100ListContainerView.addSubview(top100ListView)
        
        
        NSLayoutConstraint.activate([
            
            buttonsContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            buttonsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            buttonsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
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
            top100ListContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            top100ListContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            top100ListContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
            
            top100ListView.topAnchor.constraint(equalTo: top100ListContainerView.topAnchor, constant: 5),
            top100ListView.leadingAnchor.constraint(equalTo: top100ListContainerView.leadingAnchor, constant: 5),
            top100ListView.trailingAnchor.constraint(equalTo: top100ListContainerView.trailingAnchor, constant: -5),
            top100ListView.bottomAnchor.constraint(equalTo: top100ListContainerView.bottomAnchor, constant: -5)
        ])
    }
    
}

// MARK: - Cell 디자인

class TOP100ChallengeCell: UICollectionViewCell {
    
    let numberLabel = UILabel()
    let chalThumbnailView = UIImageView()
    let titleLabel = UILabel()
    let artistLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray5
        contentView.layer.cornerRadius = 5
        
        // 1. 번호
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.font = .boldSystemFont(ofSize: 18)
        numberLabel.textColor = .darkGray
        
        // 2. 썸네일
        chalThumbnailView.translatesAutoresizingMaskIntoConstraints = false
        chalThumbnailView.image = UIImage(named: "SodaPop4")
        chalThumbnailView.contentMode = .scaleAspectFill
        chalThumbnailView.clipsToBounds = true
        
        // 3. 챌린지 제목
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = .label
        
        // 4. 아티스트명
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.font = .systemFont(ofSize: 15, weight: .medium)
        artistLabel.textColor = .label
        
        
        contentView.addSubview(numberLabel)
        contentView.addSubview(chalThumbnailView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        
        
        NSLayoutConstraint.activate([
            
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            numberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            
            chalThumbnailView.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 8),
            chalThumbnailView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chalThumbnailView.heightAnchor.constraint(equalToConstant: 60),
            chalThumbnailView.widthAnchor.constraint(equalTo: chalThumbnailView.heightAnchor, multiplier: 2),
            
            
            titleLabel.leadingAnchor.constraint(equalTo: chalThumbnailView.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionView 데이터소스 (챌린지 목록)

extension HotChallTop100ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sampleData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChallengeCell", for: indexPath) as! TOP100ChallengeCell
        
        let number = indexPath.item + 1
        cell.numberLabel.text = "\(number)"
        cell.titleLabel.text = sampleData[indexPath.item]
        cell.artistLabel.text = sampleData2[indexPath.item]
        
        return cell
    }
    
}



@available(iOS 17.0, *)
#Preview {
    UINavigationController(rootViewController: HotChallTop100ViewController())
}


// MARK: 임시

extension HotChallTop100ViewController: UICollectionViewDelegateFlowLayout{
    private func playLocalVideo(named filename: String) {
        guard let path = Bundle.main.path(forResource: filename, ofType: nil) else {
            print("❌ 영상 파일을 찾을 수 없습니다: \(filename)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        
        present(playerVC, animated: true) {
            player.play()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- <#comment#>")
        
        
        playLocalVideo(named: "sodaPop4.mp4")
        
    }
}
