import UIKit

enum RecordState {
    case ready
    case recording
    case countdown
}

protocol RecordButtonDelegate: AnyObject {
    func recordButtonDidTapStart(_ button: RecordButton)
    func recordButtonDidTapStop(_ button: RecordButton)
    func recordButtonDidTapCancelDuringCountdown(_ button: RecordButton)
}

final class RecordButton: UIControl {

    private let outerCircleLayer = CAShapeLayer()
    private let innerShapeView = UIView()
    private let countdownIcon = UIImageView(image: UIImage(systemName: "xmark"))

    weak var delegate: RecordButtonDelegate?

    var recordState: RecordState = .ready {
        didSet { updateAppearance(animated: true) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        outerCircleLayer.frame = bounds
        outerCircleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        updateAppearance(animated: true)
    }

    func setState(_ newState: RecordState) {
        self.recordState = newState
    }

    private func setupLayers() {
        outerCircleLayer.strokeColor = UIColor.white.cgColor
        outerCircleLayer.fillColor = UIColor.clear.cgColor
        outerCircleLayer.lineWidth = 4
        layer.addSublayer(outerCircleLayer)

        innerShapeView.backgroundColor = .red
        innerShapeView.isUserInteractionEnabled = false
        addSubview(innerShapeView)

        countdownIcon.tintColor = .black
        countdownIcon.contentMode = .scaleAspectFit
        countdownIcon.isHidden = true
        addSubview(countdownIcon)
    }

    private func updateAppearance(animated: Bool) {
        let targetFrame: CGRect
        let targetCornerRadius: CGFloat
        
        switch recordState {
        case .ready:
            countdownIcon.isHidden = true
            let diameter = bounds.width * 0.85
            targetFrame = CGRect(
                x: (bounds.width - diameter) / 2,
                y: (bounds.height - diameter) / 2,
                width: diameter,
                height: diameter
            )
            targetCornerRadius = diameter / 2
            innerShapeView.backgroundColor = .red

        case .recording:
            countdownIcon.isHidden = true
            let side = bounds.width * 0.5
            targetFrame = CGRect(
                x: (bounds.width - side) / 2,
                y: (bounds.height - side) / 2,
                width: side,
                height: side
            )
            targetCornerRadius = 4
            innerShapeView.backgroundColor = .red

        case .countdown:
            let diameter = bounds.width * 0.85
            targetFrame = CGRect(
                x: (bounds.width - diameter) / 2,
                y: (bounds.height - diameter) / 2,
                width: diameter,
                height: diameter
            )
            targetCornerRadius = diameter / 2
            innerShapeView.backgroundColor = .white
            countdownIcon.isHidden = false
            countdownIcon.frame = targetFrame.insetBy(dx: diameter * 0.3, dy: diameter * 0.3)
        }

        let animations = {
            self.innerShapeView.frame = targetFrame
            self.innerShapeView.layer.cornerRadius = targetCornerRadius
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: animations)
    }

    // MARK: - pressed
    @objc private func handleTap() {
        switch recordState {
        case .ready:
            delegate?.recordButtonDidTapStart(self)

        case .recording:
            delegate?.recordButtonDidTapStop(self)

        case .countdown:
            delegate?.recordButtonDidTapCancelDuringCountdown(self)
        }
    }
}
