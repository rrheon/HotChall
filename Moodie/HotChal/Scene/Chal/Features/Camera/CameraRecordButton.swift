//
//  CameraRecordButton.swift
//  HotChal
//
//  Created by heojiwoo on 8/4/25.
//

import UIKit

// MARK: - 커스텀 녹화 버튼
final class RecordButton: UIControl {

    private let outerCircleLayer = CAShapeLayer()
    private let innerShapeView = UIView()

    private var isRecording: Bool = false {
        didSet { animateInnerShape(animated: true) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 버튼 크기에 맞춰서 레이아웃
    override func layoutSubviews() {
        super.layoutSubviews()

        outerCircleLayer.frame = bounds
        // 원 생성
        outerCircleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        applyInnerShapeLayout(animated: false)
    }

    func toggleRecording() {
        isRecording.toggle()
    }

    private func setupLayers() {
        outerCircleLayer.strokeColor = UIColor.white.cgColor
        outerCircleLayer.fillColor = UIColor.clear.cgColor
        outerCircleLayer.lineWidth = 4
        layer.addSublayer(outerCircleLayer)

        innerShapeView.backgroundColor = .red
        innerShapeView.isUserInteractionEnabled = false
        addSubview(innerShapeView)
    }

    private func animateInnerShape(animated: Bool) {
        applyInnerShapeLayout(animated: animated)
    }

    private func applyInnerShapeLayout(animated: Bool) {
        let targetFrame: CGRect
        let targetCornerRadius: CGFloat

        // 원형, 정사각형
        if isRecording {
            let side = bounds.width * 0.5
            targetFrame = CGRect(
                x: (bounds.width - side) / 2,
                y: (bounds.height - side) / 2,
                width: side,
                height: side
            )
            targetCornerRadius = 4
        } else {
            let diameter = bounds.width * 0.85
            targetFrame = CGRect(
                x: (bounds.width - diameter) / 2,
                y: (bounds.height - diameter) / 2,
                width: diameter,
                height: diameter
            )
            targetCornerRadius = diameter / 2
        }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
                self.innerShapeView.frame = targetFrame
                self.innerShapeView.layer.cornerRadius = targetCornerRadius
            }, completion: nil)
        } else {
            self.innerShapeView.frame = targetFrame
            self.innerShapeView.layer.cornerRadius = targetCornerRadius
        }
    }
}


