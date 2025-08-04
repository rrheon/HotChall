//
//  ChallengeCell.swift
//  HotChal
//
//  Created by jonghyuck on 7/30/25.
//

import UIKit

class LearnChallengeCell: UICollectionViewCell {
    static let identifier = "ChallengeCell"

    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let uploaderLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .darkGray
        contentView.layer.cornerRadius = 13
        contentView.clipsToBounds = true

        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true

        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        titleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.2)

        uploaderLabel.font = UIFont.systemFont(ofSize: 10)
        uploaderLabel.textColor = .white

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(uploaderLabel)

        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        uploaderLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -4),

            uploaderLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 4),
            uploaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            uploaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            uploaderLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

  func configure(with item: ChallengeVideo) {
    thumbnailImageView.image = UIImage(named: "item.thumbnailImage")
        titleLabel.text = item.title
        uploaderLabel.text = item.uploader
    }
}

//#Preview {
//    LearnViewController()
//}
