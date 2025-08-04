//
//  PopupViewController.swift
//  HotChal
//
//  Created by 최용헌 on 7/31/25.
//

import UIKit

/// 팝업 VC
final class PopupViewController: UIViewController {
  
  private let popupView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 7
    view.clipsToBounds = true
    view.backgroundColor = .systemBackground
    
    return view
  }()
  
  // 팝업의 내용 라벨
  private let deletePopupLabel: UILabel = {
    let label = UILabel()
    label.text = "챌린지를 삭제할까요?"
    
    return label
  }()
  
  // 삭제 취소버튼
  private let cancelButton: UIButton = {
    let button = UIButton(configuration: UIButton.Configuration.filled())
    button.setTitle("취소", for: .normal)
    button.setTitleColor(.appCream, for: .normal)
    return button
  }()

  // 삭제 버튼
  private let deleteButton: UIButton = {
    let button = UIButton(configuration: UIButton.Configuration.filled())
    button.setTitle("삭제", for: .normal)
    button.setTitleColor(.appPink, for: .normal)
    return button
  }()

  override func viewDidLoad() {
    view.backgroundColor = .lightGray.withAlphaComponent(0.8)
    
    self.setupConstraints()
    
    cancelButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
    deleteButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)

  }// viewDidLoad
  
  /// UI 설정
  private func setupConstraints() {
    let buttonStackView = UIStackView(arrangedSubviews: [cancelButton, deleteButton])
    buttonStackView.axis = .horizontal
    buttonStackView.distribution = .fillEqually
    buttonStackView.alignment = .fill
    buttonStackView.spacing = 20
    
    
    view.addSubview(popupView)
    popupView.translatesAutoresizingMaskIntoConstraints = false
    
    [deletePopupLabel, buttonStackView]
      .forEach {
        popupView.addSubview($0)
        $0.translatesAutoresizingMaskIntoConstraints = false
      }
    
    
    NSLayoutConstraint.activate([
      popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      popupView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
      popupView.heightAnchor.constraint(equalToConstant: 180),

      deletePopupLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20),
      deletePopupLabel.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),

      buttonStackView.topAnchor.constraint(equalTo: deletePopupLabel.bottomAnchor, constant: 20),
      buttonStackView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
      buttonStackView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),
      buttonStackView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -20),
    ])


  }
  
  @objc func dismissPopup(){
    self.dismiss(animated: true)
  }
}
