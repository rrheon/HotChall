//
//  ChallengeButton.swift
//  HotChal
//
//  Created by 최용헌 on 8/10/25.
//

import UIKit

final class ChallengeButton: UIButton {
  init(title: String, imageName: String, buttonColor: UIColor = .appPink) {
    super.init(frame: .zero)
    var config = UIButton.Configuration.plain()
    config.image = UIImage(systemName: imageName)
    config.imagePadding = 10
    config.baseForegroundColor = buttonColor
    
    let imageSize = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
    config.preferredSymbolConfigurationForImage = imageSize
    
    let font = UIFont.boldSystemFont(ofSize: 14)
    let attributes: [NSAttributedString.Key: Any] = [ .font: font ]
    config.attributedTitle = AttributedString(NSAttributedString(string: title, attributes: attributes))
    
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
