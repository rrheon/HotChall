//  ChallCompareLoopedVideoPlayer.swift
//  HotChal
//
//  Created by 이지훈 on 8/6/25.

import UIKit
import AVFoundation

final class ChallCompareLoopedVideoPlayer {
    var queuePlayer: AVQueuePlayer?
    var looper: AVPlayerLooper?
    var playerLayer: AVPlayerLayer?
    var containerView: UIView
    var isMuted: Bool
    var isMain: Bool

    init(containerView: UIView, isMuted: Bool = true, isMain: Bool = false) {
        self.containerView = containerView
        self.isMuted = isMuted
        self.isMain = isMain
    }

    func setupVideo(named fileName: String, completion: ((CGFloat) -> Void)? = nil) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else { return }
        let url = URL(fileURLWithPath: path)
        setupVideo(url, completion: completion)
    }

    func setupVideo(_ url: URL, completion: ((CGFloat) -> Void)? = nil) {
        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: item)
        let looper = AVPlayerLooper(player: player, templateItem: item)
        let layer = AVPlayerLayer(player: player)

        layer.frame = containerView.bounds
        layer.videoGravity = isMain ? .resizeAspectFill : .resizeAspect

        containerView.layer.addSublayer(layer)

        self.queuePlayer = player
        self.looper = looper
        self.playerLayer = layer

        player.isMuted = isMuted
        player.play()

        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
            guard let track = asset.tracks(withMediaType: .video).first else { return }
            let size = track.naturalSize.applying(track.preferredTransform)
            let aspectRatio = abs(size.height / size.width)
            DispatchQueue.main.async {
                self.updateFrame()
                completion?(aspectRatio)
            }
        }
    }

    func updateFrame() {
        guard let layer = playerLayer else { return }
        DispatchQueue.main.async {
            layer.frame = self.containerView.bounds
            layer.videoGravity = self.isMain ? .resizeAspectFill : .resizeAspect
        }
    }

    func togglePlayPause() {
        guard let player = queuePlayer else { return }
        player.timeControlStatus == .playing ? player.pause() : player.play()
    }

    func setMuted(_ muted: Bool) {
        queuePlayer?.isMuted = muted
        isMuted = muted
    }
}
