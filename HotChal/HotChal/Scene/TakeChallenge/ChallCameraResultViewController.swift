import UIKit
import AVFoundation

protocol ChallCameraResultViewDelegate: AnyObject {
    func cameraResultViewClose(_ view: ChallCameraResultView)
    func cameraResultViewSave(_ view: ChallCameraResultView, didTapSaveWith videoURL: URL)
}

final class ChallCameraResultView: UIView {
    private let videoURL: URL
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var isPlaying = true
    
    weak var delegate: ChallCameraResultViewDelegate?
    
    // MARK: - UI
    private let bottomStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints  = false
        return stack
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다시 찍기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장하기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor.appPink
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let timelineSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.isEnabled = false // 처음엔 비활성화
        slider.tintColor = .appPink
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    // MARK: - Init
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(frame: .zero)
        setupPlayer()
        setupUI()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }

    // MARK: - Video
    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        if let layer = playerLayer {
            self.layer.addSublayer(layer)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(replay),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )

        addPlayerObservers()
        player?.play()
    }
    
    private func addPlayerObservers() {
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { [weak self] currentTime in
            guard let self = self else { return }
            let duration = self.player?.currentItem?.duration.seconds ?? 0
            guard duration.isFinite, duration > 0 else { return }
            self.timelineSlider.value = Float(currentTime.seconds / duration)
            self.timelineSlider.isEnabled = true
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        addSubview(bottomStackView)
        addSubview(playPauseButton)
        addSubview(timelineSlider)
        bottomStackView.addArrangedSubview(closeButton)
        bottomStackView.addArrangedSubview(saveButton)
        
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPausePressed), for: .touchUpInside)
        
        // 슬라이더 이벤트
        timelineSlider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        timelineSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        timelineSlider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside])
        
        NSLayoutConstraint.activate([
            timelineSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            timelineSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            timelineSlider.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -12),
            
            bottomStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            bottomStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            bottomStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomStackView.heightAnchor.constraint(equalToConstant: 44),
            
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 50),
            playPauseButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(playPausePressed))
        self.addGestureRecognizer(tap)
    }

    // MARK: - Actions
    @objc private func closePressed() {
        delegate?.cameraResultViewClose(self)
    }

    @objc private func savePressed() {
        delegate?.cameraResultViewSave(self, didTapSaveWith: videoURL)
    }
    
    @objc private func playPausePressed() {
        isPlaying.toggle()
        isPlaying ? player?.play() : player?.pause()
        
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: iconName), for: .normal)
        playPauseButton.isHidden = false
        
        if isPlaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                guard let self = self, self.isPlaying else { return }
                self.playPauseButton.isHidden = true
            }
        }
    }
    
    @objc private func sliderTouchDown(_ sender: UISlider) {
        player?.pause()
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        let duration = player?.currentItem?.duration.seconds ?? 0
        guard duration.isFinite, duration > 0 else { return }
        
        let targetTime = Double(sender.value) * duration
        // 프레임 나누기
        let cmTime = CMTime(seconds: targetTime, preferredTimescale: 600)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    @objc private func sliderTouchUp(_ sender: UISlider) {
        if isPlaying {
            player?.play()
        }
    }

    @objc private func replay() {
        player?.seek(to: .zero)
        timelineSlider.value = 0
        player?.play()
    }

    deinit {
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        NotificationCenter.default.removeObserver(self)
    }
}
