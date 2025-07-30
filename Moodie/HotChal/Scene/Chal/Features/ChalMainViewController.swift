import UIKit

// MARK: - Model
struct MoviePoster {
    let imageName: String
    let title: String
    let subtitle: String
}

// MARK: - Custom Cell
final class PosterCell: UICollectionViewCell {
    static let reuseIdentifier = "PosterCell"

    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 8
        contentView.clipsToBounds = false

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true

        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with poster: MoviePoster) {
        imageView.image = UIImage(named: poster.imageName)
    }
}


protocol ChalMainViewControllerDelegate {
    func next()
}

// MARK: - View Controller
final class ChalMainViewController: UIViewController {
    
    var delegate: ChalCoordinator?
    
    private var posters: [MoviePoster] = [
        .init(imageName: "SodaPop1", title: "좀비딸", subtitle: "2025.07.30"),
        .init(imageName: "SodaPop2", title: "영화1", subtitle: "2025.08.01"),
        .init(imageName: "SodaPop3", title: "영화2", subtitle: "2025.08.15")
    ]

    private var collectionView: UICollectionView!

    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("home", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.0
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupCollectionView()
        setupNextButton()
    }

    deinit {
        print("ChalMainViewController deinit")
    }

    // MARK: - Setup CollectionView
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 360)
        ])
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.82), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(250), heightDimension: .absolute(250))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Setup Next Button
    private func setupNextButton() {
        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 24),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 200),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        nextButton.addTarget(self, action: #selector(didTapGoButton(_:)), for: .touchUpInside)
    }

    @objc private func didTapGoButton(_ sender: Any) {
        self.delegate?.next()
    }
}

// MARK: - UICollectionViewDataSource
extension ChalMainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let poster = posters[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCell.reuseIdentifier, for: indexPath) as? PosterCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: poster)
        return cell
    }
}

//#Preview {
//    ChalMainViewController()
//}
