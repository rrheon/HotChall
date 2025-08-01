import UIKit
import AVFoundation
import MediaPlayer

class PlayerViewController: UIViewController {
    
    var videoFilename: String?
    var videoTitle: String?
    var uploader: String?
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var timeObserverToken: Any?
    
    private var isPlaying = true {
        didSet {
            if isPlaying {
                player.playImmediately(atRate: selectedSpeed)
            } else {
                player.pause()
            }
        }
    }
    
    private let speeds: [Float] = [0.5, 1.0, 1.5, 2.0]
    private var selectedSpeed: Float = 1.0 {
        didSet {
            if isPlaying {
                player.playImmediately(atRate: selectedSpeed)
            }
            updateSpeedButtons()
        }
    }
    
    // 음소거 상태 및 이전 볼륨 저장
    private var isMuted = false
    private var previousVolume: Float = 1.0
    
    private let infoBackgroundView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blur)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private let uploaderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .right
        label.text = "00:00 / 00:00"
        return label
    }()
    
    private let volumeIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "speaker.fill"))
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let progressSlider = UISlider()
    private let volumeSlider = UISlider()
    private let speedStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupPlayer()
        setupUI()
        setupGestureRecognizers()
        setupVolumeIconTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 영상이 화면 하단 안전 영역까지 꽉 차도록 frame 조정
        if let window = view.window {
            // 전체 화면 프레임 (safeAreaInsets 포함)
            let safeFrame = CGRect(
                x: 0,
                y: 0,
                width: window.bounds.width,
                height: window.bounds.height
            )
            playerLayer.frame = safeFrame
        } else {
            playerLayer.frame = view.bounds
        }
        
        let margin: CGFloat = 20
        let spacing: CGFloat = 8
        let sliderHeight: CGFloat = 30
        let maxWidth = view.bounds.width - margin * 2
        
        // 타이틀, 업로더 텍스트 크기 측정
        let titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth - 24, height: CGFloat.greatestFiniteMagnitude))
        let uploaderSize = uploaderLabel.sizeThatFits(CGSize(width: maxWidth - 24, height: CGFloat.greatestFiniteMagnitude))
        let infoHeight = titleSize.height + uploaderSize.height + spacing
        
        // 속도 조절 탭 높이
        let speedStackHeight: CGFloat = 40
        
        // 속도 조절 탭 : 화면 가장 아래쪽 margin 20 유지
        speedStackView.frame = CGRect(
            x: margin,
            y: view.bounds.height - speedStackHeight - margin,
            width: maxWidth,
            height: speedStackHeight
        )
        
        // 재생바 : 속도조절 탭 바로 위 (spacing 포함)
        progressSlider.frame = CGRect(
            x: margin,
            y: speedStackView.frame.minY - sliderHeight - spacing,
            width: maxWidth,
            height: sliderHeight
        )
        
        // 볼륨 아이콘과 슬라이더 : 재생바 위쪽 (spacing 포함)
        let volumeIconSize: CGFloat = sliderHeight
        volumeIcon.frame = CGRect(
            x: margin,
            y: progressSlider.frame.minY - sliderHeight - spacing,
            width: volumeIconSize,
            height: volumeIconSize
        )
        volumeSlider.frame = CGRect(
            x: volumeIcon.frame.maxX + 8,
            y: volumeIcon.frame.minY,
            width: maxWidth - volumeIcon.frame.width - 8,
            height: sliderHeight
        )
        
        // 타이틀+업로더 백그라운드 : 볼륨 슬라이더 위, 텍스트 크기에 딱 맞게 맞춤
        infoBackgroundView.frame = CGRect(
            x: margin,
            y: volumeSlider.frame.minY - infoHeight - spacing,
            width: maxWidth,
            height: infoHeight
        )
        titleLabel.frame = CGRect(x: 12, y: 6, width: maxWidth - 24, height: titleSize.height)
        uploaderLabel.frame = CGRect(x: 12, y: titleLabel.frame.maxY + 2, width: maxWidth - 24, height: uploaderSize.height)
        
        // 재생시간 라벨 (재생바 오른쪽 끝 바로 위)
        timeLabel.frame = CGRect(
            x: view.bounds.width - margin - 100,
            y: progressSlider.frame.minY - 20,
            width: 100,
            height: 20
        )
    }
    
    private func setupPlayer() {
        guard let filename = videoFilename,
              let path = Bundle.main.path(forResource: filename.replacingOccurrences(of: ".mp4", with: ""), ofType: "mp4") else {
            print("❌ 영상 파일을 찾을 수 없습니다: \(videoFilename ?? "nil")")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        player.volume = 1.0
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = view.bounds
        view.layer.insertSublayer(playerLayer, at: 0)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            
            let durationSeconds = self.player.currentItem?.duration.seconds ?? 1
            if durationSeconds.isFinite && durationSeconds > 0 {
                let currentSeconds = time.seconds
                self.progressSlider.value = Float(currentSeconds / durationSeconds)
                self.updateTimeLabel(currentTime: currentSeconds, duration: durationSeconds)
            }
        }
        
        player.playImmediately(atRate: selectedSpeed)
        
        titleLabel.text = videoTitle ?? "제목 없음"
        uploaderLabel.text = uploader ?? "알 수 없음"
    }
    
    private func setupUI() {
        view.addSubview(infoBackgroundView)
        infoBackgroundView.contentView.addSubview(titleLabel)
        infoBackgroundView.contentView.addSubview(uploaderLabel)
        
        view.addSubview(timeLabel)
        view.addSubview(progressSlider)
        view.addSubview(volumeIcon)
        view.addSubview(volumeSlider)
        
        speedStackView.axis = .horizontal
        speedStackView.spacing = 8
        speedStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for speed in speeds {
            let button = UIButton(type: .system)
            button.setTitle("\(speed)x", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = .systemFont(ofSize: 12)
            button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
            button.tag = Int(speed * 10)
            button.addTarget(self, action: #selector(speedSelected(_:)), for: .touchUpInside)
            speedStackView.addArrangedSubview(button)
        }
        view.addSubview(speedStackView)
        
        progressSlider.minimumTrackTintColor = .systemGreen
        progressSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        progressSlider.thumbTintColor = .white
        progressSlider.addTarget(self, action: #selector(progressSliderChanged), for: .valueChanged)
        
        volumeSlider.minimumTrackTintColor = .systemGreen
        volumeSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        volumeSlider.thumbTintColor = .white
        volumeSlider.value = player?.volume ?? 1.0
        volumeSlider.addTarget(self, action: #selector(volumeSliderChanged), for: .valueChanged)
        
        // 초기 속도 1.0x 선택
        selectedSpeed = 1.0
        updateSpeedButtons()
    }
    
    private func setupGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePlayPause))
        view.addGestureRecognizer(tap)
    }
    
    private func setupVolumeIconTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(volumeIconTapped))
        volumeIcon.addGestureRecognizer(tapGesture)
    }
    
    @objc private func volumeIconTapped() {
        if isMuted {
            // 음소거 해제, 이전 볼륨 복원
            isMuted = false
            player.volume = previousVolume
            volumeSlider.value = previousVolume
            volumeIcon.image = UIImage(systemName: "speaker.fill")
        } else {
            // 음소거, 현재 볼륨 저장 후 0으로 설정
            isMuted = true
            previousVolume = player.volume
            player.volume = 0
            volumeSlider.value = 0
            volumeIcon.image = UIImage(systemName: "speaker.slash.fill")
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        player.seek(to: .zero)
        isPlaying = false
    }
    
    @objc private func progressSliderChanged() {
        guard let duration = player.currentItem?.duration.seconds, duration > 0 else { return }
        let value = Double(progressSlider.value) * duration
        player.seek(to: CMTime(seconds: value, preferredTimescale: 600))
    }
    
    @objc private func volumeSliderChanged() {
        player.volume = volumeSlider.value
        if volumeSlider.value == 0 {
            isMuted = true
            volumeIcon.image = UIImage(systemName: "speaker.slash.fill")
        } else {
            isMuted = false
            volumeIcon.image = UIImage(systemName: "speaker.fill")
            previousVolume = volumeSlider.value
        }
    }
    
    private func updateSpeedButtons() {
        for case let button as UIButton in speedStackView.arrangedSubviews {
            let speed = Float(button.tag) / 10.0
            button.backgroundColor = (speed == selectedSpeed) ? .systemGreen : UIColor.white.withAlphaComponent(0.2)
        }
    }
    
    @objc private func speedSelected(_ sender: UIButton) {
        selectedSpeed = Float(sender.tag) / 10.0
    }
    
    private func updateTimeLabel(currentTime: Double, duration: Double) {
        func formatTime(_ seconds: Double) -> String {
            let totalSeconds = Int(seconds)
            let mins = totalSeconds / 60
            let secs = totalSeconds % 60
            return String(format: "%02d:%02d", mins, secs)
        }
        timeLabel.text = "\(formatTime(currentTime)) / \(formatTime(duration))"
    }
    
    @objc private func togglePlayPause() {
        if player.timeControlStatus == .paused && player.currentTime() >= player.currentItem!.duration {
            player.seek(to: .zero)
        }
        isPlaying.toggle()
    }
    
    deinit {
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
        }
        NotificationCenter.default.removeObserver(self)
    }
}
