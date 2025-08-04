
import UIKit


class Favaor2Controller: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
 
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.itemSize = UIScreen.main.bounds.size

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
      collectionView.register(ChallengeCell.self, forCellWithReuseIdentifier: ChallengeCell.reuseIdentifier)
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
//        playVisibleCell()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return MockupDataManager.shared.challengeVideos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: ChallengeCell.reuseIdentifier,
        for: indexPath) as? ChallengeCell else {
            return UICollectionViewCell()
        }
//        cell.configure(with: videos[indexPath.item])
        return cell
    }

//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
//        if let indexPath = collectionView.indexPathForItem(at: CGPoint(x: visibleRect.midX, y: visibleRect.midY)),
//           indexPath.item != currentIndex {
//            if let oldCell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? VideoCell {
//                oldCell.pause()
//            }
//            if let newCell = collectionView.cellForItem(at: indexPath) as? VideoCell {
//                newCell.play()
//            }
//            currentIndex = indexPath.item
//        }
//    }

//    private func playVisibleCell() {
//        let indexPath = IndexPath(item: currentIndex, section: 0)
//        if let cell = collectionView.cellForItem(at: indexPath) as? SavedChallengeCell {
//            cell.play()
//        }
//    }
}
