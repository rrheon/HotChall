//
//  ModalViewController.swift
//  HotChal
//
//  Created by jonghyuck on 8/7/25.
//

import UIKit
import RxSwift
import RxCocoa

protocol ModalViewControllerProtocol {
  func willDismissModalView(_ viewController: ModalViewController, startTime: Double?, endTime: Double?)
}


/// 챌린지 배우기 - 반복설정 화면
final class ModalViewController: UIViewController {
  var delegate: ModalViewControllerProtocol? = nil

  var reactor: ModalReactor? = nil
  private let disposeBag: DisposeBag = DisposeBag()

  private let startTimeField = UITextField()
  private let endTimeField = UITextField()
  private let closeButton = UIButton(configuration: .bordered())
  private let infoButton = UIButton(type: .system)

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    setupLayout()
    setupTextField()

    let reactor = reactor ?? ModalReactor()
    self.reactor = reactor
    bind(with: reactor)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let sheet = self.sheetPresentationController {
      if #available(iOS 16.0, *) {
        sheet.detents = [.custom { _ in return 170 }]
      } else {
        sheet.detents = [.medium()]
      }
      sheet.prefersGrabberVisible = true  // 위에 바 표시
      sheet.preferredCornerRadius = 20
    }
  }

  // MARK: setupLayout

  private func setupLayout(){
    // 제목 라벨
    let titleLabel = UILabel()
    titleLabel.text = "반복설정"
    titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
    titleLabel.textAlignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(titleLabel)

    // 안내 문구 라벨
    infoButton.setImage(UIImage(systemName: "exclamationmark.bubble"), for: .normal)
    infoButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    infoButton.tintColor = .appPink
    infoButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(infoButton)

    // 텍스트필드 StackView (기존 방식 유지)
    let timeInputStackView = UIStackView(arrangedSubviews: [startTimeField, endTimeField])
    timeInputStackView.axis = .horizontal
    timeInputStackView.spacing = 12
    timeInputStackView.distribution = .fillEqually
    timeInputStackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(timeInputStackView)

    [startTimeField, endTimeField].forEach {
      $0.borderStyle = .roundedRect
      $0.keyboardType = .decimalPad
      $0.textColor = .label
      $0.backgroundColor = .clear
      $0.textAlignment = .center
    }

    view.addSubview(timeInputStackView)

    closeButton.setTitle("설정 완료하기", for: .normal)
    closeButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
    closeButton.backgroundColor = .appPink
    closeButton.tintColor = .white

    closeButton.layer.cornerRadius = 12
    closeButton.layer.masksToBounds = false

    closeButton.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(closeButton)

    NSLayoutConstraint.activate([
      // 제목
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
      titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

      //  텍스트 필드 스택
      timeInputStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
      timeInputStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      timeInputStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      timeInputStackView.heightAnchor.constraint(equalToConstant: 44),

      // 안내문
      infoButton.topAnchor.constraint(equalTo: titleLabel.topAnchor),
      infoButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 40),

      // 설정완료 버튼
      closeButton.topAnchor.constraint(equalTo: timeInputStackView.bottomAnchor, constant: 20),
      closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
  }

  private func setupTextField(){
    startTimeField.placeholder = "시작시간(초)"
    endTimeField.placeholder = "종료시간(초)"

    [startTimeField, endTimeField].forEach {
      $0.layer.borderWidth = 1
      $0.layer.cornerRadius = 8
      $0.layer.borderColor = UIColor.darkGray.cgColor
    }
  }

  // MARK: bind

  private func bind(with reactor: ModalReactor) {
    // 시작시간 입력
    startTimeField.rx.text.orEmpty
      .skip(1)
      .distinctUntilChanged()
      .map { ModalReactor.Action.startTimeChanged($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // 종료시간 입력
    endTimeField.rx.text.orEmpty
      .skip(1)
      .distinctUntilChanged()
      .map { ModalReactor.Action.endTimeChanged($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // 설정 완료 버튼
    closeButton.rx.tap
      .map { ModalReactor.Action.confirmButtonTapped }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // 툴팁 버튼
    infoButton.rx.tap
      .map { ModalReactor.Action.showTooltip }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // TextField 포커스 상태 관리
    startTimeField.rx.controlEvent(.editingDidBegin)
      .subscribe(onNext: { [weak self] in
        self?.startTimeField.layer.borderColor = UIColor.white.cgColor
      })
      .disposed(by: disposeBag)

    startTimeField.rx.controlEvent(.editingDidEnd)
      .subscribe(onNext: { [weak self] in
        self?.startTimeField.layer.borderColor = UIColor.darkGray.cgColor
      })
      .disposed(by: disposeBag)

    endTimeField.rx.controlEvent(.editingDidBegin)
      .subscribe(onNext: { [weak self] in
        self?.endTimeField.layer.borderColor = UIColor.white.cgColor
      })
      .disposed(by: disposeBag)

    endTimeField.rx.controlEvent(.editingDidEnd)
      .subscribe(onNext: { [weak self] in
        self?.endTimeField.layer.borderColor = UIColor.darkGray.cgColor
      })
      .disposed(by: disposeBag)

    // State 바인딩 - 툴팁 표시
    reactor.state.map { $0.showTooltip }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        self?.showTooltipView()
      })
      .disposed(by: disposeBag)

    // State 바인딩 - dismiss
    reactor.state
      .filter { $0.shouldDismiss }
      .take(1)
      .subscribe(onNext: { [weak self] state in
        guard let self = self else { return }
        self.delegate?.willDismissModalView(self, startTime: state.dismissStartTime, endTime: state.dismissEndTime)
        self.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
  }

  private func showTooltipView() {
    let tooltip = TooltipView(text: "아무것도 입력하지 않고 완료 버튼을 누르면 루프가 초기화됩니다.")
    tooltip.alpha = 0
    view.addSubview(tooltip)

    // 버튼 기준 위치 설정
    NSLayoutConstraint.activate([
      tooltip.bottomAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 45),
      tooltip.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      tooltip.widthAnchor.constraint(lessThanOrEqualToConstant: 300)
    ])

    // 애니메이션으로 나타나고, 2초 뒤에 사라짐
    UIView.animate(withDuration: 0.3, animations: {
      tooltip.alpha = 1
    }) { _ in
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        UIView.animate(withDuration: 0.3, animations: {
          tooltip.alpha = 0
        }) { _ in
          tooltip.removeFromSuperview()
        }
      }
    }
  }
}

@available(iOS 17.0, *)
#Preview {
  UINavigationController(rootViewController: PlayerViewController())
}
