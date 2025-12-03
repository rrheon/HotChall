//
//  TimerSelectView.swift
//  HotChal
//
//  Created by heojiwoo on 8/4/25.
//
import UIKit

final class TimerSelectView: UIView {

    private let timerOptions: [(label: String, value: Int)] = [
        ("3초", 3),
        ("10초", 10),
        ("20초", 20)
    ]
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: timerOptions.map { $0.label })
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .white
        control.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.black, .font: UIFont.boldSystemFont(ofSize: 15)], for: .selected)
        return control
    }()

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("시작", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .appPink
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }()

    var onStart: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        let mainStack = UIStackView(arrangedSubviews: [segmentedControl, spacer, startButton])
        mainStack.axis = .vertical
        
    
        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        spacer.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            segmentedControl.heightAnchor.constraint(equalToConstant: 48),
            startButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
    }

    @objc private func startButtonPressed() {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        let selectedValue = timerOptions[selectedIndex].value
        onStart?(selectedValue)
    }
}
