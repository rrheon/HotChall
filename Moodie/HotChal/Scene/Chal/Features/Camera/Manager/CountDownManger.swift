//
//  CountDownManger.swift
//  HotChal
//
//  Created by heojiwoo on 8/4/25.
//
import UIKit
protocol CountdownManagerDelegate: AnyObject {
    func countdownDidStart()
    func countdownDidUpdate(remaining: Int)
    func countdownDidFinish()
}

final class CountdownManager {
    weak var delegate: CountdownManagerDelegate?

    private var timer: Timer?
    private var remaining = 0
    
    func start(seconds: Int) {
        remaining = seconds
        delegate?.countdownDidStart()
        delegate?.countdownDidUpdate(remaining: remaining)

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
    
            self.remaining -= 1
            
            if self.remaining > 0 {
                self.delegate?.countdownDidUpdate(remaining: self.remaining)
            } else {
                timer.invalidate()
                self.timer = nil
                self.delegate?.countdownDidFinish()
            }
        }
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        cancel()
    }
}
