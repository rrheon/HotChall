//
//  HomeController.swift
//  HotChal
//
//  Created by heojiwoo on 7/29/25.
//
import UIKit

class HomeViewController: UIViewController {

    var didSendEventClosure: ((HomeViewController.Event) -> Void)?

    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("home", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.0

        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(nextButton)

        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 200),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        nextButton.addTarget(self, action: #selector(didTapGoButton(_:)), for: .touchUpInside)
    }
    
    deinit {
        print("GoViewController deinit")
    }
    
    @objc private func didTapGoButton(_ sender: Any) {
        didSendEventClosure?(.homeTwo)
    }
}

extension HomeViewController {
    enum Event {
        case homeTwo
    }
}
