//
//  ToastPopupManager.swift
//  HotChal
//
//  Created by 최용헌 on 8/4/25.
//

import UIKit


/// ToastPopup 매니져
final class ToastPopupManager {
  static let shared = ToastPopupManager()
  
  private init() {}
  
  /// Toast Popup 띄우기
  /// - Parameters:
  ///   - message: Toast Popup 메세지(기본값 = 통신 실패 메세지)
  func showToast(message: String) {
    guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
    
    let toastContainer = UIView()
    toastContainer.backgroundColor = .appPink
    toastContainer.layer.cornerRadius = 10
    toastContainer.clipsToBounds = true
    toastContainer.translatesAutoresizingMaskIntoConstraints = false
    
    let toastLabel = UILabel()
    toastLabel.textColor = .black
    toastLabel.text = message
    toastLabel.numberOfLines = 0
    toastLabel.textAlignment = .center
    toastLabel.translatesAutoresizingMaskIntoConstraints = false
   
    toastContainer.addSubview(toastLabel)
    
    keyWindow.addSubview(toastContainer)
    
    NSLayoutConstraint.activate([
      toastContainer.bottomAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.bottomAnchor, constant: -50),
      toastContainer.leadingAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.leadingAnchor, constant: 10),
      toastContainer.trailingAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.trailingAnchor, constant: -10),
      toastContainer.heightAnchor.constraint(equalToConstant: 56),
      
      toastLabel.centerYAnchor.constraint(equalTo: toastContainer.centerYAnchor),
      toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 10),
      toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -10)
    ])
    
    UIView.animate(withDuration: 3.0, delay: 0.3, options: .curveEaseOut, animations: {
      toastContainer.alpha = 0.0
    }, completion: { _ in
      toastContainer.removeFromSuperview()
    })
  }
}
