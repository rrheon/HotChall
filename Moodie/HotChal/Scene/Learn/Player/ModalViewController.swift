//
//  TextModalViewController.swift
//  HotChal
//
//  Created by jonghyuck on 8/7/25.
//

import UIKit

protocol ModalViewControllerProtocol {
    func willDismissModalView(_ viewController: ModalViewController, startTime: Double?, endTime: Double?)
}


class ModalViewController: UIViewController {
    var delegate: ModalViewControllerProtocol? = nil

    private let startTimeField = UITextField()
    private let endTimeField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        startTimeField.placeholder = "start time(s)"
        endTimeField.placeholder = "end time(s)"
        
        // 제목 라벨
        let titleLabel = UILabel()
        titleLabel.text = "Loop Setting"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // 안내 문구 라벨
        let infoLabel = UILabel()
        infoLabel.text = "⚠️ 입력하지 않으면 루프가 초기화됩니다"
        infoLabel.font = UIFont.systemFont(ofSize: 10)
        infoLabel.textColor = .gray
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)

        // 텍스트필드 StackView (기존 방식 유지)
        let timeInputStackView = UIStackView(arrangedSubviews: [startTimeField, endTimeField])
        timeInputStackView.axis = .horizontal
        timeInputStackView.spacing = 12
        timeInputStackView.distribution = .fillEqually
        timeInputStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeInputStackView)

        [startTimeField, endTimeField].forEach {
            $0.borderStyle = .roundedRect
            $0.keyboardType = .decimalPad
            $0.backgroundColor = .white
            $0.textAlignment = .center
        }
        
        view.addSubview(timeInputStackView)
        
        let closeButton = UIButton(type: .system)
            closeButton.setTitle("Complete Setting", for: .normal)
            closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(closeButton)
            
        NSLayoutConstraint.activate([
            // 제목
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
            //  텍스트 필드 스택
            timeInputStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            timeInputStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeInputStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timeInputStackView.heightAnchor.constraint(equalToConstant: 44),
            
            // 안내문
            infoLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 5),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
            // 설정완료 버튼
            closeButton.topAnchor.constraint(equalTo: timeInputStackView.bottomAnchor, constant: 10),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let sheet = self.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in return 170 }] // 또는 .fractional(0.33)
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true  // 위에 바 표시
            sheet.preferredCornerRadius = 20
        }
    }
    
    @objc func close() {
        let start = Double(startTimeField.text ?? "")
        let end = Double(endTimeField.text ?? "")
        // 아무 값도 없으면 둘 다 nil로 전달
        if start == nil && end == nil {
            delegate?.willDismissModalView(self, startTime: nil, endTime: nil)
        } else {
            delegate?.willDismissModalView(self, startTime: start, endTime: end)
        }
        self.dismiss(animated: true)
    }
}
    
@available(iOS 17.0, *)
#Preview {
    UINavigationController(rootViewController: PlayerViewController())
}
