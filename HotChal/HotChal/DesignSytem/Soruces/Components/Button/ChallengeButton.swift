//
//  ChallengeButton.swift
//  HotChal
//
//  Created by 최용헌 on 8/10/25.
//

import UIKit


/// 챌린지 버튼의 유형
enum ChallengeButtonType {
    case learnChallenge
    case takeChallenge
    case showChallenge
    case saveChallenge
    case repeatChallenge
    
    var title: String {
        switch self {
        case .learnChallenge:   "배우기"
        case .saveChallenge:    "즐겨찾기"
        case .takeChallenge:    "찍어보기"
        case .repeatChallenge:  "반복설정"
        case .showChallenge:    "보기"
        }
    }
    
    var imageName: String {
        switch self {
        case .learnChallenge:   "figure.dance"
        case .saveChallenge:    "star"
        case .takeChallenge:    "camera.shutter.button"
        case .repeatChallenge:  "repeat"
        case .showChallenge:    "play.rectangle"
        }
    }
}

final class ChallengeButton: UIButton {
    init(type: ChallengeButtonType, buttonColor: UIColor = .appPink) {
    super.init(frame: .zero)
        
    var config = UIButton.Configuration.plain()
    config.image = UIImage(systemName: type.imageName)
    config.imagePadding = 10
    config.baseForegroundColor = buttonColor
    
    let imageSize = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
    config.preferredSymbolConfigurationForImage = imageSize
    
    let font = UIFont.boldSystemFont(ofSize: 14)
    let attributes: [NSAttributedString.Key: Any] = [ .font: font ]
        config.attributedTitle = AttributedString(NSAttributedString(string: type.title, attributes: attributes))
    
    self.configuration = config
    self.semanticContentAttribute = .forceRightToLeft
    self.configuration?.imagePlacement = .top
    self.configuration?.imagePadding = 10
    self.tintColor = .white
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}
