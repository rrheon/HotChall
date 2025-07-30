//
//  CalendarViewController.swift
//  Moodie
//
//  Created by heojiwoo on 7/29/25.
//
import UIKit
import AVFoundation
import AVKit

// 데이터 모델
struct ChallengeItem {
    let thumbnailImage: UIImage?
    let title: String
    let uploader: String
    let videoFilename: String
}

class LearnViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var didSendEventClosure: ((LearnViewController.Event) -> Void)?
    
    private var collectionView: UICollectionView!
    
    private let items: [ChallengeItem] = [
        ChallengeItem(thumbnailImage: UIImage(named: "Golden1"), title: "골든1", uploader: "랭킹바라", videoFilename: "Golden1"),
        ChallengeItem(thumbnailImage: UIImage(named: "Golden2"), title: "골든2", uploader: "랭킹바라", videoFilename: "Golden2"),
        ChallengeItem(thumbnailImage: UIImage(named: "Pokemon1"), title: "포켓댄스1", uploader: "아이튠스토리", videoFilename: "Pokemon1.mp4"),
        ChallengeItem(thumbnailImage: UIImage(named: "Pokemon2"), title: "포켓댄스2", uploader: "아이즈원", videoFilename: "Pokemon2.mp4"),
        ChallengeItem(thumbnailImage: UIImage(named: "SodaPop1"), title: "소다팝1", uploader: "댄서Yuna", videoFilename: "SodaPop1.mp4"),
        ChallengeItem(thumbnailImage: UIImage(named: "SodaPop2"), title: "소다팝2", uploader: "사자보이즈", videoFilename: "SodaPop2.mp4"),
        ChallengeItem(thumbnailImage: UIImage(named: "SodaPop3"), title: "소다팝3", uploader: "리듬냥", videoFilename: "SodaPop3.mp4"),
        ChallengeItem(thumbnailImage: UIImage(named: "SodaPop4"), title: "소다팝4", uploader: "랭킹바라", videoFilename: "SodaPop4.mp4"),
        ChallengeItem(thumbnailImage: UIImage(named: "Toca1"), title: "토카댄스1", uploader: "랭킹바라", videoFilename: "Toca1.mp4"),
        ChallengeItem(thumbnailImage: UIImage(named: "Toca2"), title: "토카댄스2", uploader: "랭킹바라", videoFilename: "Toca2.mp4"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
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
        collectionView.register(ChallengeCell.self, forCellWithReuseIdentifier: ChallengeCell.identifier)
        
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
        let selectedItem = items[indexPath.item]
        playLocalVideo(named: selectedItem.videoFilename)
    }


    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeCell.identifier, for: indexPath) as! ChallengeCell
        cell.configure(with: items[indexPath.item])
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

#Preview {
    LearnViewController()
}
