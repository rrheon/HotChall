import UIKit

// MARK: - Semantic Colors
public extension UIColor {
    struct App {
        public static let accentColor = UIColor(named: "AccentColor")
    }
}

// MARK: - Emotion Scale
public extension UIColor {
    static let blueEmotion = UIColor(named: "AppBlue")
    static let yellowEmotion = UIColor(named: "AppYellow")
    static let charcoalEmotion = UIColor(named: "AppCharcoal")
    static let creamEmotion = UIColor(named: "AppCream")
    static let grayEmotion = UIColor(named: "AppGray")
    static let mintEmotion = UIColor(named: "AppMint")
    static let orangeEmotion = UIColor(named: "AppOrange")
    static let pinkEmotion = UIColor(named: "AppPink")
    static let purpleEmotion = UIColor(named: "AppPurple")
}


public extension UIColor {
  static let backgroundColor = UIColor.init(hexCode: "#1E1E1E")
  
  convenience init(hexCode: String, alpha: CGFloat = 1.0) {
    var hexFormatted: String = hexCode.trimmingCharacters(
      in: CharacterSet.whitespacesAndNewlines
    ).uppercased()
    
    if hexFormatted.hasPrefix("#") {
      hexFormatted = String(hexFormatted.dropFirst())
    }
    
    assert(hexFormatted.count == 6, "Invalid hex code used.")
    
    var rgbValue: UInt64 = 0
    Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
    
    self.init(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: alpha
    )
  }
}
