//
//  HotChallViewController.swift
//  HotChal
//
//  Created by 최용헌 on 7/31/25.
//

import UIKit
import AVFoundation
import AVKit

// 임시
final class ChallengeVideoCell: UICollectionViewCell {
  static let reuseIdentifier = "ChallengeVideoCell"
  
  private let imageView = UIImageView()
  private let titleLabel = UILabel()
  private let uploaderLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    self.backgroundColor = .appPink
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(with video: ChallengeVideo) {
    imageView.image = video.thumbnailImage
    titleLabel.text = video.title
    uploaderLabel.text = video.uploader
  }
  
  private func setupViews() {
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 8
    titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
    uploaderLabel.font = .systemFont(ofSize: 12)
    uploaderLabel.textColor = .gray
    titleLabel.numberOfLines = 2
    
    let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, uploaderLabel])
    stackView.axis = .vertical
    stackView.spacing = 4
    contentView.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
}





class HotChallViewController: UIViewController {

  weak var delegate: ChalCoordinator?
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let topLabel: UILabel = {
        let label = UILabel()
        label.text = "핫챌 TOP3"
        label.font = .boldSystemFont(ofSize: 22)
        return label
    }()

    private let topMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("전체보기", for: .normal)
        return button
    }()

    private lazy var topCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: 200, height: 300)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
      collectionView.delegate = self
        return collectionView
    }()

    private let middleLabel: UILabel = {
        let label = UILabel()
        label.text = "챌린지"
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()

    private let middleMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("전체보기", for: .normal)
        return button
    }()

    private lazy var middleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 120, height: 180)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
      collectionView.delegate = self
        return collectionView
    }()

    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "챌린지"
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()

    private let bottomMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("전체보기", for: .normal)
        return button
    }()

    private lazy var bottomCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 120, height: 180)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
      collectionView.delegate = self
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        registerCells()
    }

    private func registerCells() {
        topCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Top3Cell")
        middleCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "HorizontalCell1")
        bottomCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "HorizontalCell2")
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [topLabel, topMoreButton, topCollectionView,
         middleLabel, middleMoreButton, middleCollectionView,
         bottomLabel, bottomMoreButton, bottomCollectionView
        ].forEach { contentView.addSubview($0) }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        [topLabel, topMoreButton, topCollectionView,
         middleLabel, middleMoreButton, middleCollectionView,
         bottomLabel, bottomMoreButton, bottomCollectionView
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            topLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            topMoreButton.centerYAnchor.constraint(equalTo: topLabel.centerYAnchor),
            topMoreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            topCollectionView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 12),
            topCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topCollectionView.heightAnchor.constraint(equalToConstant: 300),

            middleLabel.topAnchor.constraint(equalTo: topCollectionView.bottomAnchor, constant: 24),
            middleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            middleMoreButton.centerYAnchor.constraint(equalTo: middleLabel.centerYAnchor),
            middleMoreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            middleCollectionView.topAnchor.constraint(equalTo: middleLabel.bottomAnchor, constant: 12),
            middleCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            middleCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            middleCollectionView.heightAnchor.constraint(equalToConstant: 180),

            bottomLabel.topAnchor.constraint(equalTo: middleCollectionView.bottomAnchor, constant: 24),
            bottomLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            bottomMoreButton.centerYAnchor.constraint(equalTo: bottomLabel.centerYAnchor),
            bottomMoreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            bottomCollectionView.topAnchor.constraint(equalTo: bottomLabel.bottomAnchor, constant: 12),
            bottomCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomCollectionView.heightAnchor.constraint(equalToConstant: 180),

            bottomCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
      
      [topMoreButton, bottomMoreButton, middleMoreButton]
        .forEach {
          $0.addAction( UIAction { _ in
            let vc = CameraViewController()
            self.navigationController?.pushViewController(vc, animated: true)
          }, for: .touchUpInside)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension HotChallViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topCollectionView {
            return 3
        } else {
            return 5
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Top3Cell", for: indexPath)
            cell.backgroundColor = .systemGray5
            return cell
        } else if collectionView == middleCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCell1", for: indexPath)
            cell.backgroundColor = .systemYellow
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCell2", for: indexPath)
            cell.backgroundColor = .systemPink
            return cell
        }
    }
}

extension HotChallViewController: UICollectionViewDelegateFlowLayout{
  
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
 
    playLocalVideo(named: "pokemon1.mp4")
    
  }
}
