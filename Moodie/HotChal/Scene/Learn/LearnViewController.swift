//
//  CalendarViewController.swift
//  Moodie
//
//  Created by heojiwoo on 7/29/25.
//
import UIKit
import AVFoundation
import AVKit


class LearnViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
    var didSendEventClosure: ((LearnViewController.Event) -> Void)?
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "핫한 챌린지 배우기 🔥"
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(LearnChallengeCell.self, forCellWithReuseIdentifier: LearnChallengeCell.identifier)
        
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
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
      let selectedItem = MockupDataManager.shared.challengeVideos[indexPath.item]
      playLocalVideo(named: selectedItem.videoFilename ?? "")
    }


    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return MockupDataManager.shared.challengeVideos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LearnChallengeCell.identifier, for: indexPath) as! LearnChallengeCell
        cell.configure(with: MockupDataManager.shared.challengeVideos[indexPath.item])
        return cell
    }

    
    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 50) / 2
        return CGSize(width: width, height: width * 1.5)
    }
    
}

extension LearnViewController {
    enum Event {
        case learnViewControllerTwo
    }
}
//
//#Preview {
//    LearnViewController()
//}
