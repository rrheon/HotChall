//
//  PlayerManager.swift
//  HotChal
//
//  Created by jonghyuck on 8/8/25.
//

import UIKit

final class PlayerManager: UIView {
    
    let progressSlider = UISlider()
    let volumeSlider = UISlider()
    let speedStackView = UIStackView()
    
    let titleLabel = UILabel()
    let uploaderLabel = UILabel()
    let timeLabel = UILabel()
    let volumeIcon = UIImageView()
    let pauseIconView = UIImageView()
    private let infoBackgroundView = UIVisualEffectView(effect: nil)
    
    let speeds: [Float] = [0.5, 1.0, 1.5, 2.0]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        // infoBackgroundView 세팅
        infoBackgroundView.layer.cornerRadius = 10
        infoBackgroundView.clipsToBounds = true
        infoBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        // 라벨 기본 세팅
        [titleLabel, uploaderLabel, timeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.shadowColor = .darkGray
            $0.shadowOffset = CGSize(width: 1, height: 1)
            $0.textColor = .white
        }
        
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        uploaderLabel.font = .systemFont(ofSize: 14, weight: .medium)
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 11.5, weight: .regular)
        timeLabel.textAlignment = .right
        
        // volumeIcon 세팅
        volumeIcon.image = UIImage(systemName: "speaker.fill")
        volumeIcon.tintColor = .appPink
        volumeIcon.contentMode = .scaleAspectFit
        volumeIcon.isUserInteractionEnabled = true
        volumeIcon.translatesAutoresizingMaskIntoConstraints = false
        
//        // pauseIconView 세팅
//        pauseIconView.image = UIImage(systemName: "pause.fill")
//        pauseIconView.tintColor = .white
//        pauseIconView.contentMode = .scaleAspectFit
//        pauseIconView.alpha = 0
//        pauseIconView.translatesAutoresizingMaskIntoConstraints = false
        
        // 슬라이더 기본 세팅
        [progressSlider, volumeSlider].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.minimumTrackTintColor = .appPink
            $0.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
            $0.thumbTintColor = .white
        }
        progressSlider.minimumTrackTintColor = .white
        progressSlider.thumbTintColor = .appPink
        volumeSlider.value = 1.0
        
        // speedStackView 세팅
        speedStackView.axis = .horizontal
        speedStackView.spacing = 8
        speedStackView.distribution = .fillEqually
        speedStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for speed in speeds {
            let button = UIButton(type: .system)
            button.setTitle("\(speed)x", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.tag = Int(speed * 10)
            speedStackView.addArrangedSubview(button)
        }
        
        // addSubviews
        addSubview(infoBackgroundView)
        infoBackgroundView.contentView.addSubview(titleLabel)
        infoBackgroundView.contentView.addSubview(uploaderLabel)
        
        addSubview(progressSlider)
        addSubview(timeLabel)
        addSubview(volumeIcon)
        addSubview(volumeSlider)
        addSubview(speedStackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let margin: CGFloat = 20
        let spacing: CGFloat = 8
        let sliderHeight: CGFloat = 30
        let speedStackHeight: CGFloat = 40
        
        NSLayoutConstraint.activate([
            //속도조절
            speedStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            speedStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            speedStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            speedStackView.heightAnchor.constraint(equalToConstant: speedStackHeight),
            
            // 재생바
            progressSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            progressSlider.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: 45),
            progressSlider.bottomAnchor.constraint(equalTo: speedStackView.topAnchor, constant: -spacing),
            progressSlider.heightAnchor.constraint(equalToConstant: sliderHeight),
            
            // 남은시간
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            timeLabel.centerYAnchor.constraint(equalTo: progressSlider.centerYAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 100),
            timeLabel.heightAnchor.constraint(equalToConstant: sliderHeight),
            
            // 볼륨
            volumeIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            volumeIcon.bottomAnchor.constraint(equalTo: progressSlider.topAnchor, constant: -spacing),
            volumeIcon.widthAnchor.constraint(equalToConstant: sliderHeight),
            volumeIcon.heightAnchor.constraint(equalToConstant: sliderHeight),
            
            volumeSlider.leadingAnchor.constraint(equalTo: volumeIcon.trailingAnchor, constant: 8),
            volumeSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            volumeSlider.centerYAnchor.constraint(equalTo: volumeIcon.centerYAnchor),
            volumeSlider.heightAnchor.constraint(equalToConstant: sliderHeight),
            
            // 제목 + 업로더 정보 배경(투명)
            infoBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            infoBackgroundView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -margin),
            infoBackgroundView.bottomAnchor.constraint(equalTo: volumeSlider.topAnchor, constant: -spacing),
            
            // 제목
            titleLabel.topAnchor.constraint(equalTo: infoBackgroundView.topAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: infoBackgroundView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: infoBackgroundView.trailingAnchor, constant: -12),
            
            // 업로더
            uploaderLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            uploaderLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            uploaderLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            uploaderLabel.bottomAnchor.constraint(equalTo: infoBackgroundView.bottomAnchor, constant: -6),
            
        ])
    }
}
