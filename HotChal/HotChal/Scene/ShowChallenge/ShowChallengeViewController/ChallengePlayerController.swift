import UIKit
import AVFoundation

final class ChallengePlayerController {
  private let player = AVPlayer()
  private var playerLayer: AVPlayerLayer?
  
  
  /// 플레이어 레이어를 뷰에 올리고 초기 설정
  func setupPlayerLayer(to containerView: UIView) {
    let layer = AVPlayerLayer(player: player)
    layer.frame = containerView.bounds
    layer.videoGravity = .resizeAspectFill
    
    self.playerLayer = layer
    containerView.layer.addSublayer(layer)
    
    // bounds가 0이 아닌 경우 즉시 레이아웃 업데이트
    if containerView.bounds.width > 0 && containerView.bounds.height > 0 {
      layer.frame = containerView.bounds
    }
  }
  
  /// 컨테이너 크기 변경 시 레이아웃 업데이트
  func updatePlayerLayerFrame(in bounds: CGRect) {
    guard bounds.width > 0 && bounds.height > 0 else { return }
    playerLayer?.frame = bounds
  }
  
  
  /// 로컬에서 비디오 불러오기
  func loadLocalVideo(assetName: String) {
    guard let url = Bundle.main.url(forResource: assetName, withExtension: nil) else {
      print("❌ 로컬 비디오 파일을 찾을 수 없습니다: \(assetName)")
      return
    }
    let item = AVPlayerItem(url: url)
    player.replaceCurrentItem(with: item)
    
    // 비디오 로드 후 레이아웃이 설정되었는지 확인하고 필요시 업데이트
    DispatchQueue.main.async { [weak self] in
      if let layer = self?.playerLayer,
         layer.frame.width == 0 || layer.frame.height == 0,
         let superlayer = layer.superlayer {
        layer.frame = superlayer.bounds
      }
    }
  }
  
  func play() { player.play() }
  func pause() { player.pause() }
  
  
  /// 플레이어 일시정지 / 재생
  func togglePlayPause() {
    player.timeControlStatus == .playing ? pause() : play()
  }
  
  /// 시작지점으로 돌아가기
  func seekToStart() {
    player.seek(to: .zero)
  }
  
  // 플레이어가 재생중인지 여부 확인
  var isPlaying: Bool { player.timeControlStatus == .playing }
}

