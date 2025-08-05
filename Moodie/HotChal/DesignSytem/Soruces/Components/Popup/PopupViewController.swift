//
//  PopupViewController.swift
//  HotChal
//
//  Created by 최용헌 on 7/31/25.
//

import UIKit


/// 저장된 챌린지 삭제
protocol SavedChallengeDelegate: AnyObject {
  func didTapDeleteButton()
}

/// 팝업 VC
final class PopupViewController: UIViewController {
  weak var delegate: SavedChallengeDelegate?
  
  private let popupView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 7
    view.clipsToBounds = true
    view.backgroundColor = .backgroundColor
    
    return view
  }()
  
  // 팝업의 내용 라벨
  private let deletePopupLabel: UILabel = {
    let label = UILabel()
    label.text = "챌린지를 삭제할까요?"
    label.textColor = .white
    
    return label
  }()
  
  // 삭제 취소버튼
  private let cancelButton: UIButton = {
    let button = UIButton(configuration: UIButton.Configuration.filled())
    button.setTitle("취소", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.tintColor = .lightGray

    return button
  }()

  // 삭제 버튼
  private let deleteButton: UIButton = {
    let button = UIButton(configuration: UIButton.Configuration.filled())
    button.setTitle("삭제", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.tintColor = .appPink

    return button
  }()

  override func viewDidLoad() {
    view.backgroundColor = UIColor.black.withAlphaComponent(0.8)

    self.setupConstraints()
    
    cancelButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
    deleteButton.addAction(UIAction { _ in
      self.delegate?.didTapDeleteButton()
      self.dismiss(animated: true)

    }, for: .touchUpInside)

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
