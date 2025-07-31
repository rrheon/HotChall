import UIKit

final class ChallengeSectionView: UIView {
    
    private let titleLabel = UILabel()
    private let collectionView: UICollectionView
    
    private var challenges: [Challenge] = []
    
    override init(frame: CGRect) {
        // 레이아웃 설정
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 160)
        layout.minimumLineSpacing = 16
        layout.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        
        titleLabel.font = .boldSystemFont(ofSize: 18)
        collectionView.register(ChallengeCell.self, forCellWithReuseIdentifier: "ChallengeCell")
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, collectionView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    func configure(title: String, challenges: [Challenge]) {
        self.titleLabel.text = title
        self.challenges = challenges
        collectionView.reloadData()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

extension ChallengeSectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        challenges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let challenge = challenges[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChallengeCell", for: indexPath) as! ChallengeCell
        cell.configure(with: challenge)
        return cell
    }
}
