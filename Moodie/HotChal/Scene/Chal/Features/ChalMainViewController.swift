import UIKit

// MARK: - Model
struct MoviePoster {
    let imageName: String
    let title: String
    let subtitle: String
}
struct ChallengeCategory {
    let id: Int
    let name: String
    let challenges: [Challenge]
}

struct Challenge {
    let id: Int
    let profileImageName: String
    let title: String
    let subtitle: String
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
    
    let dummyCategories: [ChallengeCategory] = [
        ChallengeCategory(
            id: 0,
            name: "소다팝 챌린지",
            challenges: [
                Challenge(id: 0, profileImageName: "Pokemon2", title: "눈물참기 (with. QWER)", subtitle: "주르르"),
                Challenge(id: 1, profileImageName: "Pokemon2", title: "숲속의 작은 레스토랑 🎄", subtitle: "징버거"),
                Challenge(id: 2, profileImageName: "Pokemon2", title: "안녕하세요 저는..", subtitle: "징버거")
            ]
        ),
        ChallengeCategory(
            id: 1,
            name: "홍박사 챌린지",
            challenges: [
                Challenge(id: 0, profileImageName: "Pokemon2", title: "눈물참기 (with. QWER)", subtitle: "주르르"),
                Challenge(id: 1, profileImageName: "Pokemon2", title: "숲속의 작은 레스토랑 🎄", subtitle: "징버거"),
                Challenge(id: 2, profileImageName: "Pokemon2", title: "안녕하세요 저는..", subtitle: "징버거")
            ]
        )
    ]
    
    private let posterHeaderView: UIView = {
        let container = UIView()

        let titleLabel = UILabel()
        titleLabel.text = "핫챌 TOP3 🔥"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let seeAllButton = UIButton(type: .system)
        seeAllButton.setTitle("전체보기 >", for: .normal)
        seeAllButton.setTitleColor(.black, for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        container.addSubview(titleLabel)
        container.addSubview(seeAllButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            seeAllButton.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }()

    private let collectionPosterView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout.posterPagingLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionPosterView.dataSource = self

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 32
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        contentStackView.addArrangedSubview(posterHeaderView)
        NSLayoutConstraint.activate([
            posterHeaderView.heightAnchor.constraint(equalToConstant: 30),
            posterHeaderView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor, constant: 16),
            posterHeaderView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: -16)
        ])

        collectionPosterView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(collectionPosterView)
        NSLayoutConstraint.activate([
            collectionPosterView.heightAnchor.constraint(equalToConstant: 250)
        ])

        for category in dummyCategories {
            let challengeSectionView = ChallengeSectionView()
            challengeSectionView.configure(title: category.name, challenges: category.challenges)
            contentStackView.addArrangedSubview(challengeSectionView)

            NSLayoutConstraint.activate([
                challengeSectionView.heightAnchor.constraint(equalToConstant: 220)
            ])
        }
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

// MARK: - UICollectionLayOut
extension UICollectionViewCompositionalLayout {
    static func posterPagingLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(250)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }
}


