//
//  ChallComparSubView.swift
//  HotChal
//
//  Created by 이지훈 on 8/5/25.
//

import UIKit

final class ChallComparSubView: UIView {

    var videoPlayer: ChallCompareLoopedVideoPlayer

    override init(frame: CGRect) {
        self.videoPlayer = ChallCompareLoopedVideoPlayer(containerView: UIView(), isMuted: true, isMain: false)
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.videoPlayer = ChallCompareLoopedVideoPlayer(containerView: UIView(), isMuted: true, isMain: false)
        super.init(coder: coder)
        setupView()
    }

    func setupVideo(named name: String, completion: ((CGFloat) -> Void)? = nil) {
        videoPlayer.containerView = self
        videoPlayer.setupVideo(named: name, completion: completion)
        DispatchQueue.main.async {
            self.videoPlayer.updateFrame()
        }
    }

    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 15
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = self.superview else { return }
        let translation = gesture.translation(in: superview)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gesture.setTranslation(.zero, in: superview)

        if gesture.state == .ended {
            snapToCorner()
        }
    }

    private func snapToCorner() {
        guard let superview = self.superview else { return }
        let safeFrame = superview.safeAreaLayoutGuide.layoutFrame
        let size = frame.size

        let corners: [CGPoint] = [
            CGPoint(x: safeFrame.minX + 10, y: safeFrame.minY),
            CGPoint(x: safeFrame.maxX - size.width - 10, y: safeFrame.minY),
            CGPoint(x: safeFrame.minX + 10, y: safeFrame.maxY - size.height - 50),
            CGPoint(x: safeFrame.maxX - size.width - 10, y: safeFrame.maxY - size.height - 50)
        ]

        let origin = frame.origin
        let nearest = corners.min { distance($0, origin) < distance($1, origin) } ?? corners[0]

        UIView.animate(withDuration: 0.25) {
            self.frame.origin = nearest
        }
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        return hypot(a.x - b.x, a.y - b.y)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPlayer.updateFrame()
    }
}
