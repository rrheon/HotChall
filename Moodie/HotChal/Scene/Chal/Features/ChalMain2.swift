//
//  ChalMain2.swift
//  HotChal
//
//  Created by heojiwoo on 7/30/25.
//

import UIKit

protocol ChalMain2Delegate {
    func next2()
}

class ChalMain2: UIViewController {

    var delegate: ChalCoordinator?
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("next22222", for: .normal)
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
        print("3131313")
        self.delegate?.next2()
    }
}
