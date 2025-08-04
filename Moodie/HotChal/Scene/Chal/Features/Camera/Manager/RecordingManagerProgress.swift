//
//  RecordingProgress.swift
//  HotChal
//
//  Created by heojiwoo on 8/4/25.
//

import UIKit

protocol RecordingProgressManagerDelegate: AnyObject {
    func progressDidUpdate(_ progress: Float)
    func progressDidFinish()
}


final class RecordingProgressManager {
    weak var delegate: RecordingProgressManagerDelegate?

    private var displayLink: CADisplayLink?
    private var startTime: Date?
    private let maxDuration: TimeInterval

    init(maxDuration: TimeInterval) {
        self.maxDuration = maxDuration
    }

    func start() {
        startTime = Date()
        displayLink?.invalidate()

        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }

    func pause() {
        displayLink?.isPaused = true
    }

    func resume() {
        displayLink?.isPaused = false
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        startTime = nil
    }

    @objc private func update() {
        guard let start = startTime else { return }

        let elapsed = Date().timeIntervalSince(start)
        let progress = Float(elapsed / maxDuration)
        delegate?.progressDidUpdate(min(progress, 1.0))

        if elapsed >= maxDuration {
            stop()
            delegate?.progressDidFinish()
        }
    }
}

