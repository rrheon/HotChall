import UIKit
import AVFoundation

struct DanceVideo {
    let fileName: String
}

class VideoCell: UICollectionViewCell {
    static let identifier = "VideoCell"

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    override func prepareForReuse() {
        super.prepareForReuse()
        pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
    }

    func configure(with video: DanceVideo) {
        guard let path = Bundle.main.path(forResource: video.fileName, ofType: "mp4") else {
            return
        }

        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)

        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = contentView.bounds
        playerLayer?.videoGravity = .resizeAspectFill

        if let layer = playerLayer {
            contentView.layer.addSublayer(layer)
        }
    }

    func play() {
        player?.seek(to: .zero)
        player?.play()
    }

    func pause() {
        player?.pause()
    }
}

class Favaor2Controller: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    private let videos: [DanceVideo] = [
        .init(fileName: "sodaPop1"),
        .init(fileName: "golden1"),
        .init(fileName: "golden2")
    ]

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.itemSize = UIScreen.main.bounds.size

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.identifier)
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    private var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVisibleCell()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.identifier, for: indexPath) as? VideoCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: videos[indexPath.item])
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        if let indexPath = collectionView.indexPathForItem(at: CGPoint(x: visibleRect.midX, y: visibleRect.midY)),
           indexPath.item != currentIndex {
            if let oldCell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? VideoCell {
                oldCell.pause()
            }
            if let newCell = collectionView.cellForItem(at: indexPath) as? VideoCell {
                newCell.play()
            }
            currentIndex = indexPath.item
        }
    }

    private func playVisibleCell() {
        let indexPath = IndexPath(item: currentIndex, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? VideoCell {
            cell.play()
        }
    }
}
